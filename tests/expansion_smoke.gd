extends SceneTree
## Six-mission progression, jet-tank collision and all-range carrier defense.
## Uses actual scene controllers with a separate save; fixtures place actors for deterministic impacts.
const MAIN = preload("res://tests/compact_campaign.tscn")
const Arena = preload("res://scripts/flight_arena.gd")
const Tank = preload("res://scripts/flight_tank.gd")
const TEST_SAVE := "user://foxlike_test_save.json"
var game: Node3D
var failures: Array[String] = []
var assertions := 0
var original_save := ""
var had_save := false

func _initialize() -> void:
	if not "--test-save" in OS.get_cmdline_user_args():
		quit(2)
		return
	call_deferred("run")

func run() -> void:
	had_save = FileAccess.file_exists(TEST_SAVE)
	if had_save: original_save = FileAccess.get_file_as_string(TEST_SAVE)
	_write_fixture({"unlocked":3,"best":4000,"muted":true,"difficulty":"Standard","records":{"2_Standard":4000}})
	game = MAIN.instantiate()
	root.add_child(game)
	game.set_process(false)
	game.audio.set_muted(true)
	await process_frame
	_check(game.STAGES.size()==6 and game.hud._stage_buttons.size()==6,"Campaign and main-screen mission selector expose all six missions")
	_check(game.save_data.unlocked==4 and game.save_data.completed_stages.has(2),"A legacy Terminus clear unlocks Cinder without replaying the original campaign")
	_check(not game.hud._stage_buttons[3].disabled and game.hud._stage_buttons[4].disabled,"Migration enables the tank mission but preserves later mission locks")
	game.hud._stage_buttons[3].pressed.emit()
	_check(game.stage==3 and game.mode==game.Mode.BRIEFING,"Cinder mission button enters its actual briefing")
	await _start_stage(3)
	_check(is_equal_approx(game.player.position.y,Tank.GROUND_Y) and game.tank.fuel==100.0,"Tank launches grounded with full jet fuel")
	_key(KEY_SHIFT,true)
	await _step(1.0)
	_check(game.player.position.y>4.0 and game.tank.fuel<80.0 and game.tank.hovering,"Holding Shift lifts the tank's collision position and consumes fuel")
	var hover_y: float = game.player.position.y
	var hover_fuel: float = game.tank.fuel
	game._pause(true)
	await _step(0.6)
	_check(is_equal_approx(game.player.position.y,hover_y) and is_equal_approx(game.tank.fuel,hover_fuel),"Pause freezes jet movement and fuel")
	game._pause(false)
	var shield_before: float = game.shield
	var score_before: int = game.stage_score
	game._spawn_ground_barrier(0.0,42.0,3.5)
	game.ground_barriers.back().node.position.z = -3.5
	game._update_ground_barriers(0.05)
	_check(is_equal_approx(game.shield,shield_before) and game.stage_score==score_before+250,"Hovering above a real barrier avoids damage and awards clearance points")
	await _step(4.5)
	_check(game.tank.exhausted and not game.tank.hovering and is_equal_approx(game.player.position.y,Tank.GROUND_Y),"Depleted jet packs stop hovering and land even while Shift stays held")
	await _step(1.0)
	_check(not game.tank.hovering and game.tank.fuel>0.0,"Grounded fuel recovery does not automatically rearm held jet packs")
	_key(KEY_SHIFT,false)
	await _step(2.0)
	_check(game.tank.fuel>=99.0 and not game.tank.exhausted,"Releasing Shift on the ground rearms and fully recharges the tank")
	game.invulnerable = 0.0
	game._spawn_ground_barrier(0.0,42.0,3.5)
	game.ground_barriers.back().node.position.z = -3.5
	game._update_ground_barriers(0.05)
	_check(game.shield<shield_before,"The same barrier damages a grounded tank")
	game._roll(1.0)
	game._start_maneuver(game.Maneuver.Kind.LONG_LOOP)
	_check(game.roll_time==0.0 and not game.maneuver.active(),"Jet tank cannot activate flight rolls or loop maneuvers")
	_key(KEY_SHIFT,true)
	await _step(0.5)
	_check(game.tank.hovering and game.player.position.y>Tank.GROUND_Y+1.0,"A released and re-pressed jet control begins a new jump")
	_key(KEY_SHIFT,false)

	await _start_stage(4)
	_check(game.defense_carrier.visible and not game.carrier.visible,"Arena uses the defense carrier rather than the launch flyby")
	var world_position_before: Vector3 = game.arena.position
	var heading_before: float = game.arena.heading
	var landmark_before: Vector3 = game.defense_carrier.position
	_key(KEY_D,true)
	await _step(0.6)
	_key(KEY_D,false)
	_check(absf(angle_difference(heading_before,game.arena.heading))>0.3 and game.arena.position.distance_to(world_position_before)>10.0,"Arena steering changes world heading and actual position")
	_check(game.defense_carrier.position.distance_to(landmark_before)>10.0 and game.defense_carrier.position.is_equal_approx(game.arena.to_local(game.carrier_world)),"Carrier view follows the world-to-flight-frame transform")
	game._update_hud(0.1)
	_check(game.overlay._arena_enabled and game.overlay._radar_player.is_equal_approx(Vector2(game.arena.position.x,game.arena.position.z)) and is_equal_approx(game.overlay._radar_heading,game.arena.heading),"Radar receives the authoritative world position and heading")
	var world_point := Vector3(36,20,-42)
	_check(game.arena.to_world(game.arena.to_local(world_point)).distance_to(world_point)<0.001,"Arena local/world coordinates round-trip without moving landmarks")
	# A turn changes the presentation frame; an existing shot keeps its world trajectory.
	game._spawn_shot(game.arena.to_local(world_point),Vector3(0,0,-40),true,1.0)
	var shot: Dictionary = game.projectiles.back()
	var world_velocity: Vector3 = game.arena.basis()*Vector3(shot.velocity)
	game._update_arena_player(0.05,Vector2(1.0,0.0),false,-1)
	_check(game.arena.to_world(shot.node.position).distance_to(world_point)<0.001 and (game.arena.basis()*Vector3(shot.velocity)).distance_to(world_velocity)<0.001,"Turning preserves existing projectile world position and velocity")
	game._spawn_arena_wave({"kind":"attack","count":1,"angle":1.2})
	var frame_target: Dictionary = game.enemies.back()
	game._update_arena_player(0.05,Vector2(1.0,0.0),false,-1)
	_check(frame_target.node.position.distance_to(game.arena.to_local(frame_target.arena_pos))<0.001,"Arena targets refresh into the current turn frame before firing")
	game._update_arena_enemies(0.05)
	var intended: Vector3 = (game.carrier_world+Vector3(0,6,0)-Vector3(frame_target.arena_pos)).normalized()
	var facing: Vector3 = game.arena.basis()*(frame_target.node.visual.global_basis*Vector3.FORWARD).normalized()
	_check(facing.dot(intended)>.95,"Arena attacker visual nose faces its actual approach direction")
	game._clear_actors()
	var rim_results: Array[Vector3] = []
	for fps in [20,120]:
		var navigation := Arena.new()
		navigation.position = Vector3(0,12,-185)
		navigation.heading = 0.0
		var highest := navigation.position.y
		var furthest := 0.0
		for frame in range(int(float(fps)*3.2)):
			navigation.advance(1.0/float(fps),Vector2.ZERO,false,false)
			highest = maxf(highest,navigation.position.y)
			furthest = maxf(furthest,Vector2(navigation.position.x,navigation.position.z).length())
		var radial := Vector3(navigation.position.x,0,navigation.position.z)
		_check(navigation.turn_count==1 and not navigation.turning and radial.dot(navigation.basis()*Vector3.FORWARD)<0.0 and highest>18.0 and furthest<Arena.RADIUS,"%d FPS rim turnaround climbs once, stays contained and resumes facing inward" % fps)
		rim_results.append(navigation.position)
	_check(rim_results[0].distance_to(rim_results[1])<3.0,"Low and high frame-rate turnarounds finish within three world units")
	game.arena.position = Vector3(0,12,-185)
	game.arena.heading = 0.0
	game.invulnerable = 0.0
	game._update_arena_player(0.05,Vector2.ZERO,false,-1)
	_check(game.arena.turning and game.invulnerable==0.0,"Automatic boundary turn gives no free invulnerability")
	var turn_time: float = game.arena.turn_time
	game._pause(true)
	await _step(0.4)
	_check(is_equal_approx(game.arena.turn_time,turn_time),"Pause freezes the automatic turnaround")
	game._pause(false)
	game.arena.reset()
	game._sync_arena_view()
	game._spawn_arena_wave({"kind":"attack","count":2,"angle":1.2})
	var attacker: Dictionary = game.enemies[0]
	attacker.arena_pos = game.carrier_world+Vector3(90,8,0)
	attacker.fire = 0.0
	game._update_arena_enemies(0.05)
	var attacks := 0
	for projectile in game.projectiles:
		if projectile.get("carrier_attack",false): attacks += 1
	_check(attacks>0,"Arena strike wing fires physical carrier-directed projectiles")
	game._update_hud(0.1)
	_check(game.overlay._radar_contacts.size()==2,"Radar includes enemy world contacts around the carrier")
	game._clear_actors()
	var carrier_center: Vector3 = game.arena.to_local(game.carrier_world+Vector3(0,4,0))
	game._spawn_shot(carrier_center+Vector3(-18,0,0),Vector3(100,0,0),false,12.0)
	game.projectiles.back()["carrier_attack"] = true
	game._update_projectiles(0.05)
	game._update_carrier_defense(0.05)
	_check(is_equal_approx(game.carrier_hp,88.0),"An actual hostile projectile impact removes carrier hull")
	var hull_after: float = game.carrier_hp
	game._update_carrier_defense(0.05)
	_check(is_equal_approx(game.carrier_hp,hull_after),"A consumed carrier projectile cannot apply damage twice")
	game._spawn_shot(carrier_center,Vector3.ZERO,true,25.0)
	game._update_projectiles(0.05)
	game._update_carrier_defense(0.05)
	_check(is_equal_approx(game.carrier_hp,hull_after),"Friendly bolts cannot damage the protected carrier")
	game.carrier_hp = 1.0
	game._spawn_shot(carrier_center,Vector3.ZERO,false,2.0)
	game._update_projectiles(0.05)
	game._update_carrier_defense(0.05)
	_check(game.mode==game.Mode.DEAD and not game.overlay.visible,"Carrier hull depletion fails the defense mission")
	game._on_action("retry")
	_check(game.stage==4 and game.mode==game.Mode.BRIEFING and game.carrier_hp==100.0 and game.projectiles.is_empty(),"Retry restores the carrier and clears the failed battle")

	await _start_stage(4)
	game._spawn_boss()
	game.boss.position = Vector3(0,0,70)
	game.boss.rotation = Vector3.ZERO
	game.aim = game.player.position+Vector3.FORWARD*100.0
	_check(not is_instance_valid(game._nearest_target(10.0)),"Arena boss and its parts behind the player cannot acquire a forward lock")
	game.boss.position = Vector3(100,0,-80)
	_check(not is_instance_valid(game._nearest_target(10.0)),"An off-axis arena boss cannot acquire a false forward lock")

	for index in range(3,6):
		await _start_stage(index)
		game.waves = game._build_waves(index)
		game.wave_index = 0
		game.flight_time = 30.1
		game._update_waves()
		_check(game.wave_index>=3 and (not game.enemies.is_empty() or not game.ground_barriers.is_empty()),"Mission %d dispatches its authored encounter and traversal events" % (index+1))
		game._clear_actors()
		game.waves = []
		game.flight_time = float(game.STAGES[index].duration)-0.01
		game.invulnerable = 100.0
		game._process(0.05)
		_check(game.mode==game.Mode.BOSS and is_instance_valid(game.boss) and game.boss_parts.size()>=2,"Mission %d route ends at its own subsystem boss" % (index+1))
		# Remove actual subsystem health, then the core, to test the real clear/result path.
		for part in game.boss_parts.duplicate():
			if float(part.hp)>0.0: game._damage_boss_part(part,10000.0)
		if is_instance_valid(game.boss): game._damage_boss(10000.0,game.boss.global_position)
		_check(game.mode==game.Mode.CLEAR,"Mission %d boss defeat enters the clear flyout" % (index+1))
		await _step(4.2)
		_check(game.mode==game.Mode.RESULT and game.save_data.completed_stages.has(index) and game.save_data.unlocked==mini(6,index+2),"Mission %d clear saves progression and reaches debrief" % (index+1))
	game.save_data.unlocked = 1
	game.save_data.completed_stages = []
	game._read_save()
	_check(game.save_data.unlocked==6 and game.save_data.completed_stages.has(5),"Six-mission completion survives save reload")
	game._on_action("next")
	_check(game.mode==game.Mode.MENU,"Final mission returns to the flight deck without a seventh mission")
	await _finish()

func _start_stage(index: int) -> void:
	_key(KEY_SHIFT,false)
	_key(KEY_D,false)
	game._begin_stage(index)
	game._launch()
	await _step(3.3)
	game.waves = []
	game._clear_actors()
	game.mouse_active = false
	game.move_velocity = Vector2.ZERO
	for wing in game.wingmen:
		wing.fire = 1000.0
		wing.cooldown = 1000.0

func _step(seconds: float) -> void:
	for frame in range(int(ceil(seconds/0.05))):
		game._process(0.05)
		if not game.is_paused: game.effects._process(0.05)
		if frame%20==19: await process_frame

func _key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func _write_fixture(data: Dictionary) -> void:
	var file := FileAccess.open(TEST_SAVE,FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

func _check(ok: bool, description: String) -> void:
	assertions += 1
	print(("PASS " if ok else "FAIL ")+description)
	if not ok: failures.append(description)

func _finish() -> void:
	_key(KEY_SHIFT,false)
	_key(KEY_D,false)
	game.audio.stop_music()
	game.queue_free()
	await process_frame
	await process_frame
	if had_save:
		var restored := FileAccess.open(TEST_SAVE,FileAccess.WRITE)
		restored.store_string(original_save)
	else: DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("EXPANSION_SMOKE: %d assertions; %d failures" % [assertions,failures.size()])
	for failure in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)
