extends SceneTree
## Exercises impact geometry and independent weapon systems in the actual game.
const MAIN = preload("res://tests/compact_campaign.tscn")
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
	game = MAIN.instantiate()
	root.add_child(game)
	game.set_process(false)
	game.audio.set_muted(true)
	await process_frame
	game._begin_stage(0)
	game.mode = game.Mode.FLIGHT
	game.player.position = Vector3.ZERO
	game.speed = 42.0
	game.shield = 50.0
	game.pickup_sweep_initialized = false
	game._spawn_pickup(Vector3(0,0,-20),"ring")
	game._update_hazards(1.0)
	_check(game.rings==1 and game.pickups.is_empty(),"A ring crossing the ship in one long frame registers exactly once")
	_check(game.pickup_notice.begins_with("RING 1") and game.pickup_notice_time>0.0,"Ring collection gives immediate count and reward feedback")
	game._update_hazards(.01)
	_check(game.rings==1,"A collected ring cannot award twice")
	game.player.position = Vector3(-10,0,0)
	game.pickup_sweep_initialized = false
	game._spawn_pickup(Vector3.ZERO,"ring")
	game._update_hazards(0.0)
	game.player.position = Vector3(10,0,0)
	game._update_hazards(0.0)
	_check(game.rings==2,"Relative sweep catches rapid sideways player travel through a ring")
	game.player.position = Vector3.ZERO
	game.pickup_sweep_initialized = false
	game._spawn_pickup(Vector3(5.0,0,-10),"ring")
	game._update_hazards(.5)
	_check(game.rings==2,"A visible near miss outside the pickup envelope stays uncollected")
	game._clear_actors()
	game.missiles = 1
	var target: Dictionary = game._spawn_enemy("bomber",0,1,0)
	target.node.position = Vector3(0,0,-35)
	target.hp = 100.0
	var adjacent: Dictionary = game._spawn_enemy("bomber",0,1,0)
	adjacent.node.position = Vector3(13,0,-35)
	adjacent.hp = 100.0
	var far: Dictionary = game._spawn_enemy("bomber",0,1,0)
	far.node.position = Vector3(28,0,-35)
	far.hp = 100.0
	game.lock_target = target.node
	game.lock_progress = 1.0
	game.missile_cooldown = 0.0
	game._missile()
	_check(game.missiles==0 and game.projectiles.size()==1,"A locked player missile consumes one round")
	game.missile_cooldown = 0.0
	game.lock_progress = 1.0
	game._missile()
	_check(game.projectiles.size()==1,"An empty missile rack cannot launch another round")
	for frame in range(80): game._update_projectiles(1.0/60.0)
	_check(target.hp<100.0 and adjacent.hp<100.0,"Actual missile impact damages target and a nearby ship across an 18-unit blast")
	_check(far.hp==100.0,"Missile splash leaves enemies beyond its radius intact")
	game._clear_actors()
	game._spawn_pickup(game.player.position,"missile")
	game._update_hazards(0.0)
	_check(game.missiles==3,"Cyan ammunition pickup grants three missiles")
	game.missiles = 7
	game._spawn_pickup(game.player.position,"repair")
	game._update_hazards(0.0)
	_check(game.missiles==8,"Repair resupply respects the eight-round ammo cap")
	game._spawn_boss()
	game.boss.position = Vector3(0,0,70)
	game.aim = Vector3(0,0,-100)
	_check(game._nearest_target(30.0)==null,"Boss and weapon systems behind the ship cannot acquire a forward lock")
	game.boss.position = Vector3(0,0,-70)
	var part: Dictionary = game.boss_parts[0]
	var core_hp: float = game.boss_hp
	var part_hp: float = part.hp
	game._spawn_shot(part.node.global_position+Vector3(0,0,5),Vector3(0,0,-210),true,3.0)
	game._update_projectiles(.04)
	_check(part.hp<part_hp and game.boss_hp==core_hp,"A projectile damages the selected subsystem independently of core health")
	game._damage_boss(10.0,game.boss.position)
	_check(is_equal_approx(core_hp-game.boss_hp,.8),"Live weapon systems armor the core against direct damage")
	_clear_projectiles()
	game._fire_live_parts(40.0,10.0)
	var live_count: int = game.projectiles.size()
	_clear_projectiles()
	game._damage_boss_part(part,1000.0)
	game._fire_live_parts(40.0,10.0)
	_check(game.projectiles.size()==live_count-1 and not part.node.visible,"Destroying a weapon visibly removes it and stops its shots")
	for system in game.boss_parts: game._damage_boss_part(system,1000.0)
	_check(game._boss_core_open(),"Destroying all weapon systems exposes the core")
	core_hp = game.boss_hp
	game._damage_boss(10.0,game.boss.position)
	_check(is_equal_approx(core_hp-game.boss_hp,10.0),"Exposed core takes full weapon damage")
	for index in range(3,6):
		game._clear_actors()
		game.stage = index
		game.mode = game.Mode.BOSS
		game.boss = game.Ship.new()
		game.actors.add_child(game.boss)
		game.boss.setup("boss%d"%(index+1),Color.WHITE)
		game.boss.scale = Vector3.ONE*2.1
		game.boss.position = Vector3(0,0,-80)
		game.boss_parts.clear()
		for weak in game.boss.weak_points:
			if weak!=game.boss.core: game.boss_parts.append({"node":weak,"hp":50.0,"max_hp":50.0,"name":"TEST","radius":3.8})
		_check(game.boss_parts.size()==(2 if index==3 else 4),"New boss%d has its own destructible weapon layout"%(index+1))
		game.boss_attack = 1
		game.boss_volley_target = Vector3.ZERO
		game._fire_new_boss_pattern()
		_check(not game.projectiles.is_empty(),"New boss%d emits its distinct attack pattern"%(index+1))
		if index==3:
			_check(game.projectiles.size()==11 and game.projectiles[0].node.position.y==-2.0,"Siege crawler ground sweep leaves the hover altitude open")
		if index==4:
			var before: Vector3 = game.boss.position
			game.boss_fire = 100.0
			game._update_boss(.2)
			_check(game.boss.position.is_equal_approx(before),"Arena boss placement remains under arena controller authority")
		if index==5:
			game.boss_attack = 3
			game._fire_new_boss_pattern()
			_check(game.beam_time==0.0 and is_instance_valid(game.beam_mesh),"Storm fortress telegraphs its lane lance")
	# Every exposed core must be hittable at its visible position, including the
	# Sovereign's core well ahead of the body-origin collision sphere.
	for index in range(6):
		game._begin_stage(index)
		game._spawn_boss()
		game.boss.position = Vector3(0,0,-90)
		game.boss.rotation = Vector3.ZERO
		for system in game.boss_parts: game._damage_boss_part(system,10000.0)
		var core: Node3D = game.boss.core
		game.player.position = Vector3(0,core.global_position.y,0)
		game.aim = core.global_position
		game.lock_target = core
		game.lock_progress = 1.0
		game.missile_cooldown = 0.0
		game.missiles = 6
		var hp_before_missile: float = game.boss_hp
		game._missile()
		for frame in range(360): game._update_projectiles(1.0/120.0)
		_check(game.boss_hp<hp_before_missile and game.projectiles.is_empty(),"Boss%d missile detonates on the exposed visible core without orbiting it"%(index+1))
		var hp_before_laser: float = game.boss_hp
		game._fire_player()
		for frame in range(180): game._update_projectiles(1.0/120.0)
		_check(game.boss_hp<hp_before_laser,"Boss%d aimed lasers hit the exposed visible core"%(index+1))
	game._clear_actors()
	game.audio.stop_music()
	game.queue_free()
	await process_frame
	await create_timer(.2).timeout
	if had_save:
		var restore := FileAccess.open(TEST_SAVE,FileAccess.WRITE)
		restore.store_string(original_save)
	else: DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("COMBAT_REVISION_SMOKE: %d assertions; %d failures"%[assertions,failures.size()])
	for failure in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)

func _clear_projectiles() -> void:
	for shot in game.projectiles: shot.node.queue_free()
	game.projectiles.clear()

func _check(condition: bool, label: String) -> void:
	assertions += 1
	if not condition: failures.append(label)
	print(("PASS " if condition else "FAIL ")+label)
