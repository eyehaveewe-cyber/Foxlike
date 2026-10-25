extends Node3D
## A quiet local orbit with independent simulation and ship clocks.
const Navigation = preload("res://scripts/orbit/orbit_navigation.gd")
const Station = preload("res://scripts/orbit/orbit_station.gd")
const Asteroids = preload("res://scripts/orbit/orbit_asteroids.gd")
const Ship = preload("res://scripts/ship_model.gd")
const PLANET_SHADER = preload("res://shaders/orbit/planet.gdshader")
const CLOUD_SHADER = preload("res://shaders/orbit/clouds.gdshader")
const ATMOSPHERE_SHADER = preload("res://shaders/orbit/atmosphere.gdshader")
const STAR_SHADER = preload("res://shaders/orbit/stars.gdshader")
const PLANET_CENTER := Vector3(200,-5300,-6900)
const PLANET_RADIUS := 6000.0
const SUN_DIRECTION := Vector3(-.85,.22,.42)
var navigation := Navigation.new()
var station: Node3D
var asteroids: Node3D
var ship: Node3D
var camera: Camera3D
var planet: MeshInstance3D
var clouds: MeshInstance3D
var atmosphere: MeshInstance3D
var moon: MeshInstance3D
var planet_material: ShaderMaterial
var cloud_material: ShaderMaterial
var clock := 0.0
var ship_clock := 0.0
var time_scale := 1.0
var paused := false
var cinematic := false
var camera_mode := 0
var camera_orbit := 0.0
var mouse_turn := Vector2.ZERO
var hud: Control
var panel: PanelContainer
var audio: AudioStreamPlayer
var _sample_accumulator := 0.0

class OrbitOverlay extends Control:
	var hub: Node3D
	func _ready() -> void: mouse_filter = Control.MOUSE_FILTER_IGNORE
	func _draw() -> void:
		if is_instance_valid(hub) and not hub.cinematic and not hub.paused: hub.draw_hud(self)

func _ready() -> void:
	_build_environment()
	_build_planet()
	station = Station.new()
	add_child(station)
	station.setup()
	asteroids = Asteroids.new()
	add_child(asteroids)
	asteroids.setup()
	ship = Ship.new()
	add_child(ship)
	ship.setup("player",Color("d8e5eb"))
	camera = Camera3D.new()
	camera.near = .25
	camera.far = 80000.0
	camera.fov = 65.0
	camera.current = true
	add_child(camera)
	_build_ui()
	audio = AudioStreamPlayer.new()
	var track := load("res://assets/audio/orbit_ambience.ogg") as AudioStreamOggVorbis
	track.loop = true
	audio.stream = track
	audio.volume_db = -80.0 if bool(get_tree().get_meta("orbit_muted",false)) else -22.0
	add_child(audio)
	audio.play()
	navigation.reset()
	_update_ship(0.0)
	_update_camera(1.0,true)

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ShaderMaterial.new()
	sky_material.shader = STAR_SHADER
	sky.sky_material = sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("7094b4")
	environment.ambient_light_energy = .3
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 1.2
	var world := WorldEnvironment.new()
	world.environment = environment
	add_child(world)
	var sun := DirectionalLight3D.new()
	add_child(sun)
	sun.look_at(-SUN_DIRECTION.normalized(),Vector3.UP)
	sun.light_color = Color("fff0d8")
	sun.light_energy = 2.5
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 900.0
	var fill := DirectionalLight3D.new()
	add_child(fill)
	fill.look_at(Vector3(.4,-.5,-.7),Vector3.UP)
	fill.light_color = Color("699cd4")
	fill.light_energy = .35

func _sphere(radius: float, point: Vector3, material: Material, segments: int = 128, rows: int = 64) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius*2.0
	mesh.radial_segments = segments
	mesh.rings = rows
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.position = point
	instance.material_override = material
	add_child(instance)
	return instance

func _build_planet() -> void:
	planet_material = ShaderMaterial.new()
	planet_material.shader = PLANET_SHADER
	planet_material.set_shader_parameter("sun_direction",SUN_DIRECTION)
	planet = _sphere(PLANET_RADIUS,PLANET_CENTER,planet_material)
	cloud_material = ShaderMaterial.new()
	cloud_material.shader = CLOUD_SHADER
	cloud_material.set_shader_parameter("sun_direction",SUN_DIRECTION)
	clouds = _sphere(PLANET_RADIUS*1.003,PLANET_CENTER,cloud_material)
	var air := ShaderMaterial.new()
	air.shader = ATMOSPHERE_SHADER
	air.set_shader_parameter("sun_direction",SUN_DIRECTION)
	atmosphere = _sphere(PLANET_RADIUS*1.014,PLANET_CENTER,air)
	var moon_material := StandardMaterial3D.new()
	moon_material.albedo_color = Color("939fa7")
	moon_material.roughness = 1.0
	moon = _sphere(260.0,Vector3(-5400,1800,-16000),moon_material,48,24)
	# A distant sun is a lit visual landmark; the directional light owns shading.
	var sun_material := StandardMaterial3D.new()
	sun_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sun_material.albedo_color = Color("fff1cd")
	_sphere(230.0,SUN_DIRECTION.normalized()*22000.0,sun_material,48,24)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_RIGHT:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if event.pressed and not paused else Input.MOUSE_MODE_VISIBLE
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_ESCAPE:
				paused = not paused
				panel.visible = paused
				if paused: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			KEY_F11:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)
			KEY_I: navigation.engines_on = not navigation.engines_on
			KEY_H:
				navigation.assist = not navigation.assist
			KEY_F2: camera_mode = (camera_mode+1)%3
			KEY_F3: cinematic = not cinematic
			KEY_M: audio.volume_db = -22.0 if audio.volume_db< -50 else -80.0
			KEY_B: asteroids.set_enabled(not asteroids.enabled)
			KEY_J: admit_visitor()
			KEY_HOME: return_to_station()
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and not paused:
		mouse_turn += Vector2(event.relative.x,-event.relative.y)*.0024
	if event is InputEventJoypadButton and event.pressed:
		match event.button_index:
			JOY_BUTTON_START:
				paused = not paused
				panel.visible = paused
			JOY_BUTTON_Y: navigation.assist = not navigation.assist
			JOY_BUTTON_X: camera_mode = (camera_mode+1)%3
			JOY_BUTTON_BACK: cinematic = not cinematic
			JOY_BUTTON_B: return_to_station()

func _key(code: Key) -> float: return 1.0 if Input.is_physical_key_pressed(code) else 0.0

func input_request(dt: float) -> Dictionary:
	var move := Vector3(_key(KEY_D)-_key(KEY_A),_key(KEY_E)-_key(KEY_Q),_key(KEY_S)-_key(KEY_W))
	var turn := Vector2(_key(KEY_RIGHT)-_key(KEY_LEFT),_key(KEY_UP)-_key(KEY_DOWN))
	var pads := Input.get_connected_joypads()
	var pad := -1 if pads.is_empty() else int(pads[0])
	if pad>=0:
		var stick := Vector2(Input.get_joy_axis(pad,JOY_AXIS_LEFT_X),Input.get_joy_axis(pad,JOY_AXIS_LEFT_Y))
		if stick.length()>.16: move = Vector3(stick.x,0,stick.y)
		var look := Vector2(Input.get_joy_axis(pad,JOY_AXIS_RIGHT_X),-Input.get_joy_axis(pad,JOY_AXIS_RIGHT_Y))
		if look.length()>.16: turn = look
		move.y = float(Input.is_joy_button_pressed(pad,JOY_BUTTON_RIGHT_SHOULDER))-float(Input.is_joy_button_pressed(pad,JOY_BUTTON_LEFT_SHOULDER))
	if mouse_turn.length()>0.0:
		navigation.heading -= mouse_turn.x
		navigation.pitch = clampf(navigation.pitch+mouse_turn.y,-1.3,1.3)
		mouse_turn = Vector2.ZERO
	return {"move":move,"turn":turn,"boost":Input.is_physical_key_pressed(KEY_SHIFT) or (pad>=0 and Input.get_joy_axis(pad,JOY_AXIS_TRIGGER_RIGHT)>.4),"brake":Input.is_physical_key_pressed(KEY_SPACE) or (pad>=0 and Input.get_joy_axis(pad,JOY_AXIS_TRIGGER_LEFT)>.4)}

func _process(delta: float) -> void:
	if paused: return
	var dt := minf(delta,.1)
	simulate(dt,input_request(dt))
	_update_ship(dt)
	_update_camera(dt)
	hud.queue_redraw()

func simulate(dt: float, request: Dictionary) -> void:
	if paused: return
	ship_clock += dt
	clock += dt*time_scale
	planet_material.set_shader_parameter("spin",clock*.00022)
	cloud_material.set_shader_parameter("spin",clock*.00031+.12)
	moon.position = Vector3(-5400+sin(clock*.0006)*1100,1800+cos(clock*.0006)*250,-16000)
	moon.rotation.y = clock*.0002
	station.advance(dt*time_scale,clock)
	asteroids.advance(dt*time_scale,navigation.position,station)
	navigation.advance(dt,request,station,asteroids.visitors if asteroids.enabled else [])

func _update_ship(dt: float) -> void:
	ship.position = navigation.position
	ship.basis = navigation.basis()
	var local_velocity := navigation.basis().inverse()*navigation.velocity
	var thrust := (.12+minf(1.5,navigation.velocity.length()/55.0)) if navigation.engines_on else 0.0
	ship.animate(ship_clock,dt,-local_velocity.x*.003,0,thrust)
	for flame in ship._flames: flame.visible = navigation.engines_on
	# A visual hover oscillation never moves the collision body or changes the held point.
	ship.visual.position.y = sin(ship_clock*.7)*.075

func _update_camera(dt: float, immediate: bool = false) -> void:
	var target: Vector3
	var desired: Vector3
	match camera_mode:
		0:
			desired = navigation.position+navigation.basis()*Vector3(0,4.5,23)
			target = navigation.position-navigation.basis().z*40.0
		1:
			camera_orbit += dt*.025
			desired = navigation.position+Vector3(sin(camera_orbit)*32,13,cos(camera_orbit)*32)
			target = navigation.position+Vector3(0,1,0)
		2:
			# Observatory view includes the local ship and the broad planetary limb.
			desired = navigation.position+Vector3(100,75,230)
			target = navigation.position+Vector3(0,-105,-280)
	var next := camera.position.lerp(desired,1.0 if immediate else 1.0-exp(-dt*4.0))
	if station.blocked(navigation.position,next,1.0):
		# Shorten the arm using actual hull safety volumes; the ship stays put.
		for i in range(24,0,-1):
			var candidate := navigation.position.lerp(next,float(i)/24.0)
			if not station.blocked(navigation.position,candidate,1.0):
				next = candidate
				break
	camera.position = next
	camera.look_at(target,Vector3.UP)

func admit_visitor() -> bool:
	# An explicit visitor appears ahead, beyond the station and away from the ship.
	for distance in [450.0,650.0,850.0,1050.0]:
		var point: Vector3 = navigation.position-navigation.basis().z*distance+navigation.basis().x*70.0
		var radial := Vector2(point.x,point.z).length()
		if radial>=390.0 and radial<=1500.0:
			return asteroids.spawn(navigation.position,false,point)
	return asteroids.spawn(navigation.position)

func return_to_station() -> void:
	# Explicit user-requested reset, never a hidden boundary teleport.
	navigation.reset()
	camera_mode = 0
	_update_ship(0.0)
	_update_camera(1.0,true)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = OrbitOverlay.new()
	hud.hub = self
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(hud)
	panel = PanelContainer.new()
	panel.position = Vector2(340,135)
	panel.size = Vector2(600,450)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(.014,.035,.055,.96)
	style.set_content_margin_all(25)
	panel.add_theme_stylebox_override("panel",style)
	layer.add_child(panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation",12)
	panel.add_child(stack)
	var title := Label.new()
	title.text = "VIRIDIA / QUIET ORBIT"
	title.add_theme_font_size_override("font_size",26)
	stack.add_child(title)
	var note := Label.new()
	note.text = "Linger at the observatory, drift over Viridia,\nor visit the outer asteroid field."
	stack.add_child(note)
	_button(stack,"RESUME ORBIT",func(): paused = false; panel.hide())
	_button(stack,"RETURN SHIP TO STATION / HOME",return_to_station)
	_button(stack,"SOUND ON / OFF / M",func(): audio.volume_db = -22.0 if audio.volume_db< -50 else -80.0)
	_button(stack,"ENGINE ON / OFF / I",func(): navigation.engines_on = not navigation.engines_on)
	_button(stack,"CHANGE VIEW / F2",func(): camera_mode = (camera_mode+1)%3)
	_button(stack,"ASTEROID VISITORS / B",func(): asteroids.set_enabled(not asteroids.enabled))
	var pace := HSlider.new()
	pace.min_value = 0.0
	pace.max_value = 8.0
	pace.step = .25
	pace.value = 1.0
	pace.tooltip_text = "Orbit time: 0 to8. Ship handling stays the same."
	pace.value_changed.connect(func(value: float): time_scale = value)
	stack.add_child(pace)
	var text := Label.new()
	text.text = "Orbit time / pause or accelerate the planet and visitors"
	stack.add_child(text)
	_button(stack,"RETURN TO FLIGHT DECK",func(): get_tree().change_scene_to_file("res://scenes/main.tscn"))
	panel.hide()
	get_viewport().size_changed.connect(_resize_ui)
	_resize_ui()

func _button(parent: Node, text_value: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size.y = 35
	button.pressed.connect(action)
	parent.add_child(button)

func _resize_ui() -> void:
	var view := get_viewport().get_visible_rect().size
	var factor := minf(1.0,minf(view.x/1280.0,view.y/720.0))
	panel.scale = Vector2.ONE*factor
	panel.position = (view-panel.size*factor)*.5

func draw_hud(surface: Control) -> void:
	var size: Vector2 = surface.size
	var factor := minf(size.x/1280.0,size.y/720.0)
	var font := ThemeDB.fallback_font
	var color := Color("d1e8ec")
	var plate := StyleBoxFlat.new()
	plate.bg_color = Color(.012,.028,.045,.7)
	surface.draw_style_box(plate,Rect2(Vector2(24,24)*factor,Vector2(346,89)*factor))
	surface.draw_string(font,Vector2(40,49)*factor,"VIRIDIA / ORBITAL OBSERVATORY",HORIZONTAL_ALIGNMENT_LEFT,-1,17*factor,color)
	surface.draw_string(font,Vector2(40,76)*factor,"%.1f m/s   /   %s" % [navigation.velocity.length(),navigation.status],HORIZONTAL_ALIGNMENT_LEFT,-1,13*factor,Color("84cfd7"))
	surface.draw_string(font,Vector2(40,98)*factor,"%d visitors   ·   orbit time ×%.2f" % [asteroids.visitors.size() if asteroids.enabled else 0,time_scale],HORIZONTAL_ALIGNMENT_LEFT,-1,12*factor,color)
	surface.draw_style_box(plate,Rect2(Vector2(24,size.y/factor-75)*factor,Vector2(1050,53)*factor))
	surface.draw_string(font,Vector2(38,size.y/factor-53)*factor,"W/S thrust · A/D strafe · Q/E descend/rise · arrows or RMB-drag look · SHIFT boost · SPACE brake",HORIZONTAL_ALIGNMENT_LEFT,-1,13*factor,color)
	surface.draw_string(font,Vector2(38,size.y/factor-32)*factor,"I engine · H assist · F2 view · F3 hide interface · B visitors · J add asteroid · HOME station · M sound · ESC options",HORIZONTAL_ALIGNMENT_LEFT,-1,12*factor,Color("84cfd7"))

func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if is_instance_valid(hud): hud.hub = null
	if is_instance_valid(audio): audio.stop()
