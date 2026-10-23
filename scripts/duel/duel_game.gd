extends Node3D
## Phase One practice operation. World motion, observation, damage and camera
## have separate owners. Experimental settings do not modify campaign saves.
const Vehicle = preload("res://scripts/duel/duel_vehicle.gd")
const Pilot = preload("res://scripts/duel/duel_pilot.gd")
const Weapons = preload("res://scripts/duel/duel_weapons.gd")
const Geometry = preload("res://scripts/duel/duel_geometry.gd")
const Ship = preload("res://scripts/ship_model.gd")
const Sound = preload("res://scripts/flight_audio.gd")
const Effects = preload("res://scripts/flight_effects.gd")
const VOLUMES := [Vector2(600,76),Vector2(640,160)]
const Build = preload("res://scripts/duel/duel_build.gd")
const REVISION = Build.SOURCE_ID
var vehicles: Array = [Vehicle.new(),Vehicle.new()]
var rigs: Array[Node3D] = []
var pilot := Pilot.new()
var weapons := Weapons.new()
var cover: Array = []
var camera: Camera3D
var effects: Node3D
var audio: Node
var arena_root: Node3D
var shot_nodes: Dictionary = {}
var shot_mesh: CapsuleMesh
var shot_materials: Array[StandardMaterial3D] = []
var hp := [100.0,100.0]
var grace := [0.0,0.0]
var elapsed := 0.0
var volume_index := 1
var radius := 320.0
var ceiling := 160.0
var pitch_hold := true
var reduced_motion := true
var mode := "briefing"
var paused := false
var debug_view := false
var return_text := ""
var event_text := "Opponent staging high. Use the structure to break its approach."
var event_time := 0.0
var observation: Dictionary = {}
var player_contact: Dictionary = {}
var last_player_seen := -1000.0
var samples: Array[Dictionary] = []
var trace_events: Array[Dictionary] = []
var sample_at := 0.0
var camera_retractions := 0
var obscured_threat_time := 0.0
var camera_shortened := false
var options: Control
var start_button: Button
var status: Label
var overlay: Control
var trace_path := ""
var run_id := ""
var _accumulator := 0.0
var _roll_request := 0.0
var _frame_request: Dictionary = {}
var run_driver := "human_input"
var _bot_player := false # Explicit capture/test driver, recorded in trace metadata.
var _hit_flash := 0.0
var _mouse_steering := false
var _last_pilot_state := ""
var _hud_clock := 0.0

class DuelOverlay extends Control:
	var game: Node3D
	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	func _draw() -> void:
		if not is_instance_valid(game) or game.mode!="flight": return
		game.draw_overlay(self)

func _ready() -> void:
	_setup_inputs()
	volume_index = 0 if "--duel-low" in OS.get_cmdline_user_args() else 1
	pitch_hold = not "--pitch-level" in OS.get_cmdline_user_args()
	reduced_motion = not "--full-camera" in OS.get_cmdline_user_args()
	_build_world()
	for i in range(2):
		var rig: Node3D = Ship.new()
		add_child(rig)
		rig.setup("player" if i==0 else "wingman",Color("cfe8f4") if i==0 else Color("ff765e"))
		rig.set_meta("motion_contract",{"forward":"-Z","up":"+Y","bounds":AABB(Vector3(-3.47,-.518,-3.1),Vector3(6.94,1.848,5.3)),"solid_radius":4.0,"engines":[Vector3(-.92,-.07,1.52),Vector3(.92,-.07,1.52)],"reset":"setup resets rig; Vehicle.reset owns motion"})
		rigs.append(rig)
	camera = Camera3D.new()
	camera.fov = 67.0
	camera.far = 1800.0
	camera.near = .15
	add_child(camera)
	camera.current = true
	audio = Sound.new()
	add_child(audio)
	audio.start_music(4,false)
	effects = Effects.new()
	add_child(effects)
	shot_mesh = CapsuleMesh.new()
	shot_mesh.radius = .14
	shot_mesh.height = 2.0
	shot_mesh.radial_segments = 5
	for color in [Color("75efff"),Color("ff765e")]: shot_materials.append(material(color,true))
	_build_ui()
	_reset(false)
	if "--duel-replay" in OS.get_cmdline_user_args():
		_bot_player = true
		run_driver = "arranged_capture"
		_start()

func _setup_inputs() -> void:
	var bindings := {"left":[KEY_A,KEY_LEFT],"right":[KEY_D,KEY_RIGHT],"up":[KEY_W,KEY_UP],"down":[KEY_S,KEY_DOWN],"fire":[KEY_SPACE],"boost":[KEY_SHIFT],"brake":[KEY_CTRL],"roll_left":[KEY_Q],"roll_right":[KEY_E]}
	for action in bindings:
		if not InputMap.has_action(action): InputMap.add_action(action)
		if InputMap.action_get_events(action).is_empty():
			for key in bindings[action]:
				var event := InputEventKey.new()
				event.physical_keycode = key
				InputMap.action_add_event(action,event)

func material(color: Color, glow: bool = false) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = .72
	if glow:
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.emission_enabled = true
		mat.emission = color
	return mat

func box_mesh(parent: Node3D, point: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.material_override = material(color)
	node.position = point
	parent.add_child(node)
	return node

func _build_world() -> void:
	if is_instance_valid(arena_root):
		remove_child(arena_root)
		arena_root.queue_free()
	arena_root = Node3D.new()
	add_child(arena_root)
	radius = VOLUMES[volume_index].x*.5
	ceiling = VOLUMES[volume_index].y
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("102c47")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("a3c7e4")
	environment.ambient_light_energy = .8
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var env := WorldEnvironment.new()
	env.environment = environment
	arena_root.add_child(env)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-35,-32,0)
	light.light_energy = 1.6
	arena_root.add_child(light)
	box_mesh(arena_root,Vector3(0,-2,0),Vector3(radius*2+60,4,radius*2+60),Color("183846"))
	# Same 60 x 44 x 44 core in both volumes; at least two broad side routes.
	# Width/height cap in the low candidate keeps a 28-unit route above the roof.
	var height := 44.0
	cover = [{"id":"anchor-block","box":AABB(Vector3(-30,4,-22),Vector3(60,height,44))}]
	box_mesh(arena_root,Vector3(0,4+height*.5,0),Vector3(60,height,44),Color("3d5f75"))
	for side in [-1.0,1.0]:
		box_mesh(arena_root,Vector3(side*30.2,26,0),Vector3(.5,40,36),Color("658698"))
		box_mesh(arena_root,Vector3(side*22,48.3,0),Vector3(1,.6,42),Color("e5b55e"))
	for i in range(5):
		box_mesh(arena_root,Vector3(-24+float(i)*12,29,22.2),Vector3(3,22,.5),Color("7899aa"))
	# Solid warning stripes emphasize that this is cover, not a painted backdrop.
	for i in range(9):
		box_mesh(arena_root,Vector3(-27+float(i)*6,7,22.4),Vector3(2,3,.5),Color("f3c77d"))
	for i in range(32):
		var angle := TAU*float(i)/32.0
		var point := Vector3(sin(angle)*radius,0,cos(angle)*radius)
		box_mesh(arena_root,point+Vector3(0,ceiling*.5,0),Vector3(1.5,ceiling,1.5),Color("426d84"))
		for y in [8.0,ceiling*.5,ceiling-3.0]:
			box_mesh(arena_root,point+Vector3(0,y,0),Vector3(3,2,3),Color("8acbd2"))
	# Floor grid and high rings provide a stable horizon without rotating camera roll.
	for x in range(-6,7):
		box_mesh(arena_root,Vector3(float(x)*45,.1,0),Vector3(.35,.2,radius*2),Color("2c5967"))
		box_mesh(arena_root,Vector3(0,.1,float(x)*45),Vector3(radius*2,.2,.35),Color("2c5967"))
	var torus := TorusMesh.new()
	torus.inner_radius = radius-1.3
	torus.outer_radius = radius+1.3
	torus.rings = 96
	torus.ring_segments = 4
	for y in [1.0,ceiling*.5,ceiling]:
		var ring := MeshInstance3D.new()
		ring.mesh = torus
		ring.position.y = y
		ring.material_override = material(Color("72a9b5"),true)
		arena_root.add_child(ring)

func _reset(rebuild: bool = true) -> void:
	if mode=="flight" and not samples.is_empty(): _write_trace("restart")
	if rebuild: _build_world()
	weapons.reset()
	for node in shot_nodes.values(): node.queue_free()
	shot_nodes.clear()
	hp = [100.0,100.0]
	grace = [0.0,0.0]
	elapsed = 0.0
	_accumulator = 0.0
	_roll_request = 0.0
	paused = false
	_hit_flash = 0.0
	camera_retractions = 0
	obscured_threat_time = 0.0
	camera_shortened = false
	samples.clear()
	trace_events.clear()
	sample_at = 0.0
	observation.clear()
	player_contact.clear()
	last_player_seen = -1000.0
	vehicles[0].reset(Vector3(0,ceiling*.45,125),0.0)
	vehicles[1].reset(Vector3(75,minf(ceiling-12.0,100.0),-65),PI-.4,-.15)
	for vehicle in vehicles: vehicle.pitch_hold = pitch_hold
	pilot.reset(Vector3(70,ceiling-14,20))
	_last_pilot_state = pilot.state
	mode = "briefing"
	event_text = "Opponent staging high. Use the structure to break its approach."
	options.show()
	start_button.text = "START STANDARD DUEL"
	_update_rigs(1.0/60.0)
	_update_camera(1.0,true)
	_refresh_status()

func _start() -> void:
	mode = "flight"
	options.hide()
	status.text = ""
	start_button.release_focus()
	run_id = Time.get_datetime_string_from_system().replace(":","-")+"-"+str(Time.get_ticks_usec())
	event_text = "Opponent setting up high. Break its line with the anchor block."
	event_time = 5.0
	_log("start",{"profile":Vehicle.PROFILE,"volume":VOLUMES[volume_index],"pitch_hold":pitch_hold,"reduced_motion":reduced_motion,"driver":run_driver})

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_ESCAPE:
				if mode=="flight":
					paused = not paused
					options.visible = paused
					start_button.text = "RESUME DUEL"
					_refresh_status()
			KEY_F5: _reset()
			KEY_F3: debug_view = not debug_view
			KEY_F8: _write_trace("manual_snapshot")
			KEY_Q: _roll_request = -1.0
			KEY_E: _roll_request = 1.0
	if event is InputEventMouseMotion and mode=="flight" and event.relative.length()>2:
		_mouse_steering = true
	if event is InputEventJoypadButton and event.pressed:
		if event.button_index==JOY_BUTTON_A: _roll_request = 1.0
		if event.button_index==JOY_BUTTON_START:
			paused = not paused
			options.visible = paused
			start_button.text = "RESUME DUEL"

func player_request() -> Dictionary:
	var steer := Input.get_vector("left","right","down","up")
	if steer.length()>.1: _mouse_steering = false
	var pads := Input.get_connected_joypads()
	var pad := -1 if pads.is_empty() else int(pads[0])
	if pad>=0:
		var stick := Vector2(Input.get_joy_axis(pad,JOY_AXIS_LEFT_X),-Input.get_joy_axis(pad,JOY_AXIS_LEFT_Y))
		if stick.length()>.16:
			steer = stick.limit_length()
			_mouse_steering = false
	if _mouse_steering:
		var pointer := get_viewport().get_mouse_position()/get_viewport().get_visible_rect().size
		steer = Vector2((pointer.x-.5)*2.0,(.5-pointer.y)*2.0).limit_length()
	var request := {"steer":steer,"boost":Input.is_action_pressed("boost") or (pad>=0 and Input.is_joy_button_pressed(pad,JOY_BUTTON_RIGHT_SHOULDER)),"brake":Input.is_action_pressed("brake") or (pad>=0 and Input.is_joy_button_pressed(pad,JOY_BUTTON_LEFT_SHOULDER)),"roll":_roll_request,"fire":Input.is_action_pressed("fire") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or (pad>=0 and Input.get_joy_axis(pad,JOY_AXIS_TRIGGER_RIGHT)>.25)}
	_roll_request = 0.0
	return request

func _process(delta: float) -> void:
	_hud_clock += delta
	if mode=="flight" and not paused:
		_frame_request = player_request()
		_accumulator += minf(delta,.25)
		while _accumulator>=1.0/120.0 and mode=="flight":
			simulate(1.0/120.0,_frame_request)
			_frame_request.roll = 0.0
			_accumulator -= 1.0/120.0
		_update_rigs(delta)
		_sync_shots()
		_update_camera(minf(delta,.05))
		_refresh_status()
	overlay.queue_redraw()

func simulate(dt: float, request: Dictionary) -> void:
	if mode!="flight" or paused: return
	elapsed += dt
	event_time = maxf(0.0,event_time-dt)
	_hit_flash = maxf(0.0,_hit_flash-dt*2.0)
	var previous := [Vector3(vehicles[0].position),Vector3(vehicles[1].position)]
	observation = Pilot.sensor(vehicles[1].position,vehicles[1].forward(),vehicles[0].position,vehicles[0].velocity,weapons.shots,cover,elapsed)
	pilot.feed(observation)
	var enemy_request: Dictionary = pilot.update(dt,vehicles[1],cover,radius,ceiling)
	if _bot_player:
		request = {"steer":Pilot.steer_to(vehicles[0],Vector3(80,ceiling*.55,-90) if elapsed<8.0 else vehicles[1].position),"boost":false,"brake":false,"roll":0.0,"fire":elapsed>8.0}
	for i in range(2):
		grace[i] = maxf(0.0,float(grace[i])-dt)
		vehicles[i].step(dt,request if i==0 else enemy_request,cover,radius,ceiling)
		for event in vehicles[i].events:
			_log("vehicle",{"actor":i,"event":event})
			if str(event).begins_with("collision:"): _damage(i,18.0,"Collision with solid anchor block")
	# Relative aircraft collision has one physical outcome and a consistent separation side.
	var contact := Geometry.sphere_time(previous[0]-previous[1],vehicles[0].position-vehicles[1].position,Vector3.ZERO,8.0)
	if contact!=INF:
		for i in range(2):
			vehicles[i].position = Vector3(previous[i]).lerp(vehicles[i].position,maxf(0.0,contact-.005))
			vehicles[i].velocity = (vehicles[i].position-Vector3(previous[i]))/dt
			vehicles[i].speed = minf(12.0,vehicles[i].speed)
			_damage(i,16.0,"Aircraft collision")
	if mode!="flight": return
	var actors := [{"id":0,"position":vehicles[0].position,"previous":previous[0]},{"id":1,"position":vehicles[1].position,"previous":previous[1]}]
	for impact in weapons.step(dt,actors,cover):
		effects.spark(impact.point,Color("a1eaff") if impact.type=="cover" else Color("ffbb83"))
		_log("projectile_"+str(impact.type),{"owner":impact.owner,"target":impact.target,"shot":impact.shot,"point":vec(impact.point)})
		if int(impact.target)>=0:
			_damage(int(impact.target),float(impact.damage),"COMET's firing pass" if int(impact.owner)==0 else "Opponent's committed pass")
	if mode!="flight": return
	if bool(request.get("fire",false)) and weapons.fire(0,vehicles[0],cover):
		audio.sfx("laser")
		_log("weapon_fired",{"actor":0})
	if bool(enemy_request.fire) and weapons.fire(1,vehicles[1],cover):
		audio.sfx("laser")
		_log("weapon_fired",{"actor":1,"observation_at":pilot.last_seen})
	if pilot.state!=_last_pilot_state:
		_last_pilot_state = pilot.state
		_log("pilot_transition",pilot.transitions.back() if not pilot.transitions.is_empty() else {})
		if pilot.state=="commit":
			event_text = "Opponent committing to a pass — cross its line or use cover."
			event_time = 3.0
		elif pilot.state=="extend":
			event_text = "Opponent extending. Its missed pass leaves a counter window."
			event_time = 3.0
		elif pilot.state=="search":
			event_text = "Contact broken. Reposition around the block."
			event_time = 2.5
	_update_contact()
	if elapsed>=sample_at:
		sample_at = elapsed+.1
		_record_sample()

func _damage(actor_id: int, amount: float, source: String) -> void:
	if mode!="flight" or float(grace[actor_id])>0.0 or vehicles[actor_id].protected(): return
	hp[actor_id] = maxf(0.0,float(hp[actor_id])-amount)
	grace[actor_id] = .06 if amount<10.0 else .8
	rigs[actor_id].hit_flash()
	audio.sfx("hit")
	effects.spark(vehicles[actor_id].position,Color("ffae7e"))
	_log("damage",{"actor":actor_id,"amount":amount,"source":source,"remaining":hp[actor_id]})
	if actor_id==0: _hit_flash = .7
	if float(hp[actor_id])<=0.0:
		mode = "won" if actor_id==1 else "lost"
		event_text = "Opponent defeated" if actor_id==1 else "COMET lost: "+source
		return_text = source
		options.show()
		start_button.text = "RESTART STANDARD DUEL"
		_write_trace(mode)
		_refresh_status()

func _update_contact() -> void:
	var own: RefCounted = vehicles[0]
	var other: RefCounted = vehicles[1]
	var difference: Vector3 = other.position-own.position
	var visible_now: bool = difference.length()<260.0 and own.forward().dot(difference.normalized())>-.4 and Geometry.first_cover(own.position,other.position,cover).is_empty()
	if visible_now:
		player_contact = {"position":Vector3(other.position),"velocity":Vector3(other.velocity),"seen":elapsed}
		last_player_seen = elapsed
	if not player_contact.is_empty(): player_contact["visible"] = visible_now

func _update_rigs(dt: float) -> void:
	for i in range(2):
		var vehicle: RefCounted = vehicles[i]
		rigs[i].position = vehicle.position
		rigs[i].basis = vehicle.orientation()
		var thrust := clampf(vehicle.velocity.length()/38.0,.4,1.8)
		rigs[i].animate(elapsed,dt,vehicle.bank,0.0,thrust,vehicle.roll_angle(),_hit_flash if i==0 else 0.0)
		rigs[i].visual.rotation.z = vehicle.bank+vehicle.roll_angle()

func _update_camera(dt: float, immediate: bool = false) -> void:
	var vehicle: RefCounted = vehicles[0]
	var focus: Vector3 = vehicle.position+vehicle.forward()*18.0
	var desired: Vector3 = vehicle.position-vehicle.forward()*20.0+Vector3.UP*5.0
	var cover_hit := Geometry.first_cover(focus,desired,cover,1.0)
	var retracted := not cover_hit.is_empty()
	if retracted:
		# Sweep from aircraft towards camera, never pull the camera through a wall.
		cover_hit = Geometry.first_cover(vehicle.position,desired,cover,1.0)
		if not cover_hit.is_empty(): desired = Vector3(cover_hit.point)+Vector3(cover_hit.normal)*1.5
		if not camera_shortened: camera_retractions += 1
	camera_shortened = retracted
	desired.y = maxf(1.5,desired.y)
	var blend := 1.0 if immediate or retracted else 1.0-exp(-dt*9.0)
	camera.position = camera.position.lerp(desired,blend)
	# The smoothed segment itself must stay clear when changing sides of cover.
	var line := Geometry.first_cover(vehicle.position,camera.position,cover,.8)
	if not line.is_empty(): camera.position = Vector3(line.point)+Vector3(line.normal)*1.5
	camera.look_at(focus,Vector3.UP)
	camera.fov = 67.0 if reduced_motion else lerpf(camera.fov,67.0+(vehicle.velocity.length()-38.0)*.18,1.0-exp(-dt*4.0))
	if not reduced_motion and _hit_flash>0.0: camera.position += Vector3(sin(elapsed*33),cos(elapsed*27),0)*_hit_flash*.12
	if not player_contact.is_empty() and player_contact.get("visible",false) and camera.is_position_behind(player_contact.position): obscured_threat_time += dt

func _sync_shots() -> void:
	var living: Dictionary = {}
	for shot in weapons.shots:
		var id: int = shot.id
		living[id] = true
		if not shot_nodes.has(id):
			var mesh := MeshInstance3D.new()
			mesh.mesh = shot_mesh
			mesh.material_override = shot_materials[int(shot.owner)]
			add_child(mesh)
			shot_nodes[id] = mesh
		var node: MeshInstance3D = shot_nodes[id]
		node.position = shot.position
		node.quaternion = Quaternion(Vector3.UP,Vector3(shot.velocity).normalized())
	for id in shot_nodes.keys():
		if not living.has(id):
			shot_nodes[id].queue_free()
			shot_nodes.erase(id)

func _log(kind: String, data: Dictionary) -> void:
	if trace_events.size()<12000: trace_events.append({"at":elapsed,"kind":kind,"data":data.duplicate(true)})

func _record_sample() -> void:
	if samples.size()>=3600: return
	samples.append({"at":elapsed,"player":vehicles[0].snapshot(),"opponent":vehicles[1].snapshot(),"intent":pilot.state,"weapon_requested":pilot.intent.get("fire",false),"route":pilot.route,"reason":pilot.reason,"observed_age":minf(999.0,pilot.observed_age()),"observed_position":vec(pilot.predicted_contact()),"sight":pilot.visible,"player_hp":hp[0],"opponent_hp":hp[1]})

static func vec(value: Vector3) -> Array:
	return [value.x,value.y,value.z]

func _write_trace(outcome: String) -> void:
	if samples.is_empty(): return
	var folder := "user://duel_traces"
	DirAccess.make_dir_recursive_absolute(folder)
	trace_path = folder+"/"+run_id+".json"
	var file := FileAccess.open(trace_path,FileAccess.WRITE)
	if file==null: return
	file.store_string(JSON.stringify({"schema":1,"revision":REVISION,"profile":Vehicle.PROFILE,"volume":{"diameter":radius*2,"height":ceiling},"pitch_variant":"hold" if pitch_hold else "gradual_level","camera":{"reduced_motion":reduced_motion,"behind":20,"above":5,"fov":67},"driver":run_driver,"outcome":outcome,"duration":elapsed,"boundary_events":[vehicles[0].boundary_events,vehicles[1].boundary_events],"camera_retractions":camera_retractions,"rear_visible_seconds":obscured_threat_time,"samples":samples,"events":trace_events},"\t"))
	file.close()

func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	overlay = DuelOverlay.new()
	overlay.game = self
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(overlay)
	options = PanelContainer.new()
	options.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	options.position = Vector2(-420,-270)
	options.size = Vector2(840,540)
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(.018,.045,.07,.97)
	panel.border_color = Color("75b8c6")
	panel.set_border_width_all(1)
	panel.set_content_margin_all(25)
	options.add_theme_stylebox_override("panel",panel)
	canvas.add_child(options)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation",12)
	options.add_child(stack)
	var title := Label.new()
	title.text = "ANCHORAGE / FLIGHT PRACTICE"
	title.add_theme_font_size_override("font_size",27)
	stack.add_child(title)
	status = Label.new()
	status.custom_minimum_size = Vector2(760,135)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.add_theme_font_size_override("font_size",18)
	stack.add_child(status)
	var settings := HBoxContainer.new()
	settings.add_theme_constant_override("separation",12)
	stack.add_child(settings)
	var volume := OptionButton.new()
	volume.add_item("600 × 600 × 76 / LOW")
	volume.add_item("640 × 640 × 160 / TALL")
	volume.select(volume_index)
	volume.item_selected.connect(func(index: int):
		volume_index = index
		_reset()
	)
	settings.add_child(volume)
	var control := OptionButton.new()
	control.add_item("PITCH HOLD")
	control.add_item("GRADUAL LEVEL")
	control.select(0 if pitch_hold else 1)
	control.item_selected.connect(func(index: int):
		pitch_hold = index==0
		_reset()
	)
	settings.add_child(control)
	var motion := CheckButton.new()
	motion.text = "Reduced camera motion"
	motion.button_pressed = reduced_motion
	motion.toggled.connect(func(value: bool): reduced_motion = value)
	stack.add_child(motion)
	start_button = Button.new()
	start_button.text = "START STANDARD DUEL"
	start_button.custom_minimum_size.y = 44
	start_button.pressed.connect(func():
		if paused:
			paused = false
			options.hide()
		elif mode in ["won","lost"]:
			_reset()
			_start()
		else: _start()
	)
	stack.add_child(start_button)
	var restart := Button.new()
	restart.text = "RESET ENCOUNTER / F5"
	restart.pressed.connect(func(): _reset())
	stack.add_child(restart)
	var back := Button.new()
	back.text = "RETURN TO FLIGHT DECK"
	back.pressed.connect(func():
		_write_trace("return_to_deck")
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	)
	stack.add_child(back)
	start_button.grab_focus()

func _refresh_status() -> void:
	if not options.visible: return
	if mode=="briefing":
		status.text = "STANDARD DUEL / COMET against one opponent\nClimb, dive and use the solid anchor block to break sight. Bait a committed pass, then counter its recovery. Both ships use the same flight and weapon limits.\nWASD/arrows or stick: turn and pitch. SPACE/LMB/RT: lasers. SHIFT/RB: boost. CTRL/LB: brake. Q/E/A: roll. ESC/Start: pause. F5: reset."
	elif paused:
		status.text = "FLIGHT PAUSED\nResume the same duel, or reset to compare the two volumes and pitch behaviors.\nF3: optional measurement overlay. F8: save current trace."
	else:
		status.text = ("DUEL WON / Counter completed" if mode=="won" else "DUEL LOST / "+return_text)+"\nTime %.1fs / COMET %.0f shield / opponent %.0f shield.\nReset uses the same staging, cover and vehicle profile. A human playtest is still needed to judge feel and readability." % [elapsed,hp[0],hp[1]]

func draw_overlay(surface: Control) -> void:
	var size: Vector2 = surface.size
	var scale_value := minf(size.x/1280.0,size.y/720.0)
	var font := ThemeDB.fallback_font
	var player: RefCounted = vehicles[0]
	var center := size*.5
	var paper := Color("e5f5f3")
	var cyan := Color("83e4ed")
	var amber := Color("ffc47b")
	var left := Vector2(24,27)*scale_value
	surface.draw_style_box(_hud_panel(),Rect2(Vector2(12,12)*scale_value,Vector2(370,115)*scale_value))
	surface.draw_string(font,left,"COMET / SHIELD %03d   ENGINE %03d" % [hp[0],player.energy],HORIZONTAL_ALIGNMENT_LEFT,-1,17*scale_value,paper)
	surface.draw_string(font,left+Vector2(0,27)*scale_value,"SPEED %02d   ALT %03d / %03d" % [player.velocity.length(),player.position.y,ceiling],HORIZONTAL_ALIGNMENT_LEFT,-1,15*scale_value,cyan)
	surface.draw_string(font,left+Vector2(0,52)*scale_value,"ROLL READY" if player.roll_wait<=0.0 else "ROLL %.1fs" % player.roll_wait,HORIZONTAL_ALIGNMENT_LEFT,-1,14*scale_value,amber)
	surface.draw_string(font,left+Vector2(0,76)*scale_value,"PITCH HOLD" if pitch_hold else "GRADUAL LEVEL",HORIZONTAL_ALIGNMENT_LEFT,-1,13*scale_value,paper)
	var text := "ANCHORAGE PRACTICE / STANDARD"
	surface.draw_string(font,Vector2(size.x*.5-180*scale_value,30*scale_value),text,HORIZONTAL_ALIGNMENT_LEFT,-1,18*scale_value,paper)
	# Reticle follows the actual weapon axis, including pitch and muzzle offset.
	var point: Vector2 = camera.unproject_position(player.position+player.forward()*110.0)
	for direction in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
		surface.draw_line(point+direction*7*scale_value,point+direction*18*scale_value,cyan,1.5,true)
	surface.draw_circle(point,2*scale_value,paper)
	var contact_visible := not player_contact.is_empty() and bool(player_contact.get("visible",false))
	if not player_contact.is_empty() and elapsed-last_player_seen<9.0:
		var point3: Vector3 = player_contact.position
		var delta: Vector3 = point3-player.position
		var height := "ABOVE +%d" % delta.y if delta.y>6 else ("BELOW %d" % delta.y if delta.y< -6 else "LEVEL")
		var age := elapsed-last_player_seen
		var label := "CONTACT / "+height if contact_visible else "LAST SEEN %.1fs / %s" % [age,height]
		var local_point: Vector3 = player.orientation().inverse()*delta
		var target_screen: Vector2 = camera.unproject_position(point3)
		var behind := camera.is_position_behind(point3)
		if behind or target_screen.x<45 or target_screen.x>size.x-45 or target_screen.y<80 or target_screen.y>size.y-100:
			# Edge cue uses only the stored contact; stale contact never tracks truth.
			var side := -1.0 if local_point.x<0.0 else 1.0
			target_screen = Vector2(45*scale_value if side<0.0 else size.x-45*scale_value,size.y*.48)
			label = ("REAR / TURN LEFT" if side<0.0 else "REAR / TURN RIGHT")+" / "+height if behind else label
			var triangle := PackedVector2Array([target_screen+Vector2(side*9,0)*scale_value,target_screen+Vector2(-side*7,-8)*scale_value,target_screen+Vector2(-side*7,8)*scale_value])
			surface.draw_colored_polygon(triangle,amber if contact_visible else Color("c6d8e1"))
		var color := amber if contact_visible else Color("c6d8e1")
		if not behind:
			surface.draw_circle(target_screen,19*scale_value,Color(.01,.03,.05,.9),false,4.0,true)
			surface.draw_circle(target_screen,19*scale_value,color,false,1.4,true)
			if not contact_visible:
				surface.draw_line(target_screen-Vector2(9,9)*scale_value,target_screen+Vector2(9,9)*scale_value,color,1.3,true)
		if not contact_visible and behind: label = "LAST SEEN / "+label
		var tx := clampf(target_screen.x-100*scale_value,15*scale_value,size.x-260*scale_value)
		var ty := clampf(target_screen.y-32*scale_value,80*scale_value,size.y-110*scale_value)
		surface.draw_style_box(_hud_panel(),Rect2(Vector2(tx-5*scale_value,ty-19*scale_value),Vector2(minf(285.0,float(label.length())*8.2+10.0),26)*scale_value))
		surface.draw_string(font,Vector2(tx,ty),label,HORIZONTAL_ALIGNMENT_LEFT,-1,14*scale_value,color)
		if contact_visible:
			surface.draw_string(font,Vector2(size.x-245*scale_value,31*scale_value),"OPPONENT / %03d SHIELD" % hp[1],HORIZONTAL_ALIGNMENT_LEFT,-1,15*scale_value,amber)
	var warning := ""
	if player.boundary: warning = "BOUNDARY RECOVERY / BRAKING AND TURNING INWARD"
	elif player.warning(radius,ceiling): warning = "PERIMETER / LEAVE ROOM FOR YOUR TURN"
	elif event_time>0.0: warning = event_text
	if not warning.is_empty():
		surface.draw_style_box(_hud_panel(),Rect2(Vector2(260,581)*scale_value,Vector2(760,40)*scale_value))
		surface.draw_string(font,Vector2(275,608)*scale_value,warning,HORIZONTAL_ALIGNMENT_LEFT,-1,16*scale_value,amber)
	surface.draw_string(font,Vector2(24,size.y/scale_value-24)*scale_value,"WASD pitch/turn · SPACE fire · SHIFT boost · CTRL brake · Q/E roll · F5 reset · ESC pause",HORIZONTAL_ALIGNMENT_LEFT,-1,14*scale_value,paper)
	# A stable level datum and pitch ladder make altitude useful without a full cockpit.
	var datum := Vector2(size.x*.5,size.y*.5+player.pitch*110*scale_value)
	surface.draw_line(datum-Vector2(110,0)*scale_value,datum-Vector2(65,0)*scale_value,Color(cyan,.45),1.0)
	surface.draw_line(datum+Vector2(65,0)*scale_value,datum+Vector2(110,0)*scale_value,Color(cyan,.45),1.0)
	if _hit_flash>0.0: surface.draw_rect(Rect2(Vector2.ZERO,size),Color(1,.2,.1,_hit_flash*.65),false,8*scale_value)
	if debug_view:
		var detail := "DEV / %s / %s / observed %.2fs\nSpeed %.2f / turn %.3f rad/s / energy %.1f\nRoute: %s / denied: %s\nF8 saves a trace with the run configuration" % [pilot.state,pilot.reason,minf(999,pilot.observed_age()),player.velocity.length(),player.angular_rate,player.energy,pilot.route,player.denied]
		surface.draw_style_box(_hud_panel(),Rect2(Vector2(20,150)*scale_value,Vector2(790,118)*scale_value))
		surface.draw_multiline_string(font,Vector2(30,174)*scale_value,detail,HORIZONTAL_ALIGNMENT_LEFT,-1,14*scale_value,-1,cyan)

func _hud_panel() -> StyleBoxFlat:
	var out := StyleBoxFlat.new()
	out.bg_color = Color(.015,.04,.06,.8)
	return out

func _exit_tree() -> void:
	if is_instance_valid(overlay): overlay.game = null
	weapons.reset()
	shot_nodes.clear()
	if is_instance_valid(audio): audio.stop_music()
