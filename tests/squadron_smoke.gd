extends SceneTree
## Real roster/menu, save migration, formation motion, interception and weapon impacts.
const MAIN = preload("res://scenes/main.tscn")
const Squad = preload("res://scripts/flight_squadron.gd")
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
	var fixture := FileAccess.open(TEST_SAVE,FileAccess.WRITE)
	fixture.store_string(JSON.stringify({"unlocked":1,"best":0,"muted":true,"difficulty":"Standard","records":{}}))
	fixture.close()
	game = MAIN.instantiate()
	root.add_child(game)
	game.set_process(false)
	game.audio.set_muted(true)
	await process_frame
	_check(game.wingmen[0].id=="latch" and game.wingmen[1].id=="glint", "Old save starts with two distinct starter companions")
	_check(game.hud._pilot_buttons.size()==10, "Main screen offers left and right equipment buttons for five pilots")
	game._on_action("equip_companion",{"slot":0,"id":"ember"})
	_check(game.wingmen[0].id=="latch", "Locked companion cannot be equipped")
	game.hud._pilot_buttons[2].button.pressed.emit()
	_check(game.wingmen[0].id=="glint" and game.wingmen[1].id=="latch", "Equipping an occupied pilot swaps slots without duplicates")
	game.hud._formation_button.pressed.emit()
	_check(game.save_data.formation==1,"Main-screen formation selector emits the controller action")
	game.save_data.formation = 0
	game.save_data.companions = ["latch","glint"]
	game._configure_wingmen()
	game._begin_stage(0)
	game._launch()
	await _step(3.35)
	game.waves = []
	game._clear_actors()
	game.player.position = Vector3.ZERO
	game.move_velocity = Vector2.ZERO
	await _step(1.0)
	var wide: float = absf(game.wingmen[0].node.position.x)
	_key(KEY_TAB,true)
	await process_frame
	_key(KEY_TAB,false)
	await _step(1.2)
	_check(game.save_data.formation==1 and absf(game.wingmen[0].node.position.x)<wide-3.0 and game.wingmen[0].node.position.z < -15.0, "Tab changes formation and ships fly into spearhead positions")
	game._cycle_formation()
	await _step(1.0)
	_check(game.save_data.formation==2 and absf(game.wingmen[0].node.position.z+5.0)<0.3, "Close guard brings both companions near the player")
	game._cycle_formation()
	await _step(1.0)
	var latch: Dictionary = game.wingmen[0]
	var shield_before: float = game.shield
	var hp_before: float = latch.hp
	game._spawn_shot(Vector3(0,0,-35),Vector3(0,0,50),false,14.0)
	await _step(0.8)
	_check(latch.hp<hp_before and is_equal_approx(game.shield,shield_before), "Bodyguard flies ahead and physically absorbs an incoming hit")
	_check(latch.cooldown>0.0 and latch.node.position.z<game.player.position.z, "Interception consumes the guardian's independent cooldown")
	await _step(1.0)
	game.invulnerable = 0.0
	game._spawn_shot(Vector3(0,0,-35),Vector3(0,0,50),false,10.0)
	await _step(0.85)
	_check(game.shield<shield_before, "Guardian on cooldown does not give the player passive invulnerability")
	game._clear_actors()
	game.invulnerable = 0.0
	latch.node.position = Vector3(0,0,3)
	game.wingmen[1].node.position = Vector3(12,0,0)
	var hp_behind: float = latch.hp
	var player_before: float = game.shield
	game._spawn_shot(Vector3(0,0,-2),Vector3(0,0,200),false,10.0)
	game._update_projectiles(0.05)
	_check(game.shield<player_before and is_equal_approx(latch.hp,hp_behind),"Companion behind the player cannot absorb a shot that already hits the player")
	game._clear_actors()
	game.shield = 100.0
	game._spawn_pickup(game.player.position+Vector3(0,0,-1),"wing_power")
	await _step(0.05)
	_check(latch.level==2 and game.wingmen[1].level==2, "Violet wing pickup upgrades both active companions")
	var base_cd: float = Squad.profile("latch").cooldown
	_check(Squad.ability_cooldown(latch)<base_cd, "Wing arsenal upgrade shortens ability cooldown")
	var upgrade_target: Dictionary = game._spawn_enemy("bomber",0,1,0)
	upgrade_target.node.position = Vector3(0,2,-80)
	latch.fire = 0.0
	game.wingmen[1].fire = 1000.0
	game.wingmen[1].cooldown = 1000.0
	game._update_wingmen(0.05)
	_check(not game.projectiles.is_empty() and game.projectiles[0].damage>float(Squad.profile("latch").damage) and float(latch.fire)<float(Squad.profile("latch").interval), "Arsenal upgrade increases real laser damage and firing rate")
	game._clear_actors()
	game._empower_squadron()
	game._empower_squadron()
	_check(latch.level==3 and game.wingmen[1].level==3, "Companion weapon upgrades cap at Mk III")
	game._hurt_wing(game.wingmen[1],1000.0)
	game._empower_squadron()
	_check(game.wingmen[1].hp==0.0 and not game.wingmen[1].node.visible, "Arsenal pickups do not revive a withdrawn companion")
	game.wingmen[1].cooldown = 0.0
	game._assist()
	_check(game.wingmen[1].burst==0, "Withdrawn companions cannot activate abilities")
	# Each clear grants its matching recruit; no fake kills or score threshold needed.
	for stage in range(3):
		game.stage = stage
		game._finish_stage()
		_check(Squad.available(["pike","ember","bastion"][stage],game.save_data), "Stage %d clear unlocks its specialist" % stage)
	game._show_menu()
	game._on_action("equip_companion",{"slot":0,"id":"pike"})
	game._on_action("equip_companion",{"slot":1,"id":"ember"})
	_check(game.wingmen[0].id=="pike" and game.wingmen[1].id=="ember", "Unlocked missile and Nova specialists equip from main screen")
	game.save_data.companions = ["latch","glint"]
	game._read_save()
	_check(game.save_data.companions==["pike","ember"] and game.save_data.completed_stages.size()==3, "Selected roster and campaign unlocks survive save reload")
	game._begin_stage(0)
	game._launch()
	await _step(3.35)
	game.waves = []
	game._clear_actors()
	game.player.position = Vector3.ZERO
	var pike: Dictionary = game.wingmen[0]
	var ember: Dictionary = game.wingmen[1]
	pike.node.position = Vector3(-4,1,-12)
	ember.node.position = Vector3(4,1,-12)
	var enemy: Dictionary = game._spawn_enemy("bomber",0,1,0)
	enemy.node.position = Vector3(0,1,-60)
	enemy.hp = 100.0
	game._companion_ability(pike,enemy.node)
	_check(game.projectiles.size()==1 and game.projectiles[0].missile and not bool(game.projectiles[0].get("nova",false)), "Missile specialist launches a real homing projectile")
	var missile_hp: float = enemy.hp
	for frame in range(30): game._update_projectiles(0.05)
	_check(enemy.hp<missile_hp, "Companion missile travels to target and deals damage")
	game._clear_actors()
	var first: Dictionary = game._spawn_enemy("bomber",0,1,0)
	first.node.position = Vector3(0,1,-65)
	first.hp = 100.0
	var second: Dictionary = game._spawn_enemy("bomber",0,1,0)
	second.node.position = Vector3(8,1,-65)
	second.hp = 100.0
	game._companion_ability(ember,first.node)
	_check(game.projectiles.size()==1 and bool(game.projectiles[0].get("nova",false)), "Nova specialist launches a distinct traveling Nova")
	for frame in range(30): game._update_projectiles(0.05)
	_check(first.hp<100.0 and second.hp<100.0, "Companion Nova impact damages nearby enemies")
	_check(ember.cooldown>pike.cooldown and pike.cooldown>0.0, "Missile and Nova specialists keep different independent cooldowns")
	var pause_cd: float = ember.cooldown
	game._pause(true)
	await _step(0.4)
	_check(is_equal_approx(ember.cooldown,pause_cd),"Pause freezes individual companion cooldowns")
	game._pause(false)
	var pike_cd: float = pike.cooldown
	game._assist()
	_check(is_equal_approx(pike.cooldown,pike_cd), "Squad command cannot bypass specialist cooldowns")
	game._clear_actors()
	game._spawn_boss()
	game.boss_hp = 1.0
	ember.cooldown = 0.0
	game._companion_ability(ember,game.boss)
	game.projectiles.back().node.position = game.boss.position+Vector3(0,0,2)
	game.projectiles.back().velocity = Vector3.ZERO
	game._update_projectiles(0.05)
	_check(game.mode==game.Mode.CLEAR and game.projectiles.is_empty(),"Companion Nova killing a boss safely transitions and clears active projectiles")
	game._clear_actors()
	game._show_menu()
	game._on_action("equip_companion",{"slot":0,"id":"glint"})
	game._begin_stage(0)
	game._launch()
	await _step(3.35)
	game.waves = []
	game._clear_actors()
	var glint: Dictionary = game.wingmen[0]
	var target: Dictionary = game._spawn_enemy("bomber",0,1,0)
	target.node.position = Vector3(0,1,-70)
	target.hp = 100.0
	game._update_wingmen(0.05)
	_check(glint.cooldown>0.0 and glint.burst>0 and game.projectiles.size()>=2, "Rapid gunner automatically shoots and starts a burst against threats")
	var burst_shots: int = game.projectiles.size()
	for frame in range(12): game._update_wingmen(0.05)
	_check(game.projectiles.size()>burst_shots+3, "Burst emits successive real shots rather than instant damage")
	glint.hp = 0.0
	game._clear_actors()
	game._begin_stage(0)
	_check(game.wingmen[0].hp==game.wingmen[0].max_hp and game.wingmen[0].level==1, "Mission refit restores chosen companions and resets temporary upgrades")
	var old := {"unlocked":3,"records":{"2_Standard":100}}
	Squad.normalize(old)
	_check(Squad.available("bastion",old) and old.companions==["latch","glint"], "Legacy clear records migrate to full roster access")
	var bad := {"unlocked":1,"records":{},"companions":["ember","unknown","latch","latch"],"completed_stages":["bad",99,-1,1.5],"formation":"bad"}
	Squad.normalize(bad)
	_check(bad.companions==["latch","glint"] and bad.formation==0 and bad.completed_stages.is_empty(), "Malformed loadout, formation and unlock fields sanitize safely")
	game.audio.stop_music()
	game.queue_free()
	await process_frame
	await process_frame
	await create_timer(0.2).timeout
	if had_save:
		var restored := FileAccess.open(TEST_SAVE,FileAccess.WRITE)
		restored.store_string(original_save)
	else: DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("SQUADRON_SMOKE: %d assertions; %d failures" % [assertions,failures.size()])
	for failure in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)

func _step(seconds: float) -> void:
	for frame in range(int(ceil(seconds/0.05))):
		game._process(0.05)
		game.effects._process(0.05)
		if frame%20==19: await process_frame

func _key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func _check(ok: bool, description: String) -> void:
	assertions += 1
	print(("PASS " if ok else "FAIL ")+description)
	if not ok: failures.append(description)
