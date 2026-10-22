extends Node3D
## Foxlike's flight simulation. Forward is -Z; scenery advances toward the camera.
## Visual rigs never own gameplay position or damage.
const Ship = preload("res://scripts/ship_model.gd")
const World = preload("res://scripts/flight_world.gd")
const Hud = preload("res://scripts/flight_hud.gd")
const Sound = preload("res://scripts/flight_audio.gd")
const Effects = preload("res://scripts/flight_effects.gd")
const Overlay = preload("res://scripts/flight_overlay.gd")
const SAVE_PATH := "user://foxlike_save.json"
var save_path := SAVE_PATH
const STAGES := [
	{"index":0, "title":"VIRIDIA", "subtitle":"01 / The coast is burning", "description":"Asterion's evacuation corridor has fallen silent. Comet Flight launches from the Dragonfly to reopen it. Fly the sea wall, cut through the defense line, and bring down the blockade frigate.", "objective":"Break the coastal blockade", "boss":"WARDEN / blockade frigate", "duration":88.0},
	{"index":1, "title":"AURORA", "subtitle":"02 / Ghosts in the ice", "description":"The blockade was a decoy. A signal is guiding the enemy through Aurora's shattered moon. Follow it into the debris field. RIME is awake, and its weapon arms are tracking your squadron.", "objective":"Silence the RIME relay", "boss":"RIME / autonomous hunter", "duration":96.0},
	{"index":2, "title":"TERMINUS", "subtitle":"03 / The last light", "description":"The enemy command carrier is charging its jump drive. Your squadron has one approach through the orbital shipyard. Sever its weapon systems and destroy the command core before Asterion loses its last line of defense.", "objective":"Destroy the command carrier", "boss":"SOVEREIGN / command carrier", "duration":104.0}
]
enum Mode {MENU, BRIEFING, LAUNCH, FLIGHT, BOSS, CLEAR, RESULT, DEAD}
var mode: Mode = Mode.MENU
var is_paused := false
var stage := 0
var flight_time := 0.0
var clock := 0.0
var mode_time := 0.0
var speed := 42.0
var stage_score := 0
var campaign_score := 0
var kills := 0
var shots_fired := 0
var hits := 0
var combo := 0
var combo_time := 0.0
var best_combo := 0
var shield := 100.0
var energy := 100.0
var boost_depleted := false
var bombs := 3
var rings := 0
var laser_level := 1
var invulnerable := 0.0
var shot_cooldown := 0.0
var missile_cooldown := 0.0
var roll_time := 0.0
var roll_cooldown := 0.0
var roll_direction := 1.0
var assist_cooldown := 0.0
var wing_fire := 0.0
var boss_fire := 0.0
var boss_attack := 0
var boss_hp := 0.0
var boss_max_hp := 1.0
var boss_parts: Array = []
var beam_time := -1.0
var beam_x := 0.0
var beam_mesh: MeshInstance3D
var damage_flash := 0.0
var camera_shake := 0.0
var lock_progress := 0.0
var lock_target: Node3D
var aim := Vector3(0, 0, -100)
var move_velocity := Vector2.ZERO
var mouse_active := false
var chatter := true
var gamepad_previous: Dictionary = {}
var save_data: Dictionary = {"unlocked":1,"best":0,"muted":false,"difficulty":"Standard","records":{}}
var waves: Array = []
var wave_index := 0
var enemies: Array = []
var projectiles: Array = []
var hazards: Array = []
var pickups: Array = []
var wingmen: Array = []
var stars_scored := 0
var world: Node3D
var camera: Camera3D
var player: Node3D
var carrier: Node3D
var boss: Node3D
var hud: CanvasLayer
var audio: Node
var effects: Node3D
var overlay: Control
var actors: Node3D
var rng := RandomNumberGenerator.new()
var shot_mesh: CapsuleMesh
var shot_mat: StandardMaterial3D
var enemy_shot_mat: StandardMaterial3D
var missile_mat: StandardMaterial3D
var headless_test := false
var ui_timer := 0.0
var qa_web := false
var qa_clock := 0.0

func _ready() -> void:
	rng.seed = 7741
	if OS.has_feature("web"):
		qa_web = bool(JavaScriptBridge.eval("new URLSearchParams(location.search).has('qa')"))
	if "--test-save" in OS.get_cmdline_user_args(): save_path = "user://foxlike_test_save.json"
	_read_save()
	_setup_inputs()
	world = World.new()
	add_child(world)
	world.setup(0)
	actors = Node3D.new()
	actors.name = "FlightActors"
	add_child(actors)
	camera = Camera3D.new()
	camera.fov = 67.0
	camera.far = 1400.0
	camera.near = 0.2
	add_child(camera)
	camera.current = true
	player = Ship.new()
	actors.add_child(player)
	player.setup("player", Color("cfe8f4"))
	carrier = Ship.new()
	actors.add_child(carrier)
	carrier.setup("carrier", Color("58d9d0"))
	carrier.position = Vector3(-38, 17, -125)
	carrier.scale = Vector3.ONE * 2.0
	for i in range(2):
		var wing: Node3D = Ship.new()
		actors.add_child(wing)
		wing.setup("wingman", Color("ffc075") if i == 0 else Color("7de3cb"))
		wingmen.append({"node":wing,"hp":100.0,"callsign":"LATCH" if i == 0 else "GLINT"})
	effects = Effects.new()
	add_child(effects)
	audio = Sound.new()
	add_child(audio)
	audio.set_muted(bool(save_data.muted))
	hud = Hud.new()
	add_child(hud)
	hud.action.connect(_on_action)
	overlay = Overlay.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.add_child(overlay)
	overlay.visible = false
	_prepare_projectiles()
	_show_menu()
	if "--smoke" in OS.get_cmdline_user_args():
		headless_test = true
		_begin_stage(0)
		_launch()

func _setup_inputs() -> void:
	var keys: Dictionary = {"left":[KEY_A,KEY_LEFT],"right":[KEY_D,KEY_RIGHT],"up":[KEY_W,KEY_UP],"down":[KEY_S,KEY_DOWN],"fire":[KEY_SPACE],"boost":[KEY_SHIFT],"brake":[KEY_CTRL],"roll_left":[KEY_Q],"roll_right":[KEY_E],"missile":[KEY_R],"bomb":[KEY_B],"assist":[KEY_F],"pause":[KEY_ESCAPE],"mute":[KEY_M],"chatter":[KEY_C],"fullscreen":[KEY_F11]}
	for action_name in keys:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		for keycode in keys[action_name]:
			var event := InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_add_event(action_name,event)

func _prepare_projectiles() -> void:
	shot_mesh = CapsuleMesh.new()
	shot_mesh.radius = 0.12
	shot_mesh.height = 2.8
	shot_mesh.radial_segments = 5
	shot_mesh.rings = 1
	shot_mat = _material(Color("68f9ff"), 2.6)
	enemy_shot_mat = _material(Color("ff614b"), 2.0)
	missile_mat = _material(Color("ffc96b"), 2.5)

func _material(color:Color, glow:float=0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.65
	if glow > 0.0:
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = glow
	return mat

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_START and event.pressed and mode in [Mode.LAUNCH,Mode.FLIGHT,Mode.BOSS]:
		_pause(not is_paused)
		return
	if event is InputEventMouseMotion and (mode == Mode.FLIGHT or mode == Mode.BOSS):
		if event.relative.length() > 2.0:
			mouse_active = true
	if event.is_action_pressed("fullscreen"):
		var fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN)
	if event.is_action_pressed("mute"):
		_toggle_mute()
	if event.is_action_pressed("chatter"):
		chatter = not chatter
		hud.say("COMMS", "Chatter resumed." if chatter else "Chatter muted. Critical warnings remain active.", 2.5)
	if event.is_action_pressed("pause") and mode in [Mode.LAUNCH,Mode.FLIGHT,Mode.BOSS]:
		_pause(not is_paused)
	if is_paused or not mode in [Mode.FLIGHT,Mode.BOSS]:
		return
	if event.is_action_pressed("roll_left"):
		_roll(-1.0)
	if event.is_action_pressed("roll_right"):
		_roll(1.0)
	if event.is_action_pressed("bomb"):
		_bomb()
	if event.is_action_pressed("missile") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed):
		_missile()
	if event.is_action_pressed("assist"):
		_assist()

func _on_action(action_name:String, value:Variant=null) -> void:
	audio.sfx("ui")
	match action_name:
		"new_run":
			campaign_score = 0
			_begin_stage(0)
		"continue":
			campaign_score = 0
			_begin_stage(clampi(int(save_data.unlocked)-1,0,2))
		"stage":
			campaign_score = 0
			_begin_stage(clampi(int(value),0,int(save_data.unlocked)-1))
		"launch": _launch()
		"next":
			if stage < 2: _begin_stage(stage+1)
			else: _show_menu()
		"retry": _begin_stage(stage)
		"menu": _show_menu()
		"resume": _pause(false)
		"mute": _toggle_mute()
		"difficulty":
			save_data.difficulty = str(value)
			_write_save()
		"quit": get_tree().quit()

func _toggle_mute() -> void:
	save_data.muted = not bool(save_data.muted)
	audio.set_muted(bool(save_data.muted))
	hud.set_muted(bool(save_data.muted))
	_write_save()
	if mode == Mode.MENU: hud.show_menu(save_data)

func _pause(value:bool) -> void:
	is_paused = value
	hud.show_pause(value)
	effects.set_process(not value)
	overlay.visible = not value

func _clear_actors() -> void:
	for entry in enemies:
		if is_instance_valid(entry.node): entry.node.queue_free()
	for entry in projectiles:
		if is_instance_valid(entry.node): entry.node.queue_free()
	for entry in hazards:
		if is_instance_valid(entry.node): entry.node.queue_free()
	for entry in pickups:
		if is_instance_valid(entry.node): entry.node.queue_free()
	enemies.clear()
	projectiles.clear()
	hazards.clear()
	pickups.clear()
	if is_instance_valid(boss): boss.queue_free()
	boss = null
	if is_instance_valid(beam_mesh): beam_mesh.queue_free()
	beam_mesh = null
	beam_time = -1.0
	lock_target = null
	lock_progress = 0.0

func _show_menu() -> void:
	_clear_actors()
	mode = Mode.MENU
	mode_time = 0.0
	is_paused = false
	effects.set_process(true)
	world.setup(0)
	player.visible = true
	player.position = Vector3(8,2,0)
	player.rotation = Vector3.ZERO
	carrier.visible = true
	carrier.position = Vector3(-28,15,-130)
	for wing in wingmen: wing.node.visible = true
	hud.show_menu(save_data)
	overlay.visible = false
	audio.start_music(0,false)

func _begin_stage(index:int) -> void:
	_clear_actors()
	stage = index
	mode = Mode.BRIEFING
	mode_time = 0.0
	is_paused = false
	effects.set_process(true)
	flight_time = 0.0
	stage_score = 0
	kills = 0
	hits = 0
	shots_fired = 0
	combo = 0
	best_combo = 0
	combo_time = 0.0
	shield = 100.0
	energy = 100.0
	boost_depleted = false
	bombs = 3
	rings = 0
	laser_level = 1
	roll_time = 0.0
	roll_cooldown = 0.0
	assist_cooldown = 0.0
	invulnerable = 0.0
	missile_cooldown = 0.0
	move_velocity = Vector2.ZERO
	boss_hp = 0.0
	boss_parts.clear()
	boss_attack = 0
	camera_shake = 0.0
	damage_flash = 0.0
	speed = 42.0
	player.visible = true
	player.rotation = Vector3.ZERO
	player.position = Vector3.ZERO
	player.scale = Vector3.ONE
	carrier.visible = true
	carrier.position = Vector3(-42,15,-100)
	for wing in wingmen:
		wing.hp = 100.0
		wing.node.visible = true
	world.setup(stage)
	waves = _build_waves(stage)
	wave_index = 0
	hud.show_briefing(STAGES[stage])
	overlay.visible = false
	audio.start_music(stage,false)

func _launch() -> void:
	mode = Mode.LAUNCH
	mode_time = 0.0
	player.position = Vector3(0,-2,18)
	hud.show_gameplay()
	overlay.visible = true
	hud.say("COMET", ["Comet Flight, launch. Let's open that corridor.","Stay close. The ice is playing tricks with our scanners.","One carrier. Three pilots. Let's make this count."][stage],5.0)
	audio.sfx("boost")

func _process(delta:float) -> void:
	var dt := minf(delta,0.05)
	clock += dt
	if qa_web:
		qa_clock -= dt
		if qa_clock <= 0.0:
			qa_clock = .1
			JavaScriptBridge.eval("window.__foxlikeQA="+JSON.stringify({"mode":Mode.keys()[mode],"paused":is_paused,"player_x":player.position.x,"player_y":player.position.y,"shots_fired":shots_fired,"flight_time":flight_time}))
	if is_paused: return
	mode_time += dt
	if mode in [Mode.MENU,Mode.BRIEFING]:
		_title_flight(dt)
		return
	if mode == Mode.RESULT or mode == Mode.DEAD:
		world.advance(dt,8.0,clock)
		return
	if mode == Mode.LAUNCH:
		player.position = player.position.lerp(Vector3(0,0,0),dt*1.8)
		world.advance(dt,60.0,clock)
		carrier.position.z += dt*28.0
		player.animate(clock,dt,0.0,-0.08,1.8)
		_update_wingmen(dt)
		_update_camera(dt)
		_update_hud(dt)
		if mode_time > 3.2:
			mode = Mode.FLIGHT
			mode_time = 0.0
			_radio("LATCH","WASD to fly. Space to fire. Q or E rolls incoming fire away.")
		return
	if mode == Mode.CLEAR:
		world.advance(dt,55.0,clock)
		player.position.y = lerpf(player.position.y,8.0,dt)
		player.animate(clock,dt,-0.18,-0.12,1.7)
		_update_wingmen(dt)
		_update_camera(dt)
		if mode_time > 4.0: _finish_stage()
		return
	flight_time += dt
	invulnerable = maxf(0.0,invulnerable-dt)
	shot_cooldown -= dt
	missile_cooldown -= dt
	roll_cooldown -= dt
	assist_cooldown -= dt
	combo_time -= dt
	if combo_time <= 0.0: combo = 0
	damage_flash = maxf(0.0,damage_flash-dt*2.0)
	camera_shake = maxf(0.0,camera_shake-dt*2.0)
	_update_player(dt)
	world.advance(dt,speed,flight_time)
	carrier.position.z += dt*speed
	carrier.visible = carrier.position.z < 80.0
	_update_wingmen(dt)
	_update_waves()
	_update_enemies(dt)
	_update_boss(dt)
	_update_lock(dt)
	_update_projectiles(dt)
	_update_hazards(dt)
	_update_camera(dt)
	_update_hud(dt)
	if mode == Mode.FLIGHT and flight_time >= float(STAGES[stage].duration):
		_spawn_boss()

func _title_flight(dt:float) -> void:
	world.advance(dt,18.0,clock)
	player.scale = Vector3.ONE*2.2
	player.position = Vector3(9+sin(clock*.35)*.8,3+sin(clock*.7)*.6,-1)
	player.rotation.y = -.55
	player.animate(clock,dt,sin(clock*.45)*.18,-.08,0.8)
	carrier.animate(clock,dt,0,0,0.8)
	for i in range(wingmen.size()):
		var wing: Node3D = wingmen[i].node
		wing.position = Vector3(15+i*7,5+i*2,-22-i*18)
		wing.animate(clock+float(i),dt,sin(clock*.4)*.15,0,0.7)
	camera.position = Vector3(0,5,24)
	camera.look_at(Vector3(0,1,-35))

func _update_player(dt:float) -> void:
	var axis := Input.get_vector("left","right","down","up")
	if axis.length() > .05: mouse_active = false
	var joy_ids := Input.get_connected_joypads()
	var pad := -1 if joy_ids.is_empty() else int(joy_ids[0])
	if pad >= 0:
		var stick := Vector2(Input.get_joy_axis(pad,JOY_AXIS_LEFT_X),-Input.get_joy_axis(pad,JOY_AXIS_LEFT_Y))
		if stick.length() > .16:
			axis = stick.limit_length()
			mouse_active = false
		_pad_button(pad,JOY_BUTTON_A,"roll")
		_pad_button(pad,JOY_BUTTON_X,"missile")
		_pad_button(pad,JOY_BUTTON_B,"bomb")
		_pad_button(pad,JOY_BUTTON_Y,"assist")
	var target_pos := Vector2(player.position.x,player.position.y)
	if mouse_active:
		var viewport_size := get_viewport().get_visible_rect().size
		var pointer := get_viewport().get_mouse_position()/viewport_size
		target_pos = Vector2((pointer.x-.5)*38.0,(.52-pointer.y)*25.0)
		axis = ((target_pos-Vector2(player.position.x,player.position.y))*.13).limit_length()
	var boost_held := Input.is_action_pressed("boost") or (pad >= 0 and Input.is_joy_button_pressed(pad,JOY_BUTTON_RIGHT_SHOULDER))
	if not boost_held: boost_depleted = false
	if energy <= 1.0: boost_depleted = true
	var boosting := boost_held and not boost_depleted and energy > 1.0
	var braking := Input.is_action_pressed("brake") or (pad >= 0 and Input.is_joy_button_pressed(pad,JOY_BUTTON_LEFT_SHOULDER))
	var target_speed := 76.0 if boosting else (24.0 if braking else 42.0)
	speed = lerpf(speed,target_speed,dt*4.0)
	energy = clampf(energy+dt*(-30.0 if boosting else 18.0),0.0,100.0)
	move_velocity = move_velocity.lerp(axis*(24.0 if braking else 30.0),1.0-exp(-dt*7.0))
	player.position.x = clampf(player.position.x+move_velocity.x*dt,-18.0,18.0)
	player.position.y = clampf(player.position.y+move_velocity.y*dt,-8.0,13.0)
	player.position.z = lerpf(player.position.z,-3.0 if boosting else (4.0 if braking else 0.0),dt*4.0)
	var roll_angle := 0.0
	if roll_time > 0.0:
		roll_time = maxf(0.0,roll_time-dt)
		var progress := 1.0-roll_time/.68
		roll_angle = roll_direction*TAU*smoothstep(0.0,1.0,progress)
		invulnerable = maxf(invulnerable,.08)
		if int(clock*70.0)%2 == 0: effects.trail(player.position+Vector3(roll_direction*2,0,2),Color("7dfdff"),.4)
	player.rotation.y = lerpf(player.rotation.y,-axis.x*.10,dt*6.0)
	player.animate(clock,dt,-axis.x*.62,-axis.y*.22,1.8 if boosting else (.5 if braking else 1.0),roll_angle,damage_flash)
	aim = Vector3(player.position.x*1.7,player.position.y*1.65,-100)
	var fire := Input.is_action_pressed("fire") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or (pad >= 0 and Input.get_joy_axis(pad,JOY_AXIS_TRIGGER_RIGHT) > .25)
	if fire and shot_cooldown <= 0.0:
		_fire_player()
	if boosting and int(clock*45)%3 == 0:
		effects.trail(player.position+Vector3(rng.randf_range(-2.0,2.0),0,3),Color("84dfff"),.18)

func _pad_button(pad:int,button:int,action_name:String) -> void:
	var held := Input.is_joy_button_pressed(pad,button)
	if held and not bool(gamepad_previous.get(button,false)):
		match action_name:
			"roll": _roll(1)
			"missile": _missile()
			"bomb": _bomb()
			"assist": _assist()
			"pause": _pause(true)
	gamepad_previous[button] = held

func _roll(direction:float) -> void:
	if roll_cooldown > 0.0 or roll_time > 0.0: return
	roll_direction = direction
	roll_time = .68
	roll_cooldown = 1.15
	audio.sfx("roll")
	effects.shockwave(player.position,Color("73efff"),3.0)

func _fire_player() -> void:
	shot_cooldown = .13 if laser_level == 1 else .10
	var target := aim
	var target_node := _nearest_target(10.0 if save_data.difficulty == "Cadet" else 7.0)
	if is_instance_valid(target_node): target = target_node.global_position
	for side in [-1.0,1.0]:
		var origin := player.position+Vector3(side*1.8,-.1,-2.5)
		_spawn_shot(origin,(target-origin).normalized()*210.0,true,1.0 if laser_level == 1 else 1.6)
	shots_fired += 2
	audio.sfx("laser")

func _nearest_target(tolerance:float) -> Node3D:
	var result: Node3D
	var best := tolerance
	var aim_direction := (aim-player.position).normalized()
	for enemy in enemies:
		if not is_instance_valid(enemy.node) or enemy.node.position.z > -6.0: continue
		var to_target: Vector3 = enemy.node.position-player.position
		var along := maxf(1.0,-to_target.z)
		var ideal: Vector3 = player.position+aim_direction*(along/-aim_direction.z)
		var distance: float = enemy.node.position.distance_to(ideal)
		if distance < best:
			best = distance
			result = enemy.node
	if is_instance_valid(boss) and mode == Mode.BOSS:
		for part in boss_parts:
			if part.hp <= 0.0 or not is_instance_valid(part.node): continue
			var p: Vector3 = part.node.global_position
			var ideal: Vector3 = player.position+aim_direction*((player.position.z-p.z)/-aim_direction.z)
			var distance: float = p.distance_to(ideal)
			if distance < best+3.0:
				best = distance
				result = part.node
		if not is_instance_valid(result):
			var ideal: Vector3 = player.position+aim_direction*((player.position.z-boss.position.z)/-aim_direction.z)
			if boss.position.distance_to(ideal)<tolerance+9: result = boss
	return result

func _update_lock(dt:float) -> void:
	var candidate := _nearest_target(10.0)
	if is_instance_valid(candidate) and candidate == lock_target:
		var previous := lock_progress
		lock_progress = minf(1.0,lock_progress+dt*1.25)
		if previous < 1.0 and lock_progress >= 1.0: audio.sfx("lock")
	else:
		lock_target = candidate
		lock_progress = 0.0

func _missile() -> void:
	if missile_cooldown > 0.0: return
	if not is_instance_valid(lock_target) or lock_progress < .95:
		hud.say("TARGETING","Hold the reticle over a target to lock. R / right click fires when locked.",2.5)
		return
	missile_cooldown = 2.5
	_spawn_shot(player.position+Vector3(0,-.6,-2),Vector3(0,0,-75),true,14.0,lock_target)
	audio.sfx("missile")
	lock_progress = 0.0

func _bomb() -> void:
	if bombs <= 0: return
	bombs -= 1
	audio.sfx("explosion")
	camera_shake = 1.0
	effects.shockwave(player.position+Vector3(0,0,-35),Color("fff1bb"),100.0)
	for enemy in enemies.duplicate(): _damage_enemy(enemy,20.0)
	if is_instance_valid(boss): _damage_boss(32.0,boss.position)
	for projectile in projectiles:
		if not projectile.friendly: projectile.life = 0.0
	for hazard in hazards: hazard.life = 0.0
	invulnerable = 1.4

func _assist() -> void:
	if assist_cooldown > 0.0: return
	var available := 0
	for wing in wingmen:
		if wing.hp > 0.0:
			available += 1
			wing.hp = minf(100.0,wing.hp+12.0)
	if available == 0: return
	assist_cooldown = 24.0
	hud.say("LATCH","Crossfire. We've got your six!",3.0)
	audio.sfx("missile")
	for enemy in enemies.duplicate(): _damage_enemy(enemy,float(available)*3.5)
	if is_instance_valid(boss): _damage_boss(float(available)*15.0,boss.position)
	for wing in wingmen:
		if wing.hp > 0.0: effects.shockwave(wing.node.position,Color("98ffcf"),6.0)

func _spawn_shot(origin:Vector3,velocity:Vector3,friendly:bool,damage:float=1.0,target:Node3D=null) -> void:
	if projectiles.size() >= 200: return
	var mesh := MeshInstance3D.new()
	mesh.mesh = shot_mesh
	mesh.material_override = missile_mat if is_instance_valid(target) else (shot_mat if friendly else enemy_shot_mat)
	mesh.position = origin
	mesh.rotation.x = PI/2.0
	if not friendly: mesh.scale = Vector3(1.8,.45,1.8)
	if is_instance_valid(target): mesh.scale = Vector3(2.2,1.5,2.2)
	actors.add_child(mesh)
	projectiles.append({"node":mesh,"velocity":velocity,"friendly":friendly,"damage":damage,"target":target,"life":4.0,"missile":is_instance_valid(target)})

func _update_projectiles(dt:float) -> void:
	for i in range(projectiles.size()-1,-1,-1):
		var bullet: Dictionary = projectiles[i]
		bullet.life -= dt
		var previous: Vector3 = bullet.node.position
		if bullet.missile and is_instance_valid(bullet.target):
			var desired: Vector3 = (bullet.target.global_position-previous).normalized()*145.0
			bullet.velocity = bullet.velocity.lerp(desired,minf(1.0,dt*5.0))
			effects.trail(previous,Color("ffc166"),.22)
		bullet.node.position += bullet.velocity*dt
		var pos: Vector3 = bullet.node.position
		if bullet.friendly:
			for enemy in enemies.duplicate():
				if not is_instance_valid(enemy.node): continue
				if _segment_distance(previous,pos,enemy.node.position) < float(enemy.radius):
					_damage_enemy(enemy,float(bullet.damage))
					bullet.life = -1.0
					hits += 1
					break
			if bullet.life > 0.0 and is_instance_valid(boss):
				var hit_boss := false
				for part in boss_parts:
					if part.hp <= 0.0 or not is_instance_valid(part.node): continue
					if _segment_distance(previous,pos,part.node.global_position)<4.0:
						part.hp -= float(bullet.damage)
						_damage_boss(float(bullet.damage)*1.5,part.node.global_position)
						if mode != Mode.BOSS: return
						if part.hp <= 0.0:
							effects.burst(part.node.global_position,Color("ffc870"),3.0)
							part.node.visible = false
							stage_score += 350
							_radio("GLINT","Weapon pod destroyed. Keep the pressure on!")
						hit_boss = true
						break
				if not hit_boss and _segment_distance(previous,pos,boss.position)<(8.0 if stage == 0 else 10.5):
					_damage_boss(float(bullet.damage),pos)
					if mode != Mode.BOSS: return
					hit_boss = true
				if hit_boss:
					bullet.life = -1.0
					hits += 1
		else:
			if _segment_distance(previous,pos,player.position)<1.45:
				if roll_time > 0.0:
					stage_score += 15
					effects.spark(pos,Color("77ffff"))
				else: _hurt(float(bullet.damage))
				bullet.life = -1.0
		if bullet.life <= 0.0 or absf(pos.z)>350.0:
			bullet.node.queue_free()
			projectiles.remove_at(i)

func _segment_distance(a:Vector3,b:Vector3,p:Vector3) -> float:
	return Geometry3D.get_closest_point_to_segment(p,a,b).distance_to(p)

func _build_waves(index:int) -> Array:
	var result: Array = []
	# Authored beats: establish, vary, recover, combine, then the boss.
	result.append({"t":3.0,"kind":"rings","pattern":0})
	result.append({"t":7.0,"kind":"fighter","count":3,"pattern":0})
	result.append({"t":14.0,"kind":"fighter","count":4,"pattern":1})
	result.append({"t":21.0,"kind":"hazard","count":3,"pattern":0})
	result.append({"t":24.0,"kind":"interceptor","count":4,"pattern":2})
	result.append({"t":31.0,"kind":"rings","pattern":1})
	result.append({"t":35.0,"kind":"bomber","count":2,"pattern":0})
	result.append({"t":41.0,"kind":"rescue","count":3,"pattern":2})
	result.append({"t":49.0,"kind":"hazard","count":5,"pattern":1})
	result.append({"t":52.0,"kind":"interceptor","count":5,"pattern":1})
	result.append({"t":59.0,"kind":"rings","pattern":2})
	result.append({"t":64.0,"kind":"bomber","count":3,"pattern":1})
	result.append({"t":71.0,"kind":"fighter","count":5,"pattern":2})
	result.append({"t":79.0,"kind":"rings","pattern":0})
	if index > 0:
		result.append({"t":82.0,"kind":"interceptor","count":5,"pattern":2})
	if index > 1:
		result.append({"t":89.0,"kind":"bomber","count":3,"pattern":0})
		result.append({"t":95.0,"kind":"rings","pattern":1})
	return result

func _update_waves() -> void:
	if mode != Mode.FLIGHT: return
	while wave_index < waves.size() and flight_time >= float(waves[wave_index].t):
		var wave: Dictionary = waves[wave_index]
		wave_index += 1
		match str(wave.kind):
			"rings":
				var center_x: float = [-9.0,10.0,0.0][int(wave.pattern)]
				for j in range(5):
					_spawn_pickup(Vector3(center_x+sin(float(j)*.8)*3.0,3.0+sin(float(j)*.7)*3.0,-150.0-float(j)*27.0),"ring")
				if int(wave.pattern) == 1: _radio("GLINT","Gold rings restore shields. Three will tune up your lasers.")
			"hazard":
				for j in range(int(wave.count)):
					var side := -1.0 if j%2 == 0 else 1.0
					_spawn_hazard(Vector3(side*(7.0+float(j%3)*3),float(j%3)*5-5.0,-155.0-float(j)*33.0),3.5+float(stage)*.5)
				_radio("GLINT",["Debris crossing the sea wall. Thread the gap.","Ice ahead. Brake if you need room.","Heavy wreckage in the approach lane."][stage])
			_:
				for j in range(int(wave.count)):
					_spawn_enemy("fighter" if wave.kind == "rescue" else str(wave.kind),j,int(wave.count),int(wave.pattern),wave.kind == "rescue")
				if wave.kind == "rescue": _radio("LATCH","They're on my tail! Clear these fighters before they pass us!")

func _spawn_enemy(kind:String,index:int,count:int,pattern:int,rescue:bool=false) -> Dictionary:
	var node: Node3D = Ship.new()
	actors.add_child(node)
	node.setup(kind,Color("ff7862") if kind != "bomber" else Color("d1a2ef"))
	var base_x: float = (float(index)-float(count-1)*.5)*7.2
	var base_y: float = 2.5+sin(float(index)*1.7)*5.5
	node.position = Vector3(base_x,base_y,-170-float(index)*12.0)
	var hp := 4.0 if kind == "fighter" else (3.0 if kind == "interceptor" else 12.0)
	if save_data.difficulty == "Cadet": hp *= .8
	var enemy := {"node":node,"kind":kind,"hp":hp,"age":0.0,"base_x":base_x,"base_y":base_y,"phase":float(index)*1.2,"pattern":pattern,"fire":3.0+float(index)*.48,"radius":3.0 if kind != "bomber" else 4.0,"rescue":rescue,"score":120 if kind == "fighter" else (180 if kind == "interceptor" else 300)}
	enemies.append(enemy)
	return enemy

func _update_enemies(dt:float) -> void:
	for enemy in enemies.duplicate():
		if not enemies.has(enemy): continue
		var node: Node3D = enemy.node
		enemy.age += dt
		enemy.fire -= dt
		var age: float = enemy.age
		var incoming_speed := speed*.66
		if age > 3.0 and age < 7.5: incoming_speed *= .18
		node.position.z += dt*incoming_speed
		var sway := 5.0 if enemy.kind == "interceptor" else 2.8
		if int(enemy.pattern) == 2: sway = 7.0
		node.position.x = clampf(float(enemy.base_x)+sin(age*1.4+float(enemy.phase))*sway,-24.0,24.0)
		node.position.y = float(enemy.base_y)+cos(age*1.3+float(enemy.phase))*2.7
		node.animate(clock+float(enemy.phase),dt,cos(age*1.4+float(enemy.phase))*.4,sin(age)*.1,1.0)
		if enemy.fire <= 0.0 and node.position.z < -12.0 and node.position.z > -145.0:
			enemy.fire = 2.2 if enemy.kind != "bomber" else 1.8
			var aim_pos: Vector3 = player.position+Vector3(move_velocity.x,move_velocity.y,0)*.12
			var velocity: Vector3 = (aim_pos-node.position).normalized()*(52.0+float(stage)*6.0)
			_spawn_shot(node.position,velocity,false,10.0 if enemy.kind != "bomber" else 15.0)
			if enemy.kind == "bomber":
				_spawn_shot(node.position+Vector3(2,0,0),(velocity+Vector3(6,0,0)),false,12.0)
				_spawn_shot(node.position+Vector3(-2,0,0),(velocity-Vector3(6,0,0)),false,12.0)
		if node.position.distance_to(player.position)<3.4:
			_hurt(24.0)
			_damage_enemy(enemy,99.0)
		elif node.position.z > 35.0:
			if bool(enemy.rescue):
				wingmen[0].hp = maxf(0.0,float(wingmen[0].hp)-18.0)
				if wingmen[0].hp == 0.0: _radio("LATCH","Taking too much damage. I'm pulling back.")
			node.queue_free()
			enemies.erase(enemy)

func _damage_enemy(enemy:Dictionary,amount:float) -> void:
	if not enemies.has(enemy) or not is_instance_valid(enemy.node): return
	enemy.hp -= amount
	enemy.node.hit_flash()
	effects.spark(enemy.node.position,Color("ffe6ad"))
	if enemy.hp <= 0.0:
		var pos: Vector3 = enemy.node.position
		effects.burst(pos,Color("ffad63"),1.5 if enemy.kind != "bomber" else 2.4)
		audio.sfx("explosion")
		combo += 1
		best_combo = maxi(best_combo,combo)
		combo_time = 4.2
		stage_score += int(enemy.score)*mini(4,1+int(combo/5))
		kills += 1
		if bool(enemy.rescue):
			stage_score += 100
			wingmen[0].hp = minf(100.0,float(wingmen[0].hp)+8.0)
		if kills%7 == 0: _spawn_pickup(pos,"repair")
		if kills%15 == 0: _spawn_pickup(pos+Vector3(0,3,-10),"bomb")
		enemy.node.queue_free()
		enemies.erase(enemy)

func _spawn_boss() -> void:
	mode = Mode.BOSS
	mode_time = 0.0
	boss = Ship.new()
	actors.add_child(boss)
	boss.setup("boss%d"%(stage+1),Color("d4a2df"))
	boss.position = Vector3(0,3,-185)
	boss.scale = Vector3.ONE*[2.2,2.4,3.0][stage]
	boss_max_hp = [180.0,240.0,310.0][stage]
	if save_data.difficulty == "Cadet": boss_max_hp *= .8
	boss_hp = boss_max_hp
	boss_fire = 3.0
	boss_parts.clear()
	for part in boss.weak_points:
		if part == boss.core: continue
		boss_parts.append({"node":part,"hp":28.0 if stage != 2 else 42.0})
	hud.say("WARNING",str(STAGES[stage].boss)+" detected. Target the glowing weapon pods.",5.0)
	audio.start_music(stage,true)
	audio.sfx("warning")

func _update_boss(dt:float) -> void:
	if mode != Mode.BOSS or not is_instance_valid(boss): return
	boss.position.z = lerpf(boss.position.z,-85.0 if stage<2 else -100.0,dt*.55)
	boss.position.x = sin(mode_time*.36)*(8.0 if stage == 0 else 11.0)
	boss.position.y = 3.0+sin(mode_time*.55)*4.0
	boss.animate(clock,dt,sin(mode_time*.4)*.08,0.0,1.0)
	boss_fire -= dt
	if boss_fire <= 0.0 and mode_time > 3.5:
		boss_attack += 1
		var live_parts := 0
		for part in boss_parts:
			if part.hp > 0.0: live_parts += 1
		boss_fire = 1.8+float(boss_parts.size()-live_parts)*.16
		if stage == 2 and boss_attack%4 == 0:
			_start_beam()
		elif stage == 1 and boss_attack%3 == 0:
			# A moving radial ring leaves readable gaps between bolts.
			for j in range(12):
				var angle := float(j)*TAU/12.0+float(boss_attack)*.2
				var destination := player.position+Vector3(cos(angle)*12,sin(angle)*9,0)
				_spawn_shot(boss.position,(destination-boss.position).normalized()*54.0,false,14.0)
		else:
			var destination := player.position+Vector3(move_velocity.x,move_velocity.y,0)*.2
			for j in range(-2,3):
				var muzzle: Vector3 = boss.position+Vector3(float(j)*3.0,0,3)
				var direction: Vector3 = (destination+Vector3(float(j)*3.5,0,0)-muzzle).normalized()
				_spawn_shot(muzzle,direction*60.0,false,13.0)
			for part in boss_parts:
				if part.hp>0.0:
					_spawn_shot(part.node.global_position,(player.position-part.node.global_position).normalized()*49.0,false,10.0)
		if stage == 2 and boss_attack%7 == 0:
			for j in range(2): _spawn_enemy("interceptor",j,2,2)
	if beam_time >= 0.0:
		beam_time += dt
		if is_instance_valid(beam_mesh):
			beam_mesh.position = Vector3(beam_x,2,-38)
			beam_mesh.scale.x = .12 if beam_time<1.6 else 2.8
			beam_mesh.visible = beam_time >= 1.6 or fmod(beam_time,.22)<.13
			if beam_time >= 1.6 and absf(player.position.x-beam_x)<3.2: _hurt(28.0)
		if beam_time > 2.2:
			beam_time = -1.0
			if is_instance_valid(beam_mesh): beam_mesh.queue_free()
			beam_mesh = null

func _start_beam() -> void:
	if is_instance_valid(beam_mesh): beam_mesh.queue_free()
	beam_x = player.position.x
	beam_time = 0.0
	beam_mesh = MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = Vector3(1.0,40.0,110.0)
	beam_mesh.mesh = shape
	var mat := _material(Color(1.0,.14,.08,.3),2.0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_mesh.material_override = mat
	actors.add_child(beam_mesh)
	hud.say("GLINT","Lance charging! Move sideways out of the red lane!",2.6)
	audio.sfx("warning")

func _damage_boss(amount:float,where:Vector3) -> void:
	if not is_instance_valid(boss) or mode != Mode.BOSS: return
	boss_hp -= amount
	boss.hit_flash()
	effects.spark(where,Color("ffcf8a"))
	if boss_hp <= 0.0:
		boss_hp = 0.0
		stage_score += 3000+stage*1500
		for j in range(12):
			effects.burst(boss.position+Vector3(rng.randf_range(-14,14),rng.randf_range(-8,8),rng.randf_range(-7,7)),Color("ffc98a"),3.5)
		effects.shockwave(boss.position,Color("fef1c9"),80)
		audio.sfx("explosion")
		camera_shake = 1.5
		boss.queue_free()
		boss = null
		boss_parts.clear()
		_clear_actors()
		mode = Mode.CLEAR
		mode_time = 0.0
		hud.say("COMET",["Blockade broken. The corridor is yours. Bring them home.","Relay is down. I've got the carrier's coordinates.","Sovereign is gone. Asterion, your sky is clear."][stage],5.0)
		audio.sfx("victory")

func _spawn_hazard(pos:Vector3,radius:float) -> void:
	var mesh := MeshInstance3D.new()
	var shape := SphereMesh.new()
	shape.radius = radius
	shape.height = radius*1.7
	shape.radial_segments = 7
	shape.rings = 3
	mesh.mesh = shape
	mesh.material_override = _material([Color("907960"),Color("91dbe4"),Color("685f7d")][stage])
	mesh.position = pos
	mesh.rotation = Vector3(rng.randf(),rng.randf(),rng.randf())
	actors.add_child(mesh)
	hazards.append({"node":mesh,"radius":radius,"life":30.0})

func _spawn_pickup(pos:Vector3,kind:String) -> void:
	var root := Node3D.new()
	root.position = pos
	actors.add_child(root)
	var mesh := MeshInstance3D.new()
	var ring := TorusMesh.new()
	ring.inner_radius = 2.1
	ring.outer_radius = 2.65
	ring.rings = 16
	ring.ring_segments = 6
	mesh.mesh = ring
	mesh.rotation.x = PI/2
	mesh.material_override = _material(Color("ffe6a3") if kind == "ring" else (Color("81ffd3") if kind == "repair" else Color("ff9b85")),2.0)
	root.add_child(mesh)
	if kind != "ring":
		var marker := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(.45,2.3,.45)
		marker.mesh = box
		marker.material_override = mesh.material_override
		root.add_child(marker)
		var bar := MeshInstance3D.new()
		bar.mesh = box
		bar.rotation.z = PI/2
		bar.material_override = mesh.material_override
		root.add_child(bar)
	pickups.append({"node":root,"kind":kind})

func _update_hazards(dt:float) -> void:
	for i in range(hazards.size()-1,-1,-1):
		var hazard: Dictionary = hazards[i]
		hazard.node.position.z += speed*dt
		hazard.node.rotation += Vector3(.13,.22,.08)*dt
		hazard.life -= dt
		if hazard.node.position.distance_to(player.position)<float(hazard.radius)+1.0:
			_hurt(22.0)
			effects.burst(hazard.node.position,Color("b9dce4"),2.0)
			hazard.life = 0.0
		if hazard.node.position.z > 35 or hazard.life <= 0.0:
			hazard.node.queue_free()
			hazards.remove_at(i)
	for i in range(pickups.size()-1,-1,-1):
		var pickup: Dictionary = pickups[i]
		var previous: Vector3 = pickup.node.position
		pickup.node.position.z += speed*dt
		pickup.node.rotation.z += dt*.4
		var collected := _segment_distance(previous,pickup.node.position,player.position)<3.2
		if collected:
			audio.sfx("pickup")
			effects.shockwave(player.position,Color("ffedab"),4.0)
			stage_score += 100
			match str(pickup.kind):
				"ring":
					rings += 1
					shield = minf(100.0,shield+7.0)
					if rings%3 == 0:
						laser_level = 2
						stage_score += 300
						hud.say("SYSTEM","Twin lasers upgraded. Shields reinforced.",2.5)
						shield = minf(100.0,shield+12.0)
				"repair": shield = minf(100.0,shield+25.0)
				"bomb": bombs = mini(5,bombs+1)
		if collected or pickup.node.position.z>35.0:
			pickup.node.queue_free()
			pickups.remove_at(i)

func _hurt(amount:float) -> void:
	if invulnerable>0.0 or not mode in [Mode.FLIGHT,Mode.BOSS]: return
	var multiplier := .65 if save_data.difficulty == "Cadet" else (1.4 if save_data.difficulty == "Ace" else 1.0)
	shield = maxf(0.0,shield-amount*multiplier)
	invulnerable = .7
	damage_flash = .65
	camera_shake = .5
	combo = 0
	player.hit_flash()
	audio.sfx("hit")
	if shield>0.0 and shield<25.0: hud.say("WARNING","Shields critical. Gold rings repair hull. Roll through incoming fire.",3.0)
	if shield <= 0.0:
		effects.burst(player.position,Color("ffad75"),4)
		audio.sfx("death")
		player.visible = false
		mode = Mode.DEAD
		mode_time = 0.0
		overlay.visible = false
		hud.show_result({"success":false,"final":false,"score":stage_score,"kills":kills,"rank":"—","stage_name":STAGES[stage].title,"bonus":0})

func _update_wingmen(dt:float) -> void:
	wing_fire -= dt
	for i in range(wingmen.size()):
		var wing: Dictionary = wingmen[i]
		var node: Node3D = wing.node
		node.visible = wing.hp>0.0
		var side := -1.0 if i==0 else 1.0
		var target := player.position+Vector3(side*9,3.0+sin(clock*.85+i)*.8,-9.0-float(i)*3)
		if assist_cooldown > 20.0: target += Vector3(side*4,4,-25)
		node.position = node.position.lerp(target,1.0-exp(-dt*2.3))
		node.animate(clock+float(i),dt,-move_velocity.x*.012+sin(clock)*.06,0.0,1.0)
		if wing_fire<=0.0 and node.visible and mode in [Mode.FLIGHT,Mode.BOSS] and not enemies.is_empty():
			var enemy: Dictionary = enemies[0]
			_spawn_shot(node.position,(enemy.node.position-node.position).normalized()*150,true,.35)
	if wing_fire<=0.0: wing_fire = 1.2

func _update_camera(dt:float) -> void:
	var base := Vector3(player.position.x*.20,5.0+player.position.y*.18,25.0)
	camera.position = camera.position.lerp(base,1.0-exp(-dt*4.0))
	if camera_shake>0.0:
		camera.position += Vector3(rng.randf_range(-1,1),rng.randf_range(-1,1),0)*camera_shake*.28
	camera.look_at(Vector3(player.position.x*.34,2.0+player.position.y*.30,-55))
	camera.fov = lerpf(camera.fov,67.0+(speed-42.0)*.19,dt*3.0)

func _update_hud(dt:float) -> void:
	var nodes: Array = []
	for enemy in enemies: nodes.append(enemy.node)
	if is_instance_valid(boss): nodes.append(boss)
	overlay.set_targets(camera,aim,nodes,lock_target,lock_progress,damage_flash,roll_time/.68)
	ui_timer -= dt
	if ui_timer>0.0: return
	ui_timer = .05
	var objective: String = STAGES[stage].objective
	if mode == Mode.BOSS: objective = "Target the glowing pods · R lock missile · B nova"
	elif flight_time<14.0: objective = "WASD / arrows fly · SPACE fire · Q / E barrel roll"
	elif assist_cooldown<=0.0: objective += "  /  F: wingman strike ready"
	hud.update_hud({"shield":shield,"energy":energy,"bombs":bombs,"score":stage_score+campaign_score,"combo":combo,"stage_name":STAGES[stage].title,"progress":minf(1.0,flight_time/float(STAGES[stage].duration)),"speed":speed,"boss_name":STAGES[stage].boss if mode == Mode.BOSS else "","boss_hp":boss_hp/boss_max_hp if mode == Mode.BOSS else -1.0,"lock":lock_progress,"objective":objective,"roll_ready":roll_cooldown<=0.0,"wingmen":wingmen})

func _finish_stage() -> void:
	var bonus := int(shield)*20+rings*100
	for wing in wingmen:
		if wing.hp>0.0: bonus += 700
	stage_score += bonus
	campaign_score += stage_score
	var rank := "S" if kills>=28 and shield>=60 else ("A" if kills>=20 else ("B" if kills>=10 else "C"))
	save_data.unlocked = maxi(int(save_data.unlocked),mini(3,stage+2))
	save_data.best = maxi(int(save_data.best),campaign_score)
	var record_key := "%d_%s"%[stage,str(save_data.difficulty)]
	save_data.records[record_key] = maxi(int(save_data.records.get(record_key,0)),stage_score)
	_write_save()
	mode = Mode.RESULT
	mode_time = 0.0
	overlay.visible = false
	hud.show_result({"success":true,"final":stage==2,"score":stage_score,"kills":kills,"rank":rank,"stage_name":STAGES[stage].title,"bonus":bonus})

func _radio(speaker:String,message:String) -> void:
	if chatter: hud.say(speaker,message,4.2)

func _read_save() -> void:
	if not FileAccess.file_exists(save_path): return
	var file := FileAccess.open(save_path,FileAccess.READ)
	if file == null: return
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK: return
	var parsed: Variant = parser.data
	if not parsed is Dictionary: return
	if parsed.get("unlocked") is float or parsed.get("unlocked") is int:
		save_data.unlocked = clampi(int(parsed.unlocked),1,3)
	if parsed.get("best") is float or parsed.get("best") is int:
		save_data.best = clampi(int(parsed.best),0,999999999)
	if parsed.get("muted") is bool: save_data.muted = parsed.muted
	if parsed.get("difficulty") in ["Cadet","Standard","Ace"]: save_data.difficulty = parsed.difficulty
	if parsed.get("records") is Dictionary:
		for key in parsed.records:
			if parsed.records[key] is float or parsed.records[key] is int:
				save_data.records[str(key)] = clampi(int(parsed.records[key]),0,999999999)

func _write_save() -> void:
	var file := FileAccess.open(save_path,FileAccess.WRITE)
	if file != null: file.store_string(JSON.stringify(save_data,"\t"))
