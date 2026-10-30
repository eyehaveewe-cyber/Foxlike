extends SceneTree
## Integration coverage through the real scene and flight update loop.
## Requires --test-save so production player progress is never touched.
const MAIN = preload("res://tests/compact_campaign.tscn")
const TEST_SAVE := "user://foxlike_test_save.json"
var game: Node3D
var failures: Array[String] = []
var assertions := 0
var prior_save := ""
var had_save := false

func _initialize() -> void:
	if not "--test-save" in OS.get_cmdline_user_args():
		push_error("Safety: run with -- --test-save; refusing to touch a player save.")
		quit(2)
		return
	call_deferred("_run")

func _run() -> void:
	had_save = FileAccess.file_exists(TEST_SAVE)
	if had_save: prior_save = FileAccess.get_file_as_string(TEST_SAVE)
	_write_fixture({"unlocked":1,"best":0,"muted":true,"difficulty":"Standard","records":{}})
	game = MAIN.instantiate()
	root.add_child(game)
	game.set_process(false)
	game.audio.set_muted(true)
	await process_frame
	_check(game.mode == game.Mode.MENU, "Scene boots into menu")
	game._on_action("new_run")
	_check(game.mode == game.Mode.BRIEFING and game.stage == 0, "New campaign opens Viridia briefing")
	await _step(0.4) # Briefing runs the enlarged presentation airframe.
	game._on_action("launch")
	_check(game.player.scale.is_equal_approx(Vector3.ONE), "Launch restores gameplay scale after briefing presentation")
	await _step(3.35)
	_check(game.mode == game.Mode.FLIGHT and game.player.position.distance_to(Vector3.ZERO) < 1.0, "Launch animation joins active flight")
	game.waves = []
	game._clear_actors()
	var start_x: float = game.player.position.x
	_key(KEY_D, true)
	await _step(0.8)
	_key(KEY_D, false)
	_check(game.player.position.x > start_x + 5.0 and game.player.position.x <= 18.0, "Physical movement input moves and bounds the ship")
	_key(KEY_SHIFT, true)
	await _step(0.5)
	_key(KEY_SHIFT, false)
	_check(game.speed > 60.0 and game.energy < 95.0, "Boost accelerates and spends energy")
	game.player.position = Vector3.ZERO
	game.move_velocity = Vector2.ZERO
	game.invulnerable = 0.0
	game._hurt(10.0)
	game._hurt(10.0)
	_check(is_equal_approx(game.shield, 90.0), "Damage has a grace period")
	game.invulnerable = 0.0 # Separate roll protection from damage grace.
	await _tap(KEY_E)
	await _step(0.05)
	var protected_shield: float = game.shield
	game._hurt(10.0)
	_check(game.roll_time > 0.0 and is_equal_approx(game.shield, protected_shield), "Roll animation protects the ship")
	game._spawn_shot(game.player.position + Vector3(0,0,-2), Vector3(0,0,100), false, 20.0)
	await _step(0.05)
	_check(is_equal_approx(game.shield, protected_shield), "Rolling deflects an intersecting enemy bolt")
	var paused_time: float = game.flight_time
	await _tap(KEY_ESCAPE)
	await _step(0.4)
	_check(game.is_paused and is_equal_approx(game.flight_time, paused_time), "Escape pauses flight simulation")
	game._on_action("resume")
	await _step(0.05)
	_check(not game.is_paused and game.flight_time > paused_time, "Resume continues flight")
	await _maneuvers()
	await _weapons_and_pickups()
	await _campaign()
	_save_validation()
	game._begin_stage(2)
	game._launch()
	await _step(3.3)
	game.invulnerable = 0.0
	game._hurt(1000.0)
	_check(game.mode == game.Mode.DEAD and not game.player.visible, "Lethal damage opens defeat result")
	game._on_action("retry")
	_check(game.mode == game.Mode.BRIEFING and game.shield == 100.0 and game.bombs == 3 and game.stage == 2, "Retry restores this mission")
	game.audio.stop_music()
	game.queue_free()
	await process_frame
	await create_timer(0.25).timeout
	if had_save:
		var file := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
		file.store_string(prior_save)
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("GAME_SMOKE: %d assertions; %d failures" % [assertions, failures.size()])
	for failure in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)

func _maneuvers() -> void:
	game._begin_stage(0)
	game._launch()
	await _step(3.35)
	game.waves = []
	game._clear_actors()
	game.player.position = Vector3(0,1,0)
	_key(KEY_SHIFT,true)
	await _step(0.05)
	_key(KEY_S,true)
	await _step(0.05)
	_key(KEY_S,false)
	_check(game.maneuver.kind == game.Maneuver.Kind.LONG_LOOP and game.energy < 71.0, "Boost + down starts long loop and charges 30 energy")
	await _step(0.45)
	_check(game.player.position.z < -15.0, "Long loop surges a sizable distance forward")
	var time_before: float = game.maneuver.elapsed
	game._pause(true)
	await _step(0.5)
	_check(is_equal_approx(game.maneuver.elapsed,time_before), "Pause freezes maneuver path and rotation")
	game._pause(false)
	game._roll(1.0)
	_check(game.roll_time <= 0.0, "Barrel roll cannot compete with an active maneuver")
	_key(KEY_SPACE,true)
	var shots_before: int = game.shots_fired
	await _step(0.9)
	_check(game.player.position.y > 7.0 and absf(game.player.visual.rotation.x) > 2.0, "Long loop climbs and turns the actual airframe upside down")
	_check(game.shots_fired == shots_before and not game.maneuver.can_fire, "Loop stops forward fire while its nose turns away")
	_key(KEY_SPACE,false)
	await _step(1.3)
	_check(not game.maneuver.active() and absf(game.player.position.z) < 0.1, "Long loop returns to default flight depth")
	_check(absf(game.player.visual.rotation.x) < 0.1, "Loop hands back a clean steering pose")
	await _step(1.6)
	_check(game.speed < 44.0 and game.boost_depleted, "Holding boost does not cancel the automatic deboost")
	_key(KEY_SHIFT,false)
	await _step(0.05)
	# In-place somersault uses the same directional edge detector as keyboard/stick.
	game.energy = 100.0
	game.player.position = Vector3(2,1,0)
	_key(KEY_SHIFT,true)
	_key(KEY_A,true)
	await _step(0.6)
	_check(game.maneuver.kind == game.Maneuver.Kind.SOMERSAULT and Vector2(game.player.position.x,game.player.position.y).distance_to(Vector2(2,1)) < 0.01, "Boost + left performs a compact in-place somersault")
	await _step(4.3)
	_check(not game.maneuver.active() and is_zero_approx(game.maneuver_cooldown), "Held direction cannot repeatedly start stunts after cooldown")
	_key(KEY_A,false)
	_key(KEY_SHIFT,false)
	await _step(0.05)
	game.energy = 100.0
	_key(KEY_SHIFT,true)
	_key(KEY_D,true)
	await _step(1.8)
	_key(KEY_D,false)
	_check(game.maneuver.kind == game.Maneuver.Kind.CORKSCREW and game.player.position.z < -17.5 and game.player.position.y > 3.5, "Boost + right corkscrews up to a forward boosted position")
	var fast_speed: float = game.speed
	var far_depth: float = game.player.position.z
	await _step(0.7)
	_check(game.maneuver.recovering and game.speed < fast_speed and game.speed > 42.0 and game.player.position.z > far_depth, "Corkscrew eases speed and position back together")
	await _step(1.0)
	_check(not game.maneuver.active() and absf(game.player.position.z) < 0.1 and absf(game.speed-42.0)<1.0, "Corkscrew settles fully into cruise")
	_key(KEY_SHIFT,false)
	await _step(0.8)
	game.energy = 29.0
	game._start_maneuver(game.Maneuver.Kind.LONG_LOOP)
	_check(not game.maneuver.active() and is_equal_approx(game.energy,29.0), "Insufficient energy rejects a maneuver without charging")
	game.energy = 100.0
	game._start_maneuver(game.Maneuver.Kind.CORKSCREW)
	game._start_maneuver(game.Maneuver.Kind.LONG_LOOP)
	_check(game.maneuver.kind == game.Maneuver.Kind.CORKSCREW and is_equal_approx(game.energy,70.0), "Repeated starts cannot switch an active maneuver or charge twice")
	game.invulnerable = 0.0
	game._hurt(1000.0)
	_check(game.mode == game.Mode.DEAD and not game.maneuver.active(), "Death interrupts a maneuver and clears its pose state")
	game._on_action("retry")
	_check(not game.maneuver.active() and is_zero_approx(game.maneuver_cooldown), "Retry resets maneuver state and cooldown")
	# Sample the same path at low and high frame rates and along screen boundaries.
	for kind: int in [game.Maneuver.Kind.SOMERSAULT,game.Maneuver.Kind.LONG_LOOP,game.Maneuver.Kind.CORKSCREW]:
		var slow = game.Maneuver.new()
		var fast = game.Maneuver.new()
		slow.start(kind,Vector3(17,12,-3))
		fast.start(kind,Vector3(17,12,-3))
		for frame in range(24): slow.advance(1.0/20.0)
		for frame in range(144): fast.advance(1.0/120.0)
		_check(slow.position.distance_to(fast.position)<0.001 and absf(slow.pitch-fast.pitch)<0.001 and absf(slow.roll-fast.roll)<0.001, "Maneuver %d has matching 20/120fps pose and position" % kind)
		var bounded := true
		fast.start(kind,Vector3(17,12,-3))
		for frame in range(100):
			fast.advance(0.05)
			bounded = bounded and absf(fast.position.x)<=18.0 and fast.position.y<=13.0 and fast.position.y>=-8.0
		_check(bounded and not fast.active(), "Maneuver %d stays in flight bounds and finishes at screen edge" % kind)
	game._launch()
	await _step(3.35)
	game.waves = []
	game._clear_actors()

func _weapons_and_pickups() -> void:
	game._clear_actors()
	game.player.position = Vector3.ZERO
	game.move_velocity = Vector2.ZERO
	game.invulnerable = 100.0
	var enemy: Dictionary = game._spawn_enemy("fighter",0,1,0)
	enemy.base_y = -2.7
	enemy.node.position = Vector3(0,0,-45)
	enemy.fire = 100.0
	_key(KEY_SPACE,true)
	await _step(0.9)
	_key(KEY_SPACE,false)
	_check(game.shots_fired >= 2 and game.kills >= 1 and game.hits >= 1, "Held fire creates traveling bolts that destroy a fighter")
	game._clear_actors()
	var missile_enemy: Dictionary = game._spawn_enemy("bomber",0,1,0)
	missile_enemy.base_y = -2.7
	missile_enemy.node.position = Vector3(0,0,-70)
	missile_enemy.fire = 100.0
	await _step(0.95)
	_check(game.lock_progress >= 0.95, "Keeping a target in the reticle acquires a lock")
	var kills_before: int = game.kills
	await _tap(KEY_R)
	_check(game.missile_cooldown > 0.0, "Locked missile consumes its cooldown")
	await _step(0.8)
	_check(game.kills > kills_before, "Homing missile reaches and destroys its target")
	game._clear_actors()
	game._spawn_enemy("fighter",0,2,0)
	game._spawn_enemy("bomber",1,2,0)
	game._spawn_hazard(Vector3(9,4,-50),3.0)
	game._spawn_shot(Vector3(0,0,-80),Vector3(0,0,50),false,12.0)
	var bombs_before: int = game.bombs
	await _tap(KEY_B)
	await _step(0.05)
	_check(game.bombs == bombs_before-1 and game.enemies.is_empty() and game.hazards.is_empty(), "Nova bomb clears fighters and hazards")
	_check(game.projectiles.is_empty(), "Nova bomb clears hostile shots")
	game.shield = 40.0
	for i in range(3):
		game._spawn_pickup(game.player.position+Vector3(0,0,-1),"ring")
		await _step(0.05)
	_check(game.rings == 3 and game.laser_level == 2 and game.shield > 70.0, "Collected ring trio repairs and upgrades lasers")
	game._spawn_pickup(game.player.position+Vector3(0,0,-1),"repair")
	game._spawn_pickup(game.player.position+Vector3(0,0,-1),"bomb")
	await _step(0.05)
	_check(game.shield > 90.0 and game.shield <= 100.0 and game.bombs == bombs_before, "Repair and ordnance pickups replenish bounded resources")

func _campaign() -> void:
	for index in range(3):
		game._begin_stage(index)
		game._on_action("launch")
		await _step(3.3)
		game.invulnerable = 1000.0
		await _step(8.0)
		_check(not game.enemies.is_empty() and game.wave_index >= 2, "Stage %d schedules real encounter waves" % index)
		await _step(float(game.STAGES[index].duration)-7.8)
		_check(game.mode == game.Mode.BOSS and is_instance_valid(game.boss), "Stage %d reaches its boss through elapsed flight" % index)
		_check(game.boss_parts.size() >= 2, "Stage %d boss exposes destructible weapon pods" % index)
		var hp_before: float = game.boss_parts[0].hp
		var part_position: Vector3 = game.boss_parts[0].node.global_position
		game._spawn_shot(part_position+Vector3(0,0,5),Vector3(0,0,-210),true,3.0)
		await _step(0.05)
		_check(game.boss_parts[0].hp < hp_before, "Stage %d projectile damages its selected boss subsystem" % index)
		for part in game.boss_parts: game._damage_boss_part(part,1000.0)
		game.boss_hp = 1.0
		game._spawn_shot(game.boss.position+Vector3(0,0,5),Vector3(0,0,-210),true,5.0)
		await _step(0.05)
		_check(game.mode == game.Mode.CLEAR, "Stage %d lethal projectile begins victory flyout" % index)
		await _step(4.2)
		_check(game.mode == game.Mode.RESULT and game.campaign_score > 0, "Stage %d flyout settles result and score" % index)
		_check(int(game.save_data.unlocked) >= mini(game.STAGES.size(),index+2), "Stage %d unlock is persisted" % index)
		game._on_action("next")
		_check(game.mode == (game.Mode.BRIEFING), "Stage %d result advances or returns to menu" % index)
	_check(FileAccess.file_exists(TEST_SAVE), "Campaign creates isolated progress file")
	var saved: Variant = JSON.parse_string(FileAccess.get_file_as_string(TEST_SAVE))
	_check(saved is Dictionary and int(saved.unlocked) == 4 and int(saved.best) > 0, "Original campaign persists Cinder unlock and best score")

func _save_validation() -> void:
	game.save_data.difficulty = "Standard"
	_write_fixture({"unlocked":999,"best":-7,"muted":"bad","difficulty":"invalid","records":{"0_Standard":-5,"invalid":"bad"}})
	game._read_save()
	_check(game.save_data.unlocked == 6 and game.save_data.best == 0, "Out of range save values are clamped")
	_check(game.save_data.difficulty == "Standard" and not game.save_data.records.has("invalid"), "Invalid save fields are ignored")
	var file := FileAccess.open(TEST_SAVE,FileAccess.WRITE)
	file.store_string("{ broken json")
	file.close()
	game._read_save()
	_check(game.save_data.unlocked == 6, "Malformed save does not crash or erase valid in-memory progress")

func _step(seconds: float) -> void:
	for i in range(int(ceil(seconds / 0.05))):
		game._process(0.05)
		game.effects._process(0.05)
		if i % 20 == 19: await process_frame

func _key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func _tap(code: Key) -> void:
	_key(code,true)
	await process_frame
	_key(code,false)

func _write_fixture(data: Dictionary) -> void:
	var file := FileAccess.open(TEST_SAVE,FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

func _check(condition: bool, label: String) -> void:
	assertions += 1
	print(("PASS " if condition else "FAIL ")+label)
	if not condition: failures.append(label)
