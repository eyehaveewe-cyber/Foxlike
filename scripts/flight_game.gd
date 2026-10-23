extends Node3D
## Foxlike's flight simulation. Forward is -Z; scenery advances toward the camera.
## Visual rigs never own gameplay position or damage.
const Ship = preload("res://scripts/ship_model.gd")
const World = preload("res://scripts/flight_world.gd")
const Hud = preload("res://scripts/flight_hud.gd")
const Sound = preload("res://scripts/flight_audio.gd")
const Effects = preload("res://scripts/flight_effects.gd")
const Overlay = preload("res://scripts/flight_overlay.gd")
const Squadron = preload("res://scripts/flight_squadron.gd")
const Maneuver = preload("res://scripts/flight_maneuver.gd")
const SAVE_PATH := "user://foxlike_save.json"
var save_path := SAVE_PATH
const Campaign = preload("res://scripts/flight_campaign.gd")
const STAGES = Campaign.STAGES
const Arena = preload("res://scripts/flight_arena.gd")
const Tank = preload("res://scripts/flight_tank.gd")
const ArenaCarrier = preload("res://scripts/arena_carrier.gd")
enum Mode {MENU, BRIEFING, LAUNCH, FLIGHT, BOSS, CLEAR, RESULT, DEAD}
var arena := Arena.new()
var tank := Tank.new()
var defense_carrier: Node3D
var carrier_hp := 100.0
var carrier_fire := 0.0
var carrier_world := Vector3(0,8,0)
var arena_boss_world := Vector3.ZERO
var ground_barriers: Array = []
var tank_aim_y := 0.0
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
const MAX_MISSILES := 8
var missiles := 6
var missile_cooldown := 0.0
var pickup_notice := ""
var pickup_notice_time := 0.0
var pickup_player_previous := Vector3.ZERO
var pickup_sweep_initialized := false
var roll_time := 0.0
var roll_cooldown := 0.0
var roll_direction := 1.0
var maneuver := Maneuver.new()
var maneuver_cooldown := 0.0
var maneuver_input_previous: int = Maneuver.Kind.NONE
var boss_fire := 0.0
var boss_attack := 0
var boss_hp := 0.0
var boss_max_hp := 1.0
var boss_parts: Array = []
var boss_warning := 0.0
var boss_telegraph := ""
var boss_volley_target := Vector3.ZERO
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
var save_data: Dictionary = {"unlocked":1,"best":0,"muted":false,"difficulty":"Standard","records":{},"companions":["latch","glint"],"formation":0,"completed_stages":[]}
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
		wingmen.append({"node":wing})
	_configure_wingmen()
	defense_carrier = ArenaCarrier.new()
	actors.add_child(defense_carrier)
	defense_carrier.setup()
	defense_carrier.visible = false
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
	var keys: Dictionary = {"left":[KEY_A,KEY_LEFT],"right":[KEY_D,KEY_RIGHT],"up":[KEY_W,KEY_UP],"down":[KEY_S,KEY_DOWN],"fire":[KEY_SPACE],"boost":[KEY_SHIFT],"brake":[KEY_CTRL],"roll_left":[KEY_Q],"roll_right":[KEY_E],"missile":[KEY_R],"bomb":[KEY_B],"assist":[KEY_F],"formation":[KEY_TAB],"pause":[KEY_ESCAPE],"mute":[KEY_M],"chatter":[KEY_C],"fullscreen":[KEY_F11]}
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
	if event.is_action_pressed("formation"):
		_cycle_formation()
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
			_begin_stage(clampi(int(save_data.unlocked)-1,0,STAGES.size()-1))
		"stage":
			campaign_score = 0
			_begin_stage(clampi(int(value),0,int(save_data.unlocked)-1))
		"launch": _launch()
		"next":
			if stage < STAGES.size()-1: _begin_stage(stage+1)
			else: _show_menu()
		"retry": _begin_stage(stage)
		"menu": _show_menu()
		"resume": _pause(false)
		"mute": _toggle_mute()
		"difficulty":
			save_data.difficulty = str(value)
			_write_save()
		"equip_companion":
			if mode == Mode.MENU and value is Dictionary:
				_equip_companion(int(value.get("slot",-1)),str(value.get("id","")))
		"formation":
			if mode == Mode.MENU: _cycle_formation()
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
	for barrier in ground_barriers:
		if is_instance_valid(barrier.node): barrier.node.queue_free()
	ground_barriers.clear()
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
	defense_carrier.visible = false
	player.setup("player",Color("cfe8f4"))
	_reset_maneuver()
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
	stage = clampi(index,0,STAGES.size()-1)
	arena.reset()
	tank.reset()
	tank_aim_y = 0.0
	carrier_hp = 100.0
	carrier_fire = 2.0
	defense_carrier.visible = stage==4
	defense_carrier.set_damage(1.0)
	player.setup("tank" if stage==3 else "player",Color("cfe8f4"))
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
	missiles = 6
	pickup_notice = ""
	pickup_notice_time = 0.0
	pickup_sweep_initialized = false
	rings = 0
	laser_level = 1
	roll_time = 0.0
	roll_cooldown = 0.0
	_reset_maneuver()
	maneuver_cooldown = 0.0
	maneuver_input_previous = Maneuver.Kind.NONE
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
	_configure_wingmen()
	world.setup(stage)
	waves = _build_waves(stage)
	wave_index = 0
	hud.show_briefing(STAGES[stage])
	overlay.visible = false
	audio.start_music(stage,false)

func _launch() -> void:
	player.scale = Vector3.ONE
	player.rotation = Vector3.ZERO
	aim = Vector3(0,0,-100)
	mode = Mode.LAUNCH
	mode_time = 0.0
	player.position = Vector3(0,-2,18)
	if stage==3: player.position = Vector3(0,Tank.GROUND_Y,0)
	if stage==4:
		player.position = Arena.ANCHOR
		_sync_arena_view()
	hud.show_gameplay()
	overlay.visible = true
	hud.say("COMET", ["Comet Flight, launch. Let's open that corridor.","Stay close. The ice is playing tricks with our scanners.","One carrier. Three pilots. Let's make this count.","Jackal deployed. Hold Shift to hover over the barriers.","Dragonfly is under attack. Turn with A/D and intercept those bombers!","Storm ahead. Stay in the clear lanes and find the Crown."][stage],5.0)
	audio.sfx("boost")

func _process(delta:float) -> void:
	var dt := minf(delta,0.05)
	clock += dt
	if qa_web:
		qa_clock -= dt
		if qa_clock <= 0.0:
			qa_clock = .1
			JavaScriptBridge.eval("window.__foxlikeQA="+JSON.stringify({"mode":Mode.keys()[mode],"paused":is_paused,"player_x":player.position.x,"player_y":player.position.y,"shots_fired":shots_fired,"flight_time":flight_time,"maneuver":maneuver.label(),"player_z":player.position.z}))
	if is_paused: return
	mode_time += dt
	if mode in [Mode.MENU,Mode.BRIEFING]:
		_title_flight(dt)
		return
	if mode == Mode.RESULT or mode == Mode.DEAD:
		world.advance(dt,8.0,clock)
		return
	if mode == Mode.LAUNCH:
		if stage==3: player.position = Vector3(0,Tank.GROUND_Y,0)
		elif stage==4:
			player.position = Arena.ANCHOR
			_sync_arena_view()
		else: player.position = player.position.lerp(Vector3(0,0,0),dt*1.8)
		world.advance(dt,60.0,clock)
		carrier.position.z += dt*28.0
		player.animate(clock,dt,0.0,-0.08,1.8)
		_update_wingmen(dt)
		_update_camera(dt)
		_update_hud(dt)
		if mode_time > 3.2:
			mode = Mode.FLIGHT
			mode_time = 0.0
			_radio("LATCH","Hold Shift / RB to hover; release to land and recharge. Clear the striped barriers." if stage==3 else ("A/D turn around the arena. Red radar contacts attack Dragonfly. Defend its hull!" if stage==4 else "WASD to fly. Space to fire. Q or E rolls incoming fire away."))
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
	maneuver_cooldown = maxf(0.0,maneuver_cooldown-dt)
	combo_time -= dt
	if combo_time <= 0.0: combo = 0
	damage_flash = maxf(0.0,damage_flash-dt*2.0)
	camera_shake = maxf(0.0,camera_shake-dt*2.0)
	_update_player(dt)
	world.advance(dt,speed,flight_time)
	carrier.position.z += dt*speed
	carrier.visible = stage!=4 and carrier.position.z < 80.0
	_update_wingmen(dt)
	_update_waves()
	if stage==4:
		_update_arena_enemies(dt)
		_sync_arena_boss()
	else: _update_enemies(dt)
	_update_boss(dt)
	_update_lock(dt)
	_update_projectiles(dt)
	if not mode in [Mode.FLIGHT,Mode.BOSS]: return
	_update_hazards(dt)
	if stage==3: _update_ground_barriers(dt)
	if stage==4: _update_carrier_defense(dt)
	if not mode in [Mode.FLIGHT,Mode.BOSS]: return
	_update_camera(dt)
	_update_hud(dt)
	if mode == Mode.FLIGHT and flight_time >= float(STAGES[stage].duration):
		_spawn_boss()
		if stage==4: _sync_arena_boss()

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
		_pad_button(pad,JOY_BUTTON_DPAD_UP,"formation")
	var boost_held := Input.is_action_pressed("boost") or (pad >= 0 and Input.is_joy_button_pressed(pad,JOY_BUTTON_RIGHT_SHOULDER))
	if stage==3:
		_update_tank_player(dt,axis,boost_held,pad)
		return
	if stage==4:
		_update_arena_player(dt,axis,boost_held,pad)
		return
	_check_maneuver_input(axis,boost_held)
	var target_pos := Vector2(player.position.x,player.position.y)
	if mouse_active:
		var viewport_size := get_viewport().get_visible_rect().size
		var pointer := get_viewport().get_mouse_position()/viewport_size
		target_pos = Vector2((pointer.x-.5)*38.0,(.52-pointer.y)*25.0)
		axis = ((target_pos-Vector2(player.position.x,player.position.y))*.13).limit_length()
	if not boost_held: boost_depleted = false
	if energy <= 1.0: boost_depleted = true
	var boosting := boost_held and not boost_depleted and energy > 1.0
	var braking := Input.is_action_pressed("brake") or (pad >= 0 and Input.is_joy_button_pressed(pad,JOY_BUTTON_LEFT_SHOULDER))
	var was_maneuvering := maneuver.active()
	var maneuver_pitch := 0.0
	var roll_angle := 0.0
	var thrust := 1.8 if boosting else (.5 if braking else 1.0)
	if was_maneuvering:
		maneuver.advance(dt)
		player.position = maneuver.position
		move_velocity = Vector2.ZERO
		mouse_active = false
		axis = Vector2.ZERO
		player.rotation.y = lerpf(player.rotation.y,0.0,1.0-exp(-dt*12.0))
		maneuver_pitch = maneuver.pitch
		roll_angle = maneuver.roll
		thrust = maneuver.thrust
		speed = maneuver.speed
		boost_depleted = true # Release boost after the maneuver to rearm normal boost.
		boosting = false
		if maneuver.recovering: energy = minf(100.0,energy+18.0*dt)
		if int(clock*45)%2 == 0:
			for side in [-1.0,1.0]:
				effects.trail(player.position+Vector3(side*2.0,0,3),Color("d3a3ff"),.5)
	else:
		var target_speed := 76.0 if boosting else (24.0 if braking else 42.0)
		speed = lerpf(speed,target_speed,1.0-exp(-dt*4.0))
		energy = clampf(energy+dt*(-30.0 if boosting else 18.0),0.0,100.0)
		move_velocity = move_velocity.lerp(axis*(24.0 if braking else 30.0),1.0-exp(-dt*7.0))
		player.position.x = clampf(player.position.x+move_velocity.x*dt,-18.0,18.0)
		player.position.y = clampf(player.position.y+move_velocity.y*dt,-8.0,13.0)
		player.position.z = lerpf(player.position.z,-3.0 if boosting else (4.0 if braking else 0.0),1.0-exp(-dt*4.0))
		if roll_time > 0.0:
			roll_time = maxf(0.0,roll_time-dt)
			var progress := 1.0-roll_time/.68
			roll_angle = roll_direction*TAU*smoothstep(0.0,1.0,progress)
			invulnerable = maxf(invulnerable,.08)
			if int(clock*70.0)%2 == 0: effects.trail(player.position+Vector3(roll_direction*2,0,2),Color("7dfdff"),.4)
		player.rotation.y = lerpf(player.rotation.y,-axis.x*.10,1.0-exp(-dt*6.0))
	player.animate(clock,dt,-axis.x*.62,-axis.y*.22,thrust,roll_angle,damage_flash,maneuver_pitch)
	aim = Vector3(player.position.x*1.7,player.position.y*1.65,-100)
	var fire := Input.is_action_pressed("fire") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or (pad >= 0 and Input.get_joy_axis(pad,JOY_AXIS_TRIGGER_RIGHT) > .25)
	if fire and shot_cooldown <= 0.0 and maneuver.can_fire:
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
			"formation": _cycle_formation()
			"pause": _pause(true)
	gamepad_previous[button] = held

func _check_maneuver_input(axis: Vector2, boost_held: bool) -> void:
	var requested: int = Maneuver.Kind.NONE
	# Down wins diagonal chords. Mouse steering never enters this detector.
	if axis.y < -0.65: requested = Maneuver.Kind.LONG_LOOP
	elif axis.x < -0.65: requested = Maneuver.Kind.SOMERSAULT
	elif axis.x > 0.65: requested = Maneuver.Kind.CORKSCREW
	if boost_held and requested != Maneuver.Kind.NONE and requested != maneuver_input_previous:
		_start_maneuver(requested)
	maneuver_input_previous = requested

func _start_maneuver(kind: Maneuver.Kind) -> void:
	if stage in [3,4]: return
	if is_paused or not mode in [Mode.FLIGHT,Mode.BOSS]: return
	if maneuver.active() or roll_time > 0.0 or maneuver_cooldown > 0.0: return
	if kind == Maneuver.Kind.NONE or energy < Maneuver.ENERGY_COST: return
	energy -= Maneuver.ENERGY_COST
	maneuver_cooldown = Maneuver.COOLDOWN
	maneuver.start(kind,player.position)
	move_velocity = Vector2.ZERO
	lock_progress = 0.0
	lock_target = null
	audio.sfx("boost")
	hud.say("FLIGHT",maneuver.label(),1.8)

func _reset_maneuver() -> void:
	if maneuver.active():
		# Carry the current X/Y into results/clear; unwind forward excursion and pose.
		player.position.z = 0.0
		player.visual.rotation = Vector3.ZERO
	maneuver.reset()

func _roll(direction:float) -> void:
	if stage==3 or (stage==4 and arena.turning): return
	if maneuver.active(): return
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
	if aim_direction.z >= -.001: return null
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
			if p.z >= player.position.z-3.0: continue
			var ideal: Vector3 = player.position+aim_direction*((player.position.z-p.z)/-aim_direction.z)
			var distance: float = p.distance_to(ideal)
			if distance < best+3.0:
				best = distance
				result = part.node
		if not is_instance_valid(result):
			var core_target: Node3D = boss.core if is_instance_valid(boss.core) else boss
			var core_position: Vector3 = core_target.global_position
			if core_position.z < player.position.z-3.0:
				var ideal: Vector3 = player.position+aim_direction*((player.position.z-core_position.z)/-aim_direction.z)
				if core_position.distance_to(ideal)<tolerance+5: result = core_target
	return result

func _update_lock(dt:float) -> void:
	if stage==4 and arena.turning:
		lock_target = null
		lock_progress = 0.0
		return
	if not maneuver.can_fire:
		lock_target = null
		lock_progress = 0.0
		return
	var candidate := _nearest_target(10.0)
	if is_instance_valid(candidate) and candidate == lock_target:
		var previous := lock_progress
		lock_progress = minf(1.0,lock_progress+dt*1.25)
		if previous < 1.0 and lock_progress >= 1.0: audio.sfx("lock")
	else:
		lock_target = candidate
		lock_progress = 0.0

func _missile() -> void:
	if stage==4 and arena.turning: return
	if not maneuver.can_fire or missile_cooldown > 0.0: return
	if missiles <= 0:
		hud.say("TARGETING","Missiles empty. Collect a cyan ammo crate or a green repair supply.",2.5)
		return
	if not is_instance_valid(lock_target) or lock_progress < .95:
		hud.say("TARGETING","Hold the reticle over a target to lock. R / right click fires when locked.",2.5)
		return
	if projectiles.size() >= 200: return
	missiles -= 1
	missile_cooldown = 2.5
	_spawn_shot(player.position+Vector3(0,-.6,-2),Vector3(0,0,-75),true,26.0,lock_target)
	projectiles.back()["player_missile"] = true
	audio.sfx("missile")
	lock_progress = 0.0

func _detonate_player_missile(point: Vector3) -> void:
	# The right-click attack is a limited, visible 18-unit blast, about half the
	# normal steering width. Sweep collision chooses the actual impact point.
	effects.shockwave(point,Color("ffce7e"),18.0)
	effects.burst(point,Color("ffd98d"),3.0)
	audio.sfx("explosion")
	for enemy in enemies.duplicate():
		if is_instance_valid(enemy.node) and enemy.node.position.distance_to(point) <= 18.0+float(enemy.radius):
			_damage_enemy(enemy,26.0)
	for shot in projectiles:
		if not shot.friendly and shot.node.position.distance_to(point) <= 18.0: shot.life = -1.0
	if is_instance_valid(boss):
		for part in boss_parts:
			if float(part.hp)>0.0 and part.node.global_position.distance_to(point)<=18.0:
				_damage_boss_part(part,26.0)
		var core_position: Vector3 = boss.core.global_position if is_instance_valid(boss.core) else boss.position
		if core_position.distance_to(point)<18.0 or boss.position.distance_to(point)<22.0:
			_damage_boss(26.0,point)

func _bomb() -> void:
	if bombs <= 0: return
	bombs -= 1
	audio.sfx("explosion")
	camera_shake = 1.0
	effects.shockwave(player.position+Vector3(0,0,-35),Color("fff1bb"),100.0)
	for enemy in enemies.duplicate(): _damage_enemy(enemy,20.0)
	if is_instance_valid(boss):
		for part in boss_parts: _damage_boss_part(part,18.0)
		_damage_boss(32.0,boss.position)
	for projectile in projectiles:
		if not projectile.friendly: projectile.life = 0.0
	for hazard in hazards: hazard.life = 0.0
	invulnerable = 1.4

func _configure_wingmen() -> void:
	Squadron.normalize(save_data)
	for slot in range(wingmen.size()):
		var wing: Dictionary = wingmen[slot]
		var pilot := Squadron.profile(str(save_data.companions[slot]))
		wing.merge({"id":pilot.id,"callsign":pilot.name,"hp":pilot.hp,"max_hp":pilot.hp,"level":1,"fire":0.0,"cooldown":0.0,"guard_time":0.0,"burst":0,"burst_timer":0.0,"guard_point":Vector3.ZERO},true)
		wing.node.setup("wingman",Color(str(pilot.color)))
		wing.node.visible = true

func _equip_companion(slot: int, id: String) -> void:
	if slot < 0 or slot > 1 or not Squadron.available(id,save_data): return
	var other := 1-slot
	if save_data.companions[other] == id:
		save_data.companions[other] = save_data.companions[slot]
	save_data.companions[slot] = id
	_configure_wingmen()
	_write_save()
	hud.show_menu(save_data)

func _cycle_formation() -> void:
	save_data.formation = (int(save_data.formation)+1)%Squadron.FORMATIONS.size()
	_write_save()
	if mode == Mode.MENU: hud.show_menu(save_data)
	else: hud.say("FORMATION",Squadron.FORMATIONS[int(save_data.formation)],2.0)

func _companion_target(origin: Vector3) -> Node3D:
	var target: Node3D
	var nearest := 180.0
	for enemy in enemies:
		var node: Node3D = enemy.node
		var distance := origin.distance_to(node.position)
		if node.position.z < origin.z-3.0 and distance < nearest:
			target = node
			nearest = distance
	if target == null and is_instance_valid(boss):
		for part in boss_parts:
			if float(part.hp)<=0.0 or part.node.global_position.z>=origin.z-3.0: continue
			var distance: float = origin.distance_to(part.node.global_position)
			if distance<nearest:
				target = part.node
				nearest = distance
		if target==null:
			var core: Node3D = boss.core if is_instance_valid(boss.core) else boss
			if core.global_position.z<origin.z-3.0 and origin.distance_to(core.global_position)<200.0: target = core
	return target

func _companion_ability(wing: Dictionary, target: Node3D) -> bool:
	if float(wing.hp)<=0.0 or float(wing.cooldown)>0.0: return false
	var pilot := Squadron.profile(str(wing.id))
	var damage_scale := 1.0+0.4*float(int(wing.level)-1)
	match str(pilot.ability):
		"guard":
			wing.guard_time = 1.2
			wing.guard_point = player.position+Vector3(0,0,-5.5)
		"burst":
			if not is_instance_valid(target): return false
			wing.burst = 6+2*(int(wing.level)-1)
			wing.burst_timer = 0.0
		"missile", "nova":
			if not is_instance_valid(target) or projectiles.size()>=200: return false
			var nova := str(pilot.ability)=="nova"
			_spawn_shot(wing.node.position,(target.global_position-wing.node.position).normalized()*90.0,true,(12.0 if nova else 9.0)*damage_scale,target)
			projectiles.back()["nova"] = nova
			if nova:
				projectiles.back().node.scale = Vector3(4,3,4)
				projectiles.back().node.material_override = _material(Color("ff97b3"),3.0)
			audio.sfx("missile")
	wing.cooldown = Squadron.ability_cooldown(wing)
	return true

func _assist() -> void:
	var used: Array[String] = []
	for wing in wingmen:
		if _companion_ability(wing,_companion_target(wing.node.position)): used.append(str(wing.callsign))
	if not used.is_empty(): hud.say("SQUADRON"," / ".join(used)+": ability deployed.",2.4)

func _hurt_wing(wing: Dictionary, amount: float) -> void:
	if float(wing.hp)<=0.0: return
	wing.hp = maxf(0.0,float(wing.hp)-amount)
	wing.node.hit_flash()
	effects.spark(wing.node.position,Color("8fffe4"))
	if float(wing.hp)<=0.0:
		wing.node.visible = false
		wing.burst = 0
		wing.guard_time = 0.0
		_radio(str(wing.callsign),"Shields gone. Returning to the carrier!")

func _detonate_companion_nova(point: Vector3, damage: float) -> void:
	effects.shockwave(point,Color("ff9ec5"),24.0)
	effects.burst(point,Color("ffacb5"),2.5)
	audio.sfx("explosion")
	for enemy in enemies.duplicate():
		if enemy.node.position.distance_to(point)<24.0: _damage_enemy(enemy,damage)
	for shot in projectiles:
		if not shot.friendly and shot.node.position.distance_to(point)<24.0: shot.life = -1.0
	if is_instance_valid(boss):
		for part in boss_parts:
			if float(part.hp)>0.0 and part.node.global_position.distance_to(point)<24.0:
				_damage_boss_part(part,damage)
		var core_point: Vector3 = boss.core.global_position if is_instance_valid(boss.core) else boss.position
		if core_point.distance_to(point)<24.0 or boss.position.distance_to(point)<34.0: _damage_boss(damage*1.5,point)

func _empower_squadron() -> void:
	for wing in wingmen:
		if float(wing.hp)<=0.0: continue
		wing.level = mini(3,int(wing.level)+1)
		wing.cooldown = maxf(0.0,float(wing.cooldown)-3.0)
		wing.hp = minf(float(wing.max_hp),float(wing.hp)+10.0)
	hud.say("SUPPLY","Wing arsenal upgraded. Stronger shots and faster abilities, up to Mk III.",3.0)

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
		if bullet.life <= 0.0 and not bool(bullet.get("nova",false)):
			bullet.node.queue_free()
			projectiles.remove_at(i)
			continue
		var previous: Vector3 = bullet.node.position
		if bullet.missile and is_instance_valid(bullet.target):
			var desired: Vector3 = (bullet.target.global_position-previous).normalized()*145.0
			bullet.velocity = bullet.velocity.lerp(desired,minf(1.0,dt*5.0))
			effects.trail(previous,Color("ffc166"),.22)
		bullet.node.position += bullet.velocity*dt
		var pos: Vector3 = bullet.node.position
		if bool(bullet.get("nova",false)):
			var explode: bool = float(bullet.life)<=0.0
			for enemy in enemies:
				if _segment_distance(previous,pos,enemy.node.position)<float(enemy.radius)+1.0: explode = true
			if is_instance_valid(boss):
				if _segment_distance(previous,pos,boss.position)<11.0: explode = true
				if is_instance_valid(boss.core) and _segment_distance(previous,pos,boss.core.global_position)<5.0: explode = true
				for part in boss_parts:
					if float(part.hp)>0.0 and _segment_distance(previous,pos,part.node.global_position)<float(part.radius)+1.0: explode = true
			if explode:
				_detonate_companion_nova(pos,float(bullet.damage))
				if not mode in [Mode.FLIGHT,Mode.BOSS]: return
				bullet.life = -1.0
		elif bullet.friendly:
			for enemy in enemies.duplicate():
				if not is_instance_valid(enemy.node): continue
				if _segment_distance(previous,pos,enemy.node.position) < float(enemy.radius):
					if bool(bullet.get("player_missile",false)):
						_detonate_player_missile(Geometry3D.get_closest_point_to_segment(enemy.node.position,previous,pos))
						if not mode in [Mode.FLIGHT,Mode.BOSS]: return
					else: _damage_enemy(enemy,float(bullet.damage))
					bullet.life = -1.0
					hits += 1
					break
			if bullet.life > 0.0 and is_instance_valid(boss):
				var hit_boss := false
				for part in boss_parts:
					if part.hp <= 0.0 or not is_instance_valid(part.node): continue
					if _segment_distance(previous,pos,part.node.global_position)<float(part.get("radius",4.0)):
						var impact := Geometry3D.get_closest_point_to_segment(part.node.global_position,previous,pos)
						if bool(bullet.get("player_missile",false)): _detonate_player_missile(impact)
						else: _damage_boss_part(part,float(bullet.damage))
						if mode != Mode.BOSS: return
						hit_boss = true
						break
				if not hit_boss and is_instance_valid(boss.core):
					var core_position: Vector3 = boss.core.global_position
					var core_scale: Vector3 = boss.core.global_basis.get_scale()
					var core_radius := float(boss.core.get_meta("collision_radius",1.8))*maxf(core_scale.x,maxf(core_scale.y,core_scale.z))
					if _segment_distance(previous,pos,core_position)<core_radius:
						var impact := Geometry3D.get_closest_point_to_segment(core_position,previous,pos)
						if bool(bullet.get("player_missile",false)): _detonate_player_missile(impact)
						else: _damage_boss(float(bullet.damage),impact)
						if mode != Mode.BOSS: return
						hit_boss = true
				if not hit_boss and _segment_distance(previous,pos,boss.position)<(8.0 if stage in [0,3] else 10.5):
					var impact := Geometry3D.get_closest_point_to_segment(boss.position,previous,pos)
					if bool(bullet.get("player_missile",false)): _detonate_player_missile(impact)
					else: _damage_boss(float(bullet.damage),impact)
					if mode != Mode.BOSS: return
					hit_boss = true
				if hit_boss:
					bullet.life = -1.0
					hits += 1
		else:
			if stage==4 and _segment_distance(previous,pos,arena.to_local(carrier_world+Vector3(0,4,0)))<15.0:
				carrier_hp = maxf(0.0,carrier_hp-float(bullet.damage))
				effects.spark(pos,Color("ffa37a"))
				bullet.life = -1.0
			var player_hit: bool = bullet.life>0.0 and _segment_distance(previous,pos,player.position)<1.45
			var first_distance := previous.distance_squared_to(player.position) if player_hit else INF
			var blocker: Dictionary = {}
			for wing in wingmen:
				var distance := previous.distance_squared_to(wing.node.position)
				if bullet.life>0.0 and float(wing.hp)>0.0 and distance<first_distance and _segment_distance(previous,pos,wing.node.position)<1.85:
					first_distance = distance
					blocker = wing
			if not blocker.is_empty():
				_hurt_wing(blocker,float(bullet.damage))
				blocker.guard_time = 0.0
				bullet.life = -1.0
			if bullet.life>0.0 and player_hit:
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
	if index>=3: return _expansion_waves(index)
	var result: Array = []
	# Authored beats: establish, vary, recover, combine, then the boss.
	result.append({"t":3.0,"kind":"rings","pattern":0})
	result.append({"t":5.0,"kind":"wing_power","pattern":0})
	result.append({"t":45.0,"kind":"wing_power","pattern":0})
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
	result.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return float(a.t)<float(b.t))
	return result

func _update_waves() -> void:
	if mode != Mode.FLIGHT: return
	while wave_index < waves.size() and flight_time >= float(waves[wave_index].t):
		var wave: Dictionary = waves[wave_index]
		wave_index += 1
		if stage==4:
			_spawn_arena_wave(wave)
			continue
		if str(wave.kind)=="barrier":
			_spawn_ground_barrier(float(wave.get("x",0.0)),float(wave.get("width",42.0)),float(wave.get("height",4.0)))
			_radio("GLINT","Striped wall ahead. Prepare your jets; wait for HOVER NOW so fuel lasts across the wall.")
			continue
		if str(wave.kind)=="missile":
			_spawn_pickup(Vector3(0,0 if stage==3 else 3,-120),"missile")
			continue
		if str(wave.kind)=="wing_power":
			_spawn_pickup(Vector3(0,2,-120),"wing_power")
			continue
		match str(wave.kind):
			"rings":
				var center_x: float = [-9.0,10.0,0.0][int(wave.pattern)]
				for j in range(5):
					_spawn_pickup(Vector3(center_x+sin(float(j)*.8)*3.0,(0.0 if stage==3 else 3.0+sin(float(j)*.7)*3.0),-150.0-float(j)*27.0),"ring")
				if int(wave.pattern) == 1: _radio("GLINT","Gold rings restore shields. Three will tune up your lasers.")
			"hazard":
				for j in range(int(wave.count)):
					var side := -1.0 if j%2 == 0 else 1.0
					_spawn_hazard(Vector3(side*(7.0+float(j%3)*3),float(j%3)*5-5.0,-155.0-float(j)*33.0),3.5+float(stage)*.5)
				_radio("GLINT",["Debris crossing the sea wall. Thread the gap.","Ice ahead. Brake if you need room.","Heavy wreckage in the approach lane.","Keep the tracks clear.","Watch the perimeter.","Storm debris. Thread the clear lane."][stage])
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
				_hurt_wing(wingmen[0],18.0)
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
		if bool(enemy.rescue) and float(wingmen[0].hp)>0.0:
			stage_score += 100
			wingmen[0].hp = minf(float(wingmen[0].max_hp),float(wingmen[0].hp)+8.0)
		if kills%5 == 0: _spawn_pickup(pos+Vector3(0,1,-8),"wing_power")
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
	boss.scale = Vector3.ONE*[2.2,2.4,3.0,2.1,2.4,2.5][stage]
	boss_max_hp = [260.0,290.0,360.0,300.0,320.0,420.0][stage]
	if save_data.difficulty == "Cadet": boss_max_hp *= .8
	boss_hp = boss_max_hp
	boss_fire = 3.0
	boss_warning = 0.0
	boss_telegraph = ""
	boss_parts.clear()
	var names: Array = [["PORT CANNON","STARBOARD CANNON"],["ARM 1","ARM 2","ARM 3","ARM 4","ARM 5","ARM 6"],["PORT BATTERY","STARBOARD BATTERY"],["PORT MORTAR","STARBOARD MORTAR"],["PORT LAUNCHER","STARBOARD LAUNCHER","VENTRAL GUN","DORSAL GUN"],["PYLON 1","PYLON 2","PYLON 3","PYLON 4"]][stage]
	for part in boss.weak_points:
		if part == boss.core: continue
		var hp: float = [65.0,42.0,80.0,70.0,65.0,60.0][stage]
		if save_data.difficulty == "Cadet": hp *= .8
		boss_parts.append({"node":part,"name":str(names[boss_parts.size()%names.size()]),"hp":hp,"max_hp":hp,"radius":3.8})
	hud.say("WARNING",str(STAGES[stage].boss)+". Break the glowing weapon systems to expose the armored core.",5.0)
	audio.start_music(stage,true)
	audio.sfx("warning")

func _boss_core_open() -> bool:
	for part in boss_parts:
		if float(part.hp)>0.0: return false
	return true

func _damage_boss_part(part: Dictionary, amount: float) -> void:
	if float(part.hp)<=0.0 or not is_instance_valid(part.node): return
	part.hp = maxf(0.0,float(part.hp)-amount)
	boss.hit_flash()
	effects.spark(part.node.global_position,Color("ffc870"))
	if float(part.hp)<=0.0:
		effects.burst(part.node.global_position,Color("ffc870"),3.0)
		part.node.visible = false
		stage_score += 350
		var message := str(part.name)+" destroyed. That weapon is offline."
		if _boss_core_open(): message = "All systems down. Core exposed — finish it!"
		hud.say("TARGETING",message,3.0)

func _update_boss(dt:float) -> void:
	if mode != Mode.BOSS or not is_instance_valid(boss): return
	# The arena controller owns stage 4 world placement; do not pull it back onto rails.
	if stage != 4:
		boss.position.z = lerpf(boss.position.z,-78.0 if stage==3 else -85.0 if stage<2 else -100.0,dt*.55)
		boss.position.x = sin(mode_time*.36)*(8.0 if stage in [0,3] else 11.0)
		boss.position.y = -0.5 if stage==3 else 3.0+sin(mode_time*.55)*4.0
	boss.animate(clock,dt,sin(mode_time*.4)*.08 if stage!=3 else 0.0,0.0,1.0)
	if boss_warning > 0.0:
		boss_warning = maxf(0.0,boss_warning-dt)
		if boss_warning<=0.0:
			_fire_new_boss_pattern()
			boss_telegraph = ""
	boss_fire -= dt
	if boss_fire <= 0.0 and mode_time > 3.5:
		boss_attack += 1
		var live_parts := 0
		for part in boss_parts:
			if part.hp > 0.0: live_parts += 1
		boss_fire = 2.3+float(boss_parts.size()-live_parts)*.24
		if stage >= 3:
			boss_volley_target = player.position
			boss_warning = 1.0
			boss_telegraph = ["GROUND SWEEP — HOLD SHIFT / RB TO HOVER" if boss_attack%2==1 else "MORTAR LOCK — MOVE SIDEWAYS","TORPEDO FAN — TURN ACROSS ITS PATH","CROSS LANCE — LEAVE THE RED LANE" if boss_attack%3==0 else "STORM RING — FIND THE GAP"][stage-3]
			hud.say("WARNING",boss_telegraph,1.5)
			audio.sfx("warning")
		elif stage == 2 and boss_attack%4 == 0:
			_start_beam()
		elif stage == 1 and boss_attack%3 == 0:
			for j in range(12):
				var angle := float(j)*TAU/12.0+float(boss_attack)*.2
				var destination := player.position+Vector3(cos(angle)*12,sin(angle)*9,0)
				_spawn_shot(boss.position,(destination-boss.position).normalized()*54.0,false,14.0)
		else:
			var destination := player.position+Vector3(move_velocity.x,move_velocity.y,0)*.2
			for j in range(-1,2):
				var muzzle: Vector3 = boss.position+Vector3(float(j)*3.0,0,3)
				var direction: Vector3 = (destination+Vector3(float(j)*4.0,0,0)-muzzle).normalized()
				_spawn_shot(muzzle,direction*55.0,false,12.0)
			_fire_live_parts(49.0,10.0)
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

func _fire_live_parts(velocity: float, damage: float) -> void:
	for part in boss_parts:
		if float(part.hp)>0.0:
			_spawn_shot(part.node.global_position,(player.position-part.node.global_position).normalized()*velocity,false,damage)

func _fire_new_boss_pattern() -> void:
	if not is_instance_valid(boss): return
	match stage:
		3:
			# Ground row is cleared by hovering; alternating elevated mortar lanes
			# make landing/recharging a deliberate choice between sweeps.
			if boss_attack%2==1:
				for j in range(-5,6):
					var at := Vector3(float(j)*4.0,-2.0,boss.position.z+8.0)
					_spawn_shot(at,Vector3(0,0,52),false,16.0)
			else: _fire_live_parts(48.0,16.0)
		4:
			var direction: Vector3 = (boss_volley_target-boss.position).normalized()
			for j in range(-2,3):
				_spawn_shot(boss.position,direction.rotated(Vector3.UP,float(j)*.13)*58.0,false,17.0)
			_fire_live_parts(46.0,13.0)
		5:
			if boss_attack%3==0: _start_beam()
			else:
				var gap := boss_attack%8
				for j in range(8):
					if j==gap or j==(gap+1)%8: continue
					var angle := float(j)*TAU/8.0
					var target := boss_volley_target+Vector3(cos(angle)*11,sin(angle)*8,0)
					_spawn_shot(boss.position,(target-boss.position).normalized()*57.0,false,16.0)
				_fire_live_parts(47.0,12.0)

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
	boss_hp -= amount * (1.0 if _boss_core_open() else .08)
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
		_reset_maneuver()
		mode = Mode.CLEAR
		mode_time = 0.0
		hud.say("COMET",["Blockade broken. The corridor is yours. Bring them home.","Relay is down. I've got the carrier's coordinates.","Sovereign is gone. Asterion, your sky is clear.","Siege engine down. The convoy can cross.","Dragonfly is safe. The raiders are breaking off.","Storm spire silenced. Every flight has a way home."][stage],5.0)
		audio.sfx("victory")

func _spawn_hazard(pos:Vector3,radius:float) -> void:
	var mesh := MeshInstance3D.new()
	var shape := SphereMesh.new()
	shape.radius = radius
	shape.height = radius*1.7
	shape.radial_segments = 7
	shape.rings = 3
	mesh.mesh = shape
	mesh.material_override = _material([Color("907960"),Color("91dbe4"),Color("685f7d"),Color("b96b44"),Color("6ea9bd"),Color("8b95bd")][stage])
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
	mesh.material_override = _material(Color("78ecff") if kind=="missile" else Color("a8acff") if kind=="wing_power" else Color("ffe6a3") if kind == "ring" else (Color("81ffd3") if kind == "repair" else Color("ff9b85")),2.0)
	root.add_child(mesh)
	if kind in ["wing_power","missile"]:
		for side in [-1.0,1.0]:
			var chevron := MeshInstance3D.new()
			var shape := BoxMesh.new()
			shape.size = Vector3(1.7,.4,.4)
			chevron.mesh = shape
			chevron.material_override = mesh.material_override
			chevron.position.x = side*.65
			chevron.rotation.z = -side*.6
			root.add_child(chevron)
	elif kind != "ring":
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
	pickup_notice_time = maxf(0.0,pickup_notice_time-dt)
	if pickup_notice_time<=0.0: pickup_notice = ""
	if not pickup_sweep_initialized:
		pickup_player_previous = player.position
		pickup_sweep_initialized = true
	for i in range(hazards.size()-1,-1,-1):
		var hazard: Dictionary = hazards[i]
		if stage!=4: hazard.node.position.z += speed*dt
		hazard.node.rotation += Vector3(.13,.22,.08)*dt
		hazard.life -= dt
		if hazard.node.position.distance_to(player.position)<float(hazard.radius)+1.0:
			_hurt(22.0)
			effects.burst(hazard.node.position,Color("b9dce4"),2.0)
			hazard.life = 0.0
		if (stage!=4 and hazard.node.position.z > 35) or hazard.life <= 0.0:
			hazard.node.queue_free()
			hazards.remove_at(i)
	for i in range(pickups.size()-1,-1,-1):
		var pickup: Dictionary = pickups[i]
		var previous: Vector3 = pickup.node.position
		if stage!=4: pickup.node.position.z += speed*dt
		pickup.node.rotation.z += dt*.4
		# Relative sweep catches a ship crossing a ring during a fast maneuver,
		# not only a ring crossing the ship's final position in this frame.
		var collected := _segment_distance(previous-pickup_player_previous,pickup.node.position-player.position,Vector3.ZERO)<=3.7
		if collected:
			audio.sfx("pickup")
			effects.shockwave(player.position,Color("ffedab"),4.0)
			stage_score += 100
			match str(pickup.kind):
				"ring":
					rings += 1
					shield = minf(100.0,shield+7.0)
					pickup_notice = "RING %d / 3  +7 SHIELD  +100" % ((rings-1)%3+1)
					if rings%3 == 0:
						laser_level = 2
						stage_score += 300
						hud.say("SYSTEM","Twin lasers upgraded. Shields reinforced.",2.5)
						shield = minf(100.0,shield+12.0)
						pickup_notice = "TWIN LASERS UPGRADED  +19 SHIELD  +400"
				"repair":
					shield = minf(100.0,shield+25.0)
					missiles = mini(MAX_MISSILES,missiles+2)
					pickup_notice = "REPAIR  +25 SHIELD  +2 MISSILES"
				"bomb":
					bombs = mini(5,bombs+1)
					pickup_notice = "NOVA BOMB +1"
				"missile":
					missiles = mini(MAX_MISSILES,missiles+3)
					pickup_notice = "MISSILES +3  /  %d READY" % missiles
				"wing_power":
					_empower_squadron()
					pickup_notice = "SQUADRON ARSENAL UPGRADED"
			pickup_notice_time = 2.5
		if collected or (stage!=4 and pickup.node.position.z>35.0) or (stage==4 and pickup.node.position.length()>500.0):
			pickup.node.queue_free()
			pickups.remove_at(i)
	pickup_player_previous = player.position

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
		_reset_maneuver()
		mode = Mode.DEAD
		mode_time = 0.0
		overlay.visible = false
		hud.show_result({"success":false,"final":false,"score":stage_score,"kills":kills,"rank":"—","stage_name":STAGES[stage].title,"bonus":0})

func _update_wingmen(dt:float) -> void:
	var combat := mode in [Mode.FLIGHT,Mode.BOSS]
	for slot in range(wingmen.size()):
		var wing: Dictionary = wingmen[slot]
		var node: Node3D = wing.node
		node.visible = float(wing.hp)>0.0
		if not node.visible: continue
		var pilot := Squadron.profile(str(wing.id))
		if combat:
			wing.fire = maxf(0.0,float(wing.fire)-dt)
			wing.cooldown = maxf(0.0,float(wing.cooldown)-dt)
			wing.guard_time = maxf(0.0,float(wing.guard_time)-dt)
			wing.burst_timer = maxf(0.0,float(wing.burst_timer)-dt)
			# Anticipate a bolt reaching the player's front plane, then fly to intercept.
			if str(pilot.ability)=="guard" and float(wing.cooldown)<=0.0:
				for shot in projectiles:
					if shot.friendly or shot.life<=0.0 or bool(shot.get("guard_assigned",false)) or float(shot.velocity.z)<=1.0: continue
					var intercept_time: float = (player.position.z-5.5-shot.node.position.z)/float(shot.velocity.z)
					if intercept_time<0.08 or intercept_time>0.85: continue
					var point: Vector3 = shot.node.position+shot.velocity*intercept_time
					if Vector2(point.x-player.position.x,point.y-player.position.y).length()>2.5: continue
					if _companion_ability(wing,null):
						wing.guard_point = point
						shot["guard_assigned"] = true
					break
		var offset := Squadron.offset(int(save_data.formation),slot)
		var target: Vector3 = player.position+offset+Vector3(0,sin(clock*.85+slot)*.35,0)
		if float(wing.guard_time)>0.0: target = wing.guard_point
		var previous: Vector3 = node.position
		node.position = node.position.lerp(target,1.0-exp(-dt*(18.0 if float(wing.guard_time)>0.0 else 3.8)))
		var bank := clampf(-(node.position.x-previous.x)*.12,-.65,.65)
		node.animate(clock+float(slot),dt,bank,0.0,1.7 if float(wing.guard_time)>0.0 else 1.0)
		if not combat: continue
		var enemy := _companion_target(node.position)
		if not is_instance_valid(enemy): continue
		var damage_scale := 1.0+0.4*float(int(wing.level)-1)
		if float(wing.fire)<=0.0:
			_spawn_shot(node.position,(enemy.global_position-node.position).normalized()*165.0,true,float(pilot.damage)*damage_scale)
			wing.fire = float(pilot.interval)/(1.0+0.22*float(int(wing.level)-1))
		if str(pilot.ability)!="guard": _companion_ability(wing,enemy)
		if int(wing.burst)>0 and float(wing.burst_timer)<=0.0:
			_spawn_shot(node.position,(enemy.global_position-node.position).normalized()*200.0,true,0.55*damage_scale)
			wing.burst = int(wing.burst)-1
			wing.burst_timer = 0.09

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
	if is_instance_valid(boss):
		for part in boss_parts:
			if float(part.hp)>0.0: nodes.append(part.node)
		nodes.append(boss)
	overlay.set_targets(camera,aim,nodes,lock_target,lock_progress,damage_flash,roll_time/.68)
	overlay.set_arena(stage==4,arena,carrier_world,enemies,arena_boss_world if is_instance_valid(boss) else Vector3.INF)
	ui_timer -= dt
	if ui_timer>0.0: return
	ui_timer = .05
	var objective: String = STAGES[stage].objective
	if mode == Mode.BOSS: objective = "Target the glowing pods · R lock missile · B nova"
	elif stage==3: objective = "SHIFT / RB hover over walls · release to land · W/S aim · SPACE fire"
	elif stage==4: objective = "Defend Dragonfly · A/D turn · red radar contacts are attackers"
	elif flight_time<14.0: objective = "WASD / arrows fly · SPACE fire · Q / E barrel roll"
	else: objective += "  /  F: squad abilities  /  TAB: formation"
	hud.update_hud({"vehicle":"tank" if stage==3 else "flight","arena":stage==4,"hover_fuel":tank.fuel,"carrier_hp":carrier_hp,"arena_turning":arena.turning,"arena_warning":arena.warning(),"missiles":missiles,"missile_max":MAX_MISSILES,"pickup_notice":pickup_notice,"boss_parts":boss_parts,"core_open":_boss_core_open(),"shield":shield,"energy":energy,"bombs":bombs,"score":stage_score+campaign_score,"combo":combo,"stage_name":STAGES[stage].title,"progress":minf(1.0,flight_time/float(STAGES[stage].duration)),"speed":speed,"boss_name":STAGES[stage].boss if mode == Mode.BOSS else "","boss_hp":boss_hp/boss_max_hp if mode == Mode.BOSS else -1.0,"lock":lock_progress,"objective":objective,"roll_ready":roll_cooldown<=0.0 and not maneuver.active(),"wingmen":wingmen,"formation":Squadron.FORMATIONS[int(save_data.formation)],"maneuver":maneuver.label(),"maneuver_cooldown":maneuver_cooldown,"maneuver_ready":energy >= Maneuver.ENERGY_COST and roll_time <= 0.0})

func _finish_stage() -> void:
	var bonus := int(shield)*20+rings*100
	for wing in wingmen:
		if wing.hp>0.0: bonus += 700
	stage_score += bonus
	campaign_score += stage_score
	var rank := "S" if kills>=28 and shield>=60 else ("A" if kills>=20 else ("B" if kills>=10 else "C"))
	var recruits: Array[String] = []
	for pilot in Squadron.ROSTER:
		if int(pilot.gate)==stage and not Squadron.available(str(pilot.id),save_data): recruits.append(str(pilot.name))
	if not save_data.completed_stages.has(stage): save_data.completed_stages.append(stage)
	save_data.unlocked = maxi(int(save_data.unlocked),mini(STAGES.size(),stage+2))
	save_data.best = maxi(int(save_data.best),campaign_score)
	var record_key := "%d_%s"%[stage,str(save_data.difficulty)]
	save_data.records[record_key] = maxi(int(save_data.records.get(record_key,0)),stage_score)
	_write_save()
	mode = Mode.RESULT
	mode_time = 0.0
	overlay.visible = false
	hud.show_result({"success":true,"final":stage==STAGES.size()-1,"score":stage_score,"kills":kills,"rank":rank,"stage_name":STAGES[stage].title,"bonus":bonus,"recruits":", ".join(recruits)})

func _radio(speaker:String,message:String) -> void:
	if speaker=="LATCH": speaker = str(wingmen[0].callsign)
	elif speaker=="GLINT": speaker = str(wingmen[1].callsign)
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
		save_data.unlocked = clampi(int(parsed.unlocked),1,STAGES.size())
	if parsed.get("best") is float or parsed.get("best") is int:
		save_data.best = clampi(int(parsed.best),0,999999999)
	if parsed.get("muted") is bool: save_data.muted = parsed.muted
	if parsed.get("difficulty") in ["Cadet","Standard","Ace"]: save_data.difficulty = parsed.difficulty
	if parsed.get("records") is Dictionary:
		for key in parsed.records:
			if parsed.records[key] is float or parsed.records[key] is int:
				save_data.records[str(key)] = clampi(int(parsed.records[key]),0,999999999)

	for key in ["companions","formation","completed_stages"]:
		if parsed.has(key): save_data[key] = parsed[key]
	Squadron.normalize(save_data)
	for cleared in save_data.completed_stages:
		save_data.unlocked = maxi(int(save_data.unlocked),mini(STAGES.size(),int(cleared)+2))

func _write_save() -> void:
	var file := FileAccess.open(save_path,FileAccess.WRITE)
	if file != null: file.store_string(JSON.stringify(save_data,"\t"))

# Expansion vehicles keep one movement authority and feed poses into the same rig.
func _vehicle_fire(pad: int) -> void:
	var firing := Input.is_action_pressed("fire") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or (pad>=0 and Input.get_joy_axis(pad,JOY_AXIS_TRIGGER_RIGHT)>.25)
	if firing and shot_cooldown<=0.0: _fire_player()

func _update_tank_player(dt: float, axis: Vector2, hovering: bool, pad: int) -> void:
	tank.advance(dt,hovering)
	move_velocity = move_velocity.lerp(Vector2(axis.x*25.0,0),1.0-exp(-dt*8.0))
	player.position.x = clampf(player.position.x+move_velocity.x*dt,-18.0,18.0)
	player.position.y = tank.height
	player.position.z = 0.0
	tank_aim_y = clampf(tank_aim_y+axis.y*dt*34.0,-10.0,22.0)
	if mouse_active:
		var pointer := get_viewport().get_mouse_position()/get_viewport().get_visible_rect().size
		tank_aim_y = (0.55-pointer.y)*42.0
		player.position.x = move_toward(player.position.x,(pointer.x-.5)*36.0,dt*25.0)
	var brake := Input.is_action_pressed("brake") or (pad>=0 and Input.is_joy_button_pressed(pad,JOY_BUTTON_LEFT_SHOULDER))
	speed = lerpf(speed,18.0 if brake else 32.0,1.0-exp(-dt*4.0))
	energy = tank.fuel
	player.rotation.y = -axis.x*.08
	player.animate(clock,dt,-axis.x*.10,-tank.vertical_speed*.014,1.6 if tank.hovering else .7,0,damage_flash)
	aim = Vector3(player.position.x*1.6,tank_aim_y,-100)
	_vehicle_fire(pad)

func _update_arena_player(dt: float, axis: Vector2, boost: bool, pad: int) -> void:
	if mouse_active:
		var pointer := get_viewport().get_mouse_position()/get_viewport().get_visible_rect().size
		axis = Vector2((pointer.x-.5)*2.0,(.5-pointer.y)*2.0).limit_length()
	var old_basis := arena.basis()
	var old_position: Vector3 = arena.position
	var was_turning: bool = arena.turning
	if not boost: boost_depleted = false
	if energy<=1.0: boost_depleted = true
	var boosting := boost and not boost_depleted and energy>1.0 and not arena.turning
	var brake := Input.is_action_pressed("brake") or (pad>=0 and Input.is_joy_button_pressed(pad,JOY_BUTTON_LEFT_SHOULDER))
	arena.advance(dt,axis,boosting,brake)
	energy = clampf(energy+dt*(-28.0 if boosting else 18.0),0.0,100.0)
	speed = arena.velocity
	# Preserve actual world trajectories while the camera frame turns around them.
	var rotation_delta: Basis = arena.basis().inverse()*old_basis
	for shot in projectiles:
		var point: Vector3 = old_position+old_basis*(shot.node.position-Arena.ANCHOR)
		shot.node.position = arena.to_local(point)
		shot.velocity = rotation_delta*Vector3(shot.velocity)
	for item in pickups:
		item.node.position = arena.to_local(old_position+old_basis*(item.node.position-Arena.ANCHOR))
	for item in hazards:
		item.node.position = arena.to_local(old_position+old_basis*(item.node.position-Arena.ANCHOR))
	for wing in wingmen:
		wing.guard_point = arena.to_local(old_position+old_basis*(Vector3(wing.guard_point)-Arena.ANCHOR))
	# Refresh targets in the new camera frame before either player or wing fire.
	for enemy in enemies:
		if enemy.has("arena_pos"): enemy.node.position = arena.to_local(enemy.arena_pos)
	if is_instance_valid(boss): _sync_arena_boss()
	if boss_warning>0.0:
		boss_volley_target = arena.to_local(old_position+old_basis*(boss_volley_target-Arena.ANCHOR))
	player.position = Arena.ANCHOR
	move_velocity = Vector2(axis.x*20.0,axis.y*20.0)
	var roll_angle := 0.0
	if arena.turning:
		roll_time = 0.0
		lock_progress = 0.0
		lock_target = null
		if not was_turning:
			hud.say("FLIGHT","Perimeter reached. Climbing turnaround — control resumes facing the carrier.",2.6)
			audio.sfx("boost")
	elif roll_time>0.0:
		roll_time = maxf(0.0,roll_time-dt)
		roll_angle = roll_direction*TAU*smoothstep(0.0,1.0,1.0-roll_time/.68)
		invulnerable = maxf(invulnerable,.08)
	player.rotation.y = 0.0
	player.animate(clock,dt,arena.bank,arena.pitch,1.7 if boosting else (0.5 if arena.turning else 1.0),roll_angle,damage_flash)
	aim = Arena.ANCHOR+Vector3(axis.x*18.0,axis.y*14.0,-100)
	_sync_arena_view()
	if not arena.turning: _vehicle_fire(pad)

func _sync_arena_view() -> void:
	world.set_arena_view(arena.position,arena.heading)
	defense_carrier.visible = true
	defense_carrier.position = arena.to_local(carrier_world)
	defense_carrier.rotation.y = -arena.heading
	defense_carrier.animate(0.016,clock)
	carrier.visible = false

func _expansion_waves(index: int) -> Array:
	var result: Array = []
	if index==3:
		result = [{"t":2.0,"kind":"rings","pattern":2},{"t":4.0,"kind":"wing_power"},{"t":7.0,"kind":"barrier","width":42.0,"height":3.5},{"t":15.0,"kind":"fighter","count":3,"pattern":0},{"t":22.0,"kind":"barrier","x":-9.0,"width":22.0,"height":5.0},{"t":27.0,"kind":"missile"},{"t":31.0,"kind":"bomber","count":2,"pattern":1},{"t":39.0,"kind":"barrier","width":42.0,"height":4.5},{"t":47.0,"kind":"rings","pattern":2},{"t":52.0,"kind":"wing_power"},{"t":56.0,"kind":"barrier","x":8.0,"width":22.0,"height":5.5},{"t":62.0,"kind":"interceptor","count":4,"pattern":2},{"t":71.0,"kind":"barrier","width":42.0,"height":5.5},{"t":80.0,"kind":"missile"},{"t":85.0,"kind":"bomber","count":3,"pattern":0},{"t":92.0,"kind":"rings","pattern":2}]
	elif index==4:
		result = [{"t":2.0,"kind":"supply"},{"t":6.0,"kind":"attack","count":2,"angle":0.0},{"t":18.0,"kind":"attack","count":2,"angle":1.7},{"t":30.0,"kind":"attack","count":3,"angle":3.1},{"t":42.0,"kind":"supply"},{"t":46.0,"kind":"attack","count":3,"angle":4.6},{"t":61.0,"kind":"attack","count":3,"angle":0.7},{"t":75.0,"kind":"attack","count":3,"angle":3.7},{"t":83.0,"kind":"supply"}]
	else:
		result = [{"t":2.0,"kind":"rings","pattern":0},{"t":5.0,"kind":"wing_power"},{"t":8.0,"kind":"interceptor","count":4,"pattern":2},{"t":17.0,"kind":"hazard","count":4,"pattern":0},{"t":24.0,"kind":"bomber","count":3,"pattern":1},{"t":32.0,"kind":"rings","pattern":1},{"t":38.0,"kind":"missile"},{"t":43.0,"kind":"fighter","count":5,"pattern":1},{"t":52.0,"kind":"hazard","count":5,"pattern":1},{"t":59.0,"kind":"wing_power"},{"t":63.0,"kind":"interceptor","count":5,"pattern":2},{"t":72.0,"kind":"rings","pattern":2},{"t":78.0,"kind":"bomber","count":3,"pattern":0},{"t":87.0,"kind":"hazard","count":5,"pattern":1},{"t":94.0,"kind":"missile"},{"t":100.0,"kind":"rings","pattern":0}]
	return result

func _spawn_ground_barrier(x: float, width: float, height: float) -> void:
	var node := Node3D.new()
	actors.add_child(node)
	node.position = Vector3(x,-4.0+height*.5,-165)
	var shape := BoxMesh.new()
	shape.size = Vector3(width,height,5.0)
	var mesh := MeshInstance3D.new()
	mesh.mesh = shape
	mesh.material_override = _material(Color("5d3c35"))
	node.add_child(mesh)
	for i in range(int(width/3.0)):
		var stripe := MeshInstance3D.new()
		var marker := BoxMesh.new()
		marker.size = Vector3(1.25,.45,5.1)
		stripe.mesh = marker
		stripe.material_override = _material(Color("ffd46c"),1.0)
		stripe.position = Vector3(-width*.5+1.5+float(i)*3.0,height*.5+.15,0)
		node.add_child(stripe)
	ground_barriers.append({"node":node,"width":width,"height":height,"passed":false,"warned":false})

func _update_ground_barriers(dt: float) -> void:
	for barrier in ground_barriers.duplicate():
		var node: Node3D = barrier.node
		var previous_z := node.position.z
		node.position.z += speed*dt
		if not barrier.warned and node.position.z>-65.0:
			barrier.warned = true
			hud.say("JACKAL","JET HOVER NOW — hold Shift / RB, clear the striped top!",2.5)
		if not barrier.passed and previous_z<player.position.z+3.0 and node.position.z>=player.position.z-3.0:
			barrier.passed = true
			var in_lane := absf(player.position.x-node.position.x)<float(barrier.width)*.5+1.7
			var above := player.position.y-1.3 > -4.0+float(barrier.height)
			if in_lane and not above:
				_hurt(24.0)
				effects.burst(player.position,Color("ffbc76"),2.0)
			elif in_lane:
				stage_score += 250
				hud.say("JACKAL","Barrier cleared! +250",1.5)
		if node.position.z>40.0:
			node.queue_free()
			ground_barriers.erase(barrier)

func _spawn_arena_wave(wave: Dictionary) -> void:
	if wave.kind=="supply":
		# Resupply appears directly ahead, with no dependency on orbital heading.
		_spawn_pickup(Arena.ANCHOR+Vector3(0,0,-52),"repair")
		_spawn_pickup(Arena.ANCHOR+Vector3(0,0,-78),"missile")
		_spawn_pickup(Arena.ANCHOR+Vector3(0,0,-104),"wing_power")
		hud.say("DRAGONFLY","Resupply launched ahead of you. Green repairs, blue missiles, violet wing upgrades.",3.0)
		return
	for i in range(int(wave.count)):
		var angle := float(wave.angle)+float(i)*.25
		var enemy := _spawn_enemy("bomber" if i==0 else "fighter",i,int(wave.count),0)
		enemy["arena_pos"] = Vector3(sin(angle)*165.0,12.0+float(i)*8.0,cos(angle)*165.0)
		enemy["run_angle"] = angle
		enemy["attack_pass"] = false
		enemy.node.position = arena.to_local(enemy.arena_pos)
	hud.say("DRAGONFLY","Incoming strike wing. Red radar contacts are closing on the carrier!",3.0)

func _update_arena_enemies(dt: float) -> void:
	for enemy in enemies.duplicate():
		if not enemies.has(enemy): continue
		if not enemy.has("arena_pos"):
			enemy["arena_pos"] = arena.to_world(enemy.node.position)
			enemy["run_angle"] = 0.0
			enemy["attack_pass"] = false
		enemy.age += dt
		enemy.fire -= dt
		var point: Vector3 = enemy.arena_pos
		var to_carrier := carrier_world+Vector3(0,6,0)-point
		var direction := to_carrier.normalized()
		if to_carrier.length()<38.0: enemy.attack_pass = true
		if enemy.attack_pass:
			direction = Vector3(sin(float(enemy.run_angle)+PI*.65),.12,cos(float(enemy.run_angle)+PI*.65)).normalized()
		point += direction*dt*(16.0 if enemy.kind=="bomber" else 23.0)
		enemy.arena_pos = point
		var node: Node3D = enemy.node
		node.position = arena.to_local(point)
		var local_direction: Vector3 = arena.basis().inverse()*direction
		node.rotation.y = atan2(-local_direction.x,-local_direction.z)+PI
		node.animate(clock+float(enemy.phase),dt,.12,0.0,1.0)
		if enemy.fire<=0.0 and to_carrier.length()<155.0 and not enemy.attack_pass:
			enemy.fire = 3.5 if enemy.kind=="bomber" else 4.5
			var carrier_local: Vector3 = arena.to_local(carrier_world+Vector3(0,5,0))
			_spawn_shot(node.position,(carrier_local-node.position).normalized()*44.0,false,3.0 if enemy.kind=="bomber" else 1.8)
			if not projectiles.is_empty(): projectiles.back()["carrier_attack"] = true
		if node.position.distance_to(player.position)<3.4:
			_hurt(20.0)
			_damage_enemy(enemy,99.0)
		elif Vector2(point.x,point.z).length()>230.0:
			node.queue_free()
			enemies.erase(enemy)

func _sync_arena_boss() -> void:
	if not is_instance_valid(boss): return
	var angle := mode_time*.075
	arena_boss_world = Vector3(sin(angle)*95.0,20.0+sin(mode_time*.3)*8.0,cos(angle)*95.0)
	boss.position = arena.to_local(arena_boss_world)
	boss.rotation.y = angle+PI-arena.heading

func _update_carrier_defense(dt: float) -> void:
	var center: Vector3 = arena.to_local(carrier_world+Vector3(0,4,0))
	defense_carrier.set_damage(carrier_hp/100.0)
	carrier_fire -= dt
	if carrier_fire<=0.0:
		carrier_fire = 2.8
		var closest: Node3D
		var distance := 130.0
		for enemy in enemies:
			var candidate: float = enemy.node.position.distance_to(center)
			if candidate<distance:
				closest = enemy.node
				distance = candidate
		if is_instance_valid(closest):
			_spawn_shot(center,(closest.position-center).normalized()*110.0,true,2.0)
	if mode==Mode.BOSS and fmod(mode_time,9.0)<dt and is_instance_valid(boss):
		_spawn_shot(boss.position,(center-boss.position).normalized()*38.0,false,5.0)
		if not projectiles.is_empty(): projectiles.back()["carrier_attack"] = true
	if carrier_hp<=0.0:
		_reset_maneuver()
		arena.turning = false
		mode = Mode.DEAD
		mode_time = 0.0
		overlay.visible = false
		hud.show_result({"success":false,"final":false,"score":stage_score,"kills":kills,"rank":"—","stage_name":"DRAGONFLY LOST — retry the defense","bonus":0})
