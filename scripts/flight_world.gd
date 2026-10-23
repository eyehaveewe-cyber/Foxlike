class_name FoxFlightWorld
extends Node3D
## A bounded, entirely procedural scenery layer. Forward flight is -Z; scenery
## streams +Z. No decorative object participates in gameplay collision.

const CHUNK_LENGTH: float = 160.0
const CHUNK_COUNT: int = 7
const TAU_F: float = PI * 2.0
var stage: int = 0
var _chunks: Array[Node3D] = []
var _rotors: Array[Node3D] = []
var _details: Array[Node3D] = []
var _rng := RandomNumberGenerator.new()
var _clock: float = 0.0
var _low_detail: bool = false
var _sun: MeshInstance3D
var _water: MeshInstance3D
var _beacons: Array[MeshInstance3D] = []
var _mat: Dictionary = {}
var _arena_root: Node3D
const ARENA_RADIUS: float = 210.0

func setup(new_stage: int) -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_chunks.clear()
	_rotors.clear()
	_details.clear()
	_beacons.clear()
	_mat.clear()
	_sun = null
	_water = null
	_arena_root = null
	_clock = 0.0
	stage = clampi(new_stage, 0, 5)
	_rng.seed = 38229 + stage * 997
	_build_lighting()
	match stage:
		0: _build_viridia_background()
		1: _build_aurora_background()
		2: _build_terminus_background()
		3: _build_cinder_background()
		4: _build_anchorage()
		5: _build_tempest_background()
	if stage == 4:
		set_low_detail(_low_detail)
		return
	for i in range(CHUNK_COUNT):
		var chunk := Node3D.new()
		chunk.name = "Scenery_%02d" % i
		chunk.position.z = 80.0 - float(i) * CHUNK_LENGTH
		add_child(chunk)
		_chunks.append(chunk)
		match stage:
			0: _coastal_chunk(chunk, i)
			1: _asteroid_chunk(chunk, i)
			2: _fortress_chunk(chunk, i)
			3: _cinder_chunk(chunk, i)
			5: _tempest_chunk(chunk, i)
	set_low_detail(_low_detail)

func advance(delta: float, speed: float, flight_time: float) -> void:
	_clock += delta
	for chunk in _chunks:
		chunk.position.z += maxf(0.0, speed) * delta
		while chunk.position.z > CHUNK_LENGTH + 80.0:
			chunk.position.z -= CHUNK_LENGTH * float(CHUNK_COUNT)
	for i in range(_rotors.size()):
		var rotor: Node3D = _rotors[i]
		rotor.rotate_z(delta * (0.06 + float(i % 3) * 0.025) * (-1.0 if i % 2 == 0 else 1.0))
	for i in range(_beacons.size()):
		_beacons[i].visible = sin(flight_time * 3.3 + float(i) * 0.8) > -0.65

func set_arena_view(player_position: Vector3, heading: float) -> void:
	# Gameplay owns the arena position and heading. Scenery only follows its view.
	if stage != 4 or not is_instance_valid(_arena_root):
		return
	var inverse_yaw := Basis(Vector3.UP, -heading)
	_arena_root.transform = Transform3D(inverse_yaw, inverse_yaw * -player_position + Vector3(0, 0, 5))

func set_low_detail(enabled: bool) -> void:
	_low_detail = enabled
	for detail in _details:
		detail.visible = not enabled

func _material(key: String, color: Color, glow: float = 0.0, metal: float = 0.0) -> StandardMaterial3D:
	if _mat.has(key):
		return _mat[key] as StandardMaterial3D
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metal
	material.roughness = 0.7 if metal == 0.0 else 0.44
	if glow > 0.0:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = glow
	_mat[key] = material
	return material

func _mesh(parent: Node3D, mesh: Mesh, material: Material, at: Vector3, size: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = at
	instance.scale = size
	parent.add_child(instance)
	return instance

func _box(parent: Node3D, at: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	return _mesh(parent, BoxMesh.new(), material, at, size)

func _sphere(parent: Node3D, at: Vector3, radius: float, material: Material, segments: int = 24) -> MeshInstance3D:
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	sphere.radial_segments = segments
	sphere.rings = maxi(8, segments / 2)
	return _mesh(parent, sphere, material, at)

func _torus(parent: Node3D, at: Vector3, inner: float, outer: float, material: Material) -> MeshInstance3D:
	var torus := TorusMesh.new()
	torus.inner_radius = inner
	torus.outer_radius = outer
	torus.rings = 48
	torus.ring_segments = 8
	return _mesh(parent, torus, material, at)

func _instances(parent: Node3D, mesh: Mesh, material: Material, transforms: Array[Transform3D]) -> MultiMeshInstance3D:
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = mesh
	multi.instance_count = transforms.size()
	for i in range(transforms.size()):
		multi.set_instance_transform(i, transforms[i])
	var result := MultiMeshInstance3D.new()
	result.multimesh = multi
	result.material_override = material
	parent.add_child(result)
	return result

func _transform(at: Vector3, size: Vector3, turn: float = 0.0) -> Transform3D:
	return Transform3D(Basis(Vector3.UP, turn).scaled(size), at)

func _build_lighting() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_curve = 0.25
	sky_material.ground_curve = 0.2
	if stage == 0:
		sky_material.sky_top_color = Color("152e56")
		sky_material.sky_horizon_color = Color("f9b373")
		sky_material.ground_bottom_color = Color("152b3d")
		sky_material.ground_horizon_color = Color("bf7b67")
		environment.ambient_light_color = Color("a4bbdf")
		environment.ambient_light_energy = 0.75
		environment.fog_enabled = true
		environment.fog_light_color = Color("d79775")
		environment.fog_density = 0.0018
		environment.fog_sky_affect = 0.12
	elif stage == 1:
		sky_material.sky_top_color = Color("020611")
		sky_material.sky_horizon_color = Color("122440")
		sky_material.ground_bottom_color = Color("040918")
		sky_material.ground_horizon_color = Color("122440")
		environment.ambient_light_color = Color("8faee7")
		environment.ambient_light_energy = 0.7
		environment.fog_enabled = true
		environment.fog_light_color = Color("101c38")
		environment.fog_density = 0.00065
		environment.fog_sky_affect = 0.0
	elif stage == 2:
		sky_material.sky_top_color = Color("060a1c")
		sky_material.sky_horizon_color = Color("352c48")
		sky_material.ground_bottom_color = Color("101b30")
		sky_material.ground_horizon_color = Color("503c51")
		environment.ambient_light_color = Color("a3b5e1")
		environment.ambient_light_energy = 0.85
		environment.fog_enabled = true
		environment.fog_light_color = Color("282438")
		environment.fog_density = 0.001
		environment.fog_sky_affect = 0.0
	elif stage == 3:
		sky_material.sky_top_color = Color("493842")
		sky_material.sky_horizon_color = Color("f4b47a")
		sky_material.ground_bottom_color = Color("57392d")
		sky_material.ground_horizon_color = Color("bd8057")
		environment.ambient_light_color = Color("edbd9b")
		environment.ambient_light_energy = 0.85
		environment.fog_enabled = true
		environment.fog_light_color = Color("b98967")
		environment.fog_density = 0.0016
		environment.fog_sky_affect = 0.05
	elif stage == 4:
		sky_material.sky_top_color = Color("091128")
		sky_material.sky_horizon_color = Color("285471")
		sky_material.ground_bottom_color = Color("0d2442")
		sky_material.ground_horizon_color = Color("285471")
		environment.ambient_light_color = Color("b6d7ee")
		environment.ambient_light_energy = 0.95
		environment.fog_enabled = true
		environment.fog_light_color = Color("17354d")
		environment.fog_density = 0.0006
		environment.fog_sky_affect = 0.0
	else:
		sky_material.sky_top_color = Color("15162e")
		sky_material.sky_horizon_color = Color("557b85")
		sky_material.ground_bottom_color = Color("1e3549")
		sky_material.ground_horizon_color = Color("6f8b9b")
		environment.ambient_light_color = Color("b6c7ee")
		environment.ambient_light_energy = 0.9
		environment.fog_enabled = true
		environment.fog_light_color = Color("49647d")
		environment.fog_density = 0.0017
		environment.fog_sky_affect = 0.15
	sky_material.sun_angle_max = 9.0
	sky_material.sun_curve = 0.13
	sky.sky_material = sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 1.12
	var world := WorldEnvironment.new()
	world.environment = environment
	add_child(world)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-23, -28, 0) if stage == 0 else Vector3(-38, -38, -6)
	key.light_color = Color("ffd5a2") if stage in [0, 3] else Color("bbd8ff")
	key.light_energy = 1.8 if stage == 0 else 1.6
	key.shadow_enabled = false
	add_child(key)
	var rim := DirectionalLight3D.new()
	rim.rotation_degrees = Vector3(20, 145, -10)
	rim.light_color = Color("5a94c9") if stage != 2 else Color("f1795b")
	rim.light_energy = 0.65
	rim.shadow_enabled = false
	add_child(rim)

func _build_viridia_background() -> void:
	var ocean_shader := Shader.new()
	ocean_shader.code = """shader_type spatial;
render_mode cull_disabled, unshaded, fog_disabled;
uniform vec4 deep_color : source_color = vec4(0.025,0.17,0.21,1.0);
varying vec3 wp;
void vertex() { wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
 float a = sin(wp.x * 0.12 + wp.z * 0.027 + TIME * 0.8);
 float b = sin(wp.z * 0.30 - TIME * 1.8 + sin(wp.x * 0.075) * 2.0);
 float wave = pow(max(0.0, a * 0.35 + b * 0.65), 4.0);
 float path = exp(-pow((wp.x - 82.0) / (22.0 + abs(wp.z) * 0.12), 2.0));
 ALBEDO = deep_color.rgb + vec3(0.12,0.28,0.29) * wave + vec3(0.48,0.23,0.08) * path * (0.08 + wave);
 METALLIC = 0.45; ROUGHNESS = 0.36;
 EMISSION = vec3(0.5,0.24,0.1) * path * wave * 0.3;
} """
	var ocean_mat := ShaderMaterial.new()
	ocean_mat.shader = ocean_shader
	var plane := PlaneMesh.new()
	plane.size = Vector2(2200, 2400)
	_water = _mesh(self, plane, ocean_mat, Vector3(0, -17, -700))
	_sun = _sphere(self, Vector3(210, 120, -800), 64, _material("sun", Color("ffe8aa"), 1.5), 32)
	var horizon := _material("horizon", Color("52646e"))
	for side in [-1, 1]:
		for i in range(9):
			var at := Vector3(float(side) * (170.0 + float(i) * 50.0), -26, -520 - float(i % 3) * 65)
			var mountain := _pyramid(_rng.randf_range(90, 180), _rng.randf_range(80, 170), _rng.randf_range(150, 260))
			_mesh(self, mountain, horizon, at)
	# High altitude clouds are broad low-poly forms, never navigation obstacles.
	var cloud_material := _material("cloud", Color("d6b5a0"))
	for i in range(10):
		_sphere(self, Vector3(-430 + i * 100, 135 + _rng.randf_range(0, 50), -800 - _rng.randf_range(0, 100)), 35, cloud_material, 12).scale = Vector3(2.2, 0.15, 0.7)

func _coastal_chunk(chunk: Node3D, index: int) -> void:
	var rock := _material("rock", Color("3d6967"))
	var rock_top := _material("rock_top", Color("658877"))
	var wall := _material("city_wall", Color("486170"), 0.0, 0.2)
	var dark_wall := _material("city_shadow", Color("2b414f"), 0.0, 0.2)
	var ivory := _material("ivory", Color("b6b8a6"), 0.0, 0.2)
	var windows := _material("warm_windows", Color("ffc382"), 1.3)
	var guide := _material("guide", Color("5de4d6"), 1.5)
	var building_transforms: Array[Transform3D] = []
	var dark_transforms: Array[Transform3D] = []
	var window_transforms: Array[Transform3D] = []
	var details := Node3D.new()
	chunk.add_child(details)
	_details.append(details)
	for side in [-1, 1]:
		var sx := float(side)
		_mesh(chunk, _pyramid(100, 95 + float(index % 3) * 17, 170), rock, Vector3(sx * 155, -36, -65))
		_mesh(chunk, _pyramid(62, 48, 115), rock_top, Vector3(sx * 120, -21, -85))
		# Coastal retaining wall leaves a generous watercourse in the middle.
		_box(chunk, Vector3(sx * 72, -17, -80), Vector3(64, 7, 154), rock_top)
		_box(chunk, Vector3(sx * 40, -14, -80), Vector3(2.5, 4, 158), ivory)
		_box(chunk, Vector3(sx * 39, -11.6, -80), Vector3(0.6, 0.35, 158), guide)
		for j in range(8):
			var x := sx * _rng.randf_range(50, 115)
			var z := -13.0 - float(j) * 18.0
			var height := _rng.randf_range(12, 54)
			var width := _rng.randf_range(8, 16)
			var depth := _rng.randf_range(9, 17)
			var center := Vector3(x, -13 + height * 0.5, z)
			building_transforms.append(_transform(center, Vector3(width, height, depth)))
			dark_transforms.append(_transform(center + Vector3(0, height * 0.5 + 1.2, 0), Vector3(width * 1.08, 2.4, depth * 1.08)))
			for row in range(int(height / 5.0)):
				window_transforms.append(_transform(Vector3(x, -9.0 + row * 5.0, z + depth * 0.5 + 0.06), Vector3(width * 0.72, 0.65, 0.12)))
			if j % 3 == 0:
				_box(details, Vector3(x, -12 + height + 4.5, z), Vector3(0.45, 9, 0.45), dark_wall)
				var beacon := _sphere(details, Vector3(x, -12 + height + 9, z), 0.6, windows, 8)
				_beacons.append(beacon)
	if index % 3 == 1:
		# Elevated expressway: always above the player's maximum altitude.
		_box(chunk, Vector3(0, 32, -85), Vector3(200, 3.5, 12), dark_wall)
		_box(chunk, Vector3(0, 34, -85), Vector3(200, 0.4, 12.5), ivory)
		for side in [-1, 1]:
			_box(chunk, Vector3(float(side) * 35, 7.5, -85), Vector3(4, 48, 8), dark_wall)
			_box(chunk, Vector3(float(side) * 32.8, 14, -80.8), Vector3(0.6, 15, 0.25), guide)
	_instances(chunk, BoxMesh.new(), wall, building_transforms)
	_instances(chunk, BoxMesh.new(), dark_wall, dark_transforms)
	_instances(details, BoxMesh.new(), windows, window_transforms)

func _build_aurora_background() -> void:
	_starfield()
	var planet_shader := Shader.new()
	planet_shader.code = """shader_type spatial;
void fragment(){
 float bands=sin(UV.y*72.0 + sin(UV.x*24.0)*0.8)*0.5+0.5;
 float swirls=sin(UV.y*230.0+sin(UV.x*11.0)*2.0)*0.5+0.5;
 ALBEDO=mix(vec3(0.12,0.25,0.4),vec3(0.45,0.71,0.77),bands*0.65+swirls*0.15);
 ROUGHNESS=1.0;
} """
	var planet_mat := ShaderMaterial.new()
	planet_mat.shader = planet_shader
	var planet := Node3D.new()
	planet.position = Vector3(205, 110, -690)
	planet.rotation_degrees = Vector3(18, 0, -26)
	add_child(planet)
	_sphere(planet, Vector3.ZERO, 147, planet_mat, 48)
	var rings := _torus(planet, Vector3.ZERO, 180, 252, _material("planet_ring", Color("829faf")))
	rings.scale.y = 0.012
	var ring2 := _torus(planet, Vector3.ZERO, 257, 264, _material("planet_ring_lit", Color("b8d8d8"), 0.3))
	ring2.scale.y = 0.012
	_sun = _sphere(self, Vector3(-350, 100, -760), 19, _material("ice_sun", Color("b0dbff"), 3.0), 20)

func _starfield() -> void:
	var stars: Array[Transform3D] = []
	for i in range(450):
		var at := Vector3(_rng.randf_range(-850, 850), _rng.randf_range(-420, 530), _rng.randf_range(-850, -640))
		var size := _rng.randf_range(0.35, 1.05)
		stars.append(_transform(at, Vector3.ONE * size))
	var star_mesh := SphereMesh.new()
	star_mesh.radial_segments = 4
	star_mesh.rings = 3
	star_mesh.radius = 1.0
	star_mesh.height = 2.0
	_instances(self, star_mesh, _material("stars", Color("c8dcff"), 2.0), stars)

func _asteroid_chunk(chunk: Node3D, index: int) -> void:
	var stone := _material("asteroid", Color("344d68"), 0.0, 0.15)
	var ice := _material("ice", Color("90cbde"), 0.1, 0.25)
	var dark_ice := _material("dark_ice", Color("588fa6"), 0.0, 0.2)
	var rock_positions: Array[Transform3D] = []
	var ice_positions: Array[Transform3D] = []
	for i in range(24):
		var side := -1.0 if i % 2 == 0 else 1.0
		var x := side * _rng.randf_range(49, 165)
		var y := _rng.randf_range(-75, 110)
		var z := _rng.randf_range(-CHUNK_LENGTH, 0)
		var radius := _rng.randf_range(3, 11)
		rock_positions.append(_transform(Vector3(x, y, z), Vector3(radius * 1.1, radius * 0.8, radius), _rng.randf_range(0, TAU_F)))
		if i % 2 == 0:
			ice_positions.append(_transform(Vector3(x + radius * 0.4, y + radius * 0.6, z), Vector3(radius * 0.6, radius * 1.2, radius * 0.6), _rng.randf_range(0, TAU_F)))
	_instances(chunk, _asteroid_mesh(), stone, rock_positions)
	_instances(chunk, _crystal_mesh(), ice, ice_positions)
	# Big crystals establish a canyon silhouette around the void.
	for side in [-1, 1]:
		var root := Node3D.new()
		root.position = Vector3(float(side) * (75 + index % 3 * 14), -22, -85)
		root.rotation_degrees = Vector3(10, float(index) * 37, float(side) * 25)
		chunk.add_child(root)
		_mesh(root, _crystal_mesh(), dark_ice, Vector3.ZERO, Vector3(16, 46, 17))
		_mesh(root, _crystal_mesh(), ice, Vector3(-float(side) * 8, 10, -2), Vector3(8, 37, 8))
		_mesh(root, _crystal_mesh(), ice, Vector3(float(side) * 10, -6, -5), Vector3(11, 29, 10))
		var rotor := Node3D.new()
		rotor.position = Vector3(float(side) * 45, 33 + (index % 2) * 10, -45)
		chunk.add_child(rotor)
		_mesh(rotor, _asteroid_mesh(), stone, Vector3.ZERO, Vector3(7, 5, 5))
		_rotors.append(rotor)
	if index % 3 == 2:
		var wreck := Node3D.new()
		wreck.position = Vector3(71, 55, -80)
		wreck.rotation_degrees = Vector3(18, 14, -24)
		chunk.add_child(wreck)
		var wreck_mat := _material("wreck", Color("514e63"), 0.0, 0.6)
		_box(wreck, Vector3.ZERO, Vector3(18, 11, 65), wreck_mat)
		_box(wreck, Vector3(0, 6, 10), Vector3(9, 8, 28), wreck_mat)
		_box(wreck, Vector3(-20, 0, 18), Vector3(34, 2, 14), wreck_mat)
		_box(wreck, Vector3(9.3, 0, 6), Vector3(0.4, 1.6, 30), _material("wreck_lights", Color("df9458"), 1.2))

func _build_terminus_background() -> void:
	_starfield()
	var planet_mat := _material("terminus_planet", Color("34486c"), 0.15)
	_sphere(self, Vector3(0, -425, -690), 370, planet_mat, 64)
	var ring := _torus(self, Vector3(0, -425, -690), 370.1, 374, _material("atmosphere_rim", Color("67bad8"), 1.1))
	ring.rotation.x = PI * 0.5
	var distant := Node3D.new()
	distant.position = Vector3(-250, 145, -740)
	distant.rotation_degrees = Vector3(18, 4, 21)
	add_child(distant)
	var dark := _material("distant_station", Color("22283b"), 0.0, 0.65)
	var trim := _material("distant_trim", Color("d39972"), 0.7)
	var station_ring := _torus(distant, Vector3.ZERO, 106, 121, dark)
	station_ring.rotation.x = PI * 0.5
	var light_ring := _torus(distant, Vector3(0, 0, 2), 111, 112, trim)
	light_ring.rotation.x = PI * 0.5
	for i in range(6):
		var spoke := _box(distant, Vector3.ZERO, Vector3(6, 232, 10), dark)
		spoke.rotation.z = float(i) * PI / 3.0
	_sphere(distant, Vector3.ZERO, 21, dark, 16)
	_rotors.append(distant)
	_sun = _sphere(self, Vector3(350, 115, -800), 41, _material("terminus_sun", Color("ffcb94"), 2.5), 24)

func _fortress_chunk(chunk: Node3D, index: int) -> void:
	var armor := _material("fortress_armor", Color("344052"), 0.0, 0.65)
	var edges := _material("fortress_edges", Color("77848c"), 0.0, 0.55)
	var dark := _material("fortress_dark", Color("161d2d"), 0.0, 0.5)
	var orange := _material("fortress_orange", Color("f28c48"), 0.4, 0.4)
	var glow := _material("fortress_lights", Color("ff8f52"), 1.5)
	var cyan := _material("fortress_cyan", Color("64c8e0"), 1.3)
	var plates: Array[Transform3D] = []
	var strips: Array[Transform3D] = []
	var details := Node3D.new()
	chunk.add_child(details)
	_details.append(details)
	# A broad, recessed trench establishes the final approach.
	_box(chunk, Vector3(0, -24, -80), Vector3(180, 12, 160), dark)
	for side in [-1, 1]:
		var sx := float(side)
		_box(chunk, Vector3(sx * 69, -6, -80), Vector3(52, 28, 160), armor)
		_box(chunk, Vector3(sx * 42.4, -4, -80), Vector3(0.9, 0.9, 159), orange)
		_box(chunk, Vector3(sx * 43.2, 8.3, -80), Vector3(2.6, 0.5, 159), edges)
		for j in range(5):
			var z := -float(j) * 32.0 - 16.0
			plates.append(_transform(Vector3(sx * 58, 10, z), Vector3(22, 4, 22)))
			strips.append(_transform(Vector3(sx * 42.2, 0.0, z), Vector3(0.25, 0.65, 13)))
			_box(details, Vector3(sx * 28, -17.8, z), Vector3(1, 0.5, 16), cyan)
		for j in range(3):
			var z := -24.0 - float(j) * 53.0
			var height := 35.0 + float((index + j) % 3) * 12.0
			_box(chunk, Vector3(sx * 92, height * 0.5 + 7, z), Vector3(16, height, 21), armor)
			_box(chunk, Vector3(sx * 92, height + 8, z), Vector3(22, 3, 25), edges)
			_box(chunk, Vector3(sx * 83.8, height * 0.5 + 10, z + 10.6), Vector3(1.5, height * 0.6, 0.3), glow)
			_box(details, Vector3(sx * 92, height + 19, z), Vector3(1.1, 20, 1.1), dark)
			var beacon := _sphere(details, Vector3(sx * 92, height + 30, z), 0.8, glow, 8)
			_beacons.append(beacon)
		# Huge slanted structural ribs frame the corridor without entering it.
		var rib := _box(chunk, Vector3(sx * 52, 28, -80), Vector3(8, 61, 10), armor)
		rib.rotation.z = sx * 0.32
		var rib_line := _box(chunk, Vector3(sx * 48, 28, -74.7), Vector3(1.0, 56, 0.7), orange)
		rib_line.rotation.z = sx * 0.32
	_box(chunk, Vector3(0, 58, -80), Vector3(128, 9, 12), armor)
	_box(chunk, Vector3(0, 52.8, -73.7), Vector3(95, 0.9, 0.5), glow)
	if index % 2 == 1:
		for side in [-1, 1]:
			var rotor := Node3D.new()
			rotor.position = Vector3(float(side) * 70, 35, -125)
			chunk.add_child(rotor)
			var rim := _torus(rotor, Vector3.ZERO, 10, 13, dark)
			rim.rotation.x = PI * 0.5
			for k in range(5):
				var blade := _box(rotor, Vector3.ZERO, Vector3(2, 24, 1.6), edges)
				blade.rotation.z = float(k) * PI / 5.0
			_sphere(rotor, Vector3.ZERO, 3.5, cyan, 12)
			_rotors.append(rotor)
	_instances(chunk, BoxMesh.new(), edges, plates)
	_instances(details, BoxMesh.new(), glow, strips)

func _build_cinder_background() -> void:
	# Ground plane is the visual contact plane used by the tank controller.
	var ground := PlaneMesh.new()
	ground.size = Vector2(1800, 2400)
	_mesh(self, ground, _material("cinder_sand", Color("9d6543")), Vector3(0, -4.05, -650))
	_sun = _sphere(self, Vector3(-240, 145, -900), 68, _material("cinder_sun", Color("ffe0a3"), 1.1), 24)
	var mesa := _material("cinder_distant_mesa", Color("8a5c54"))
	for side in [-1, 1]:
		for i in range(6):
			var x := float(side) * (165.0 + i * 95.0)
			var z := -650.0 - float(i % 3) * 75.0
			_box(self, Vector3(x, 23 + i * 4, z), Vector3(120, 70 + i * 8, 100), mesa)
			_mesh(self, _pyramid(100, 82, 180), mesa, Vector3(x, -35, z + 15))

func _cinder_chunk(chunk: Node3D, index: int) -> void:
	var basalt := _material("cinder_basalt", Color("593f39"))
	var sandstone := _material("cinder_sandstone", Color("bd7750"))
	var strata := _material("cinder_strata", Color("e5a166"))
	var steel := _material("cinder_steel", Color("3f555d"), 0.0, 0.45)
	var concrete := _material("cinder_concrete", Color("8a8477"))
	var cyan := _material("cinder_guide", Color("6ae3cb"), 1.2)
	var amber := _material("cinder_warning", Color("ffc15c"), 1.1)
	var details := Node3D.new()
	chunk.add_child(details)
	_details.append(details)
	# A 48-unit apron stays clear: all blocking rocks and hover hurdles are gameplay actors.
	_box(chunk, Vector3(0, -4.14, -80), Vector3(48, 0.2, 160), concrete)
	for side in [-1, 1]:
		var sx := float(side)
		_box(chunk, Vector3(sx * 24.5, -3.85, -80), Vector3(0.65, 0.25, 160), strata)
		for j in range(5):
			var z := -16.0 - float(j) * 32.0
			_box(details, Vector3(sx * 18, -3.99, z), Vector3(0.7, 0.08, 9), cyan)
			var height := 18.0 + float((index + j) % 4) * 9.0
			var x := sx * (47.0 + float(j % 2) * 11.0)
			_box(chunk, Vector3(x, height * 0.5 - 4, z), Vector3(20, height, 25), sandstone)
			_box(details, Vector3(x, height * 0.65 - 4, z + 0.5), Vector3(20.8, 2, 26), strata)
			_mesh(chunk, _pyramid(16, 25, 33), basalt, Vector3(x + sx * 11, -4, z - 5))
		# Mining gantries stand outside the driving apron and make passage speed legible.
		if (index + side) % 2 == 0:
			_box(chunk, Vector3(sx * 32, 16, -75), Vector3(3, 40, 4), steel)
			_box(chunk, Vector3(sx * 41, 35, -75), Vector3(23, 3, 5), steel)
			_box(details, Vector3(sx * 50, 26, -75), Vector3(0.5, 18, 0.5), amber)
			_box(chunk, Vector3(sx * 50, 16.5, -75), Vector3(7, 4, 6), steel)
			var beacon := _sphere(details, Vector3(sx * 32, 37.5, -75), 0.7, amber, 8)
			_beacons.append(beacon)
	if index % 3 == 1:
		# Conveyor bridge deliberately remains well above the tank's jump ceiling.
		_box(chunk, Vector3(0, 23, -105), Vector3(100, 3, 11), steel)
		_box(chunk, Vector3(0, 24.8, -105), Vector3(100, 0.5, 12), strata)
		for x in [-33.0, 33.0]:
			_box(chunk, Vector3(x, 9, -105), Vector3(4, 27, 8), steel)

func _build_anchorage() -> void:
	_arena_root = Node3D.new()
	_arena_root.name = "AnchorageWorldSpace"
	add_child(_arena_root)
	var armor := _material("anchorage_armor", Color("344a60"), 0.0, 0.5)
	var trim := _material("anchorage_trim", Color("97b1c5"), 0.0, 0.5)
	var cyan := _material("anchorage_safe", Color("69efd7"), 1.4)
	var amber := _material("anchorage_rim", Color("ffc96e"), 1.2)
	var details := Node3D.new()
	_arena_root.add_child(details)
	_details.append(details)
	# The ring lies below flight altitude. Its visible masts mark the actual 210-unit boundary.
	_torus(_arena_root, Vector3(0, -32, 0), ARENA_RADIUS - 3, ARENA_RADIUS + 3, armor).scale.y = 0.65
	_torus(_arena_root, Vector3(0, -29.5, 0), ARENA_RADIUS - 0.5, ARENA_RADIUS + 0.5, amber).scale.y = 0.2
	_torus(_arena_root, Vector3(0, -44, 0), 74, 78, trim).scale.y = 0.8
	for i in range(24):
		var angle := TAU_F * float(i) / 24.0
		var at := Vector3(sin(angle) * ARENA_RADIUS, -13, cos(angle) * ARENA_RADIUS)
		var mast := Node3D.new()
		mast.position = at
		mast.rotation.y = angle
		_arena_root.add_child(mast)
		_box(mast, Vector3.ZERO, Vector3(3, 40, 3), armor)
		_box(mast, Vector3(0, 14, -1.7), Vector3(1.3, 10, 0.4), amber)
		_box(mast, Vector3(0, -18, 0), Vector3(10, 3, 10), trim)
		_sphere(mast, Vector3(0, 8, 0), 1.35, amber, 8)
		if i % 6 == 0:
			# Four broad dock crowns remain recognizable from any heading.
			_box(mast, Vector3(0, 8, 0), Vector3(28, 3, 13), armor)
			_box(mast, Vector3(0, 10, -7), Vector3(22, 0.7, 0.7), cyan)
			for side in [-1, 1]:
				_box(mast, Vector3(float(side) * 13, 13, 0), Vector3(2, 13, 3), trim)
	# A damaged service cradle makes the carrier's central objective readable even at distance.
	for side in [-1, 1]:
		_box(_arena_root, Vector3(float(side) * 40, -35, 0), Vector3(13, 7, 95), armor)
		_box(_arena_root, Vector3(float(side) * 40, -30.9, 0), Vector3(1.5, 0.6, 80), cyan)
		for z in [-35.0, 35.0]:
			_box(details, Vector3(float(side) * 45, -24, z), Vector3(4, 19, 4), trim)
	# A broad planet below the arena leaves the play volume clear in every direction.
	_sphere(_arena_root, Vector3(0, -555, 0), 410, _material("anchorage_planet", Color("24586b"), 0.1), 40)
	var star_positions: Array[Transform3D] = []
	for i in range(300):
		var yaw := _rng.randf_range(0, TAU_F)
		var elevation := _rng.randf_range(-0.2, 1.2)
		var at := Vector3(sin(yaw) * cos(elevation), sin(elevation), cos(yaw) * cos(elevation)) * 900.0
		star_positions.append(_transform(at, Vector3.ONE * _rng.randf_range(0.4, 1.1)))
	var star_mesh := SphereMesh.new()
	star_mesh.radial_segments = 4
	star_mesh.rings = 3
	_instances(details, star_mesh, _material("anchorage_stars", Color("d3e7ff"), 2.0), star_positions)
	set_arena_view(Vector3.ZERO, 0.0)

func _build_tempest_background() -> void:
	var cloud := _material("tempest_cloud", Color("718c9e"))
	var dark_cloud := _material("tempest_dark_cloud", Color("3d536b"))
	var cloud_mesh := SphereMesh.new()
	cloud_mesh.radial_segments = 12
	cloud_mesh.rings = 6
	cloud_mesh.radius = 1.0
	cloud_mesh.height = 2.0
	var low_clouds: Array[Transform3D] = []
	var high_clouds: Array[Transform3D] = []
	for i in range(38):
		var at := Vector3(_rng.randf_range(-650, 650), _rng.randf_range(-100, -60), _rng.randf_range(-1000, 50))
		low_clouds.append(_transform(at, Vector3(_rng.randf_range(90, 150), _rng.randf_range(15, 30), _rng.randf_range(60, 120))))
	for i in range(20):
		var at := Vector3(_rng.randf_range(-600, 600), _rng.randf_range(130, 210), _rng.randf_range(-1000, -250))
		high_clouds.append(_transform(at, Vector3(_rng.randf_range(90, 150), _rng.randf_range(20, 30), _rng.randf_range(60, 100))))
	_instances(self, cloud_mesh, cloud, low_clouds)
	_instances(self, cloud_mesh, dark_cloud, high_clouds)
	_sun = _sphere(self, Vector3(270, 90, -900), 37, _material("tempest_moon", Color("c8daec"), 0.5), 24)
	# A distant crown signals the destination before the moving conduits reach the player.
	var citadel := Node3D.new()
	citadel.position = Vector3(0, 44, -1000)
	add_child(citadel)
	var armor := _material("tempest_armor", Color("374354"), 0.0, 0.5)
	var glow := _material("tempest_energy", Color("bbaaee"), 1.3)
	_torus(citadel, Vector3.ZERO, 72, 84, armor)
	_torus(citadel, Vector3(0, -4, 0), 76, 78, glow)
	for i in range(7):
		var at := Vector3((i - 3) * 22, 18 + (3 - absi(i - 3)) * 15, 0)
		_box(citadel, at, Vector3(13, 70 + (3 - absi(i - 3)) * 25, 22), armor)

func _tempest_chunk(chunk: Node3D, index: int) -> void:
	var armor := _material("tempest_armor", Color("374354"), 0.0, 0.5)
	var edge := _material("tempest_edge", Color("869ca9"), 0.0, 0.5)
	var glow := _material("tempest_energy", Color("bbaaee"), 1.3)
	var teal := _material("tempest_teal", Color("61e6df"), 1.2)
	var details := Node3D.new()
	chunk.add_child(details)
	_details.append(details)
	for side in [-1, 1]:
		var sx := float(side)
		var x := sx * (57.0 + float(index % 2) * 11.0)
		var z := -80.0 + sx * 27.0
		_box(chunk, Vector3(x, 17, z), Vector3(10, 136, 13), armor)
		_box(chunk, Vector3(x - sx * 5.1, 18, z), Vector3(0.5, 115, 3), glow)
		_box(chunk, Vector3(x, 76, z), Vector3(22, 6, 23), edge)
		_box(chunk, Vector3(x, -47, z), Vector3(28, 8, 30), armor)
		for y in [-21.0, 17.0, 55.0]:
			_torus(chunk, Vector3(x, y, z), 10, 13, edge)
			_torus(details, Vector3(x, y + 2.5, z), 10.5, 11, teal)
		var rotor := Node3D.new()
		rotor.position = Vector3(x, 75, z + 13)
		chunk.add_child(rotor)
		var ring := _torus(rotor, Vector3.ZERO, 11, 13, armor)
		ring.rotation.x = PI * 0.5
		for j in range(3):
			var blade := _box(rotor, Vector3.ZERO, Vector3(1.6, 23, 1.2), glow)
			blade.rotation.z = float(j) * PI / 3.0
		_rotors.append(rotor)
		# Local ion arcs stay at the sides, above the flight envelope.
		for j in range(3):
			var arc := _box(details, Vector3(x - sx * (9 + j * 5), 61 + (j % 2) * 5, z), Vector3(8, 0.6, 0.6), glow)
			arc.rotation.z = sx * (0.7 if j % 2 == 0 else -0.7)
			_beacons.append(arc)
	if index % 2 == 0:
		_box(chunk, Vector3(0, 95, -90), Vector3(160, 7, 16), armor)
		_box(chunk, Vector3(0, 90.8, -81.8), Vector3(112, 0.7, 0.8), teal)

func _pyramid(width: float, height: float, depth: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var p: Array[Vector3] = [Vector3(-width, 0, -depth * 0.5), Vector3(width, 0, -depth * 0.5), Vector3(width, 0, depth * 0.5), Vector3(-width, 0, depth * 0.5), Vector3(-width * 0.15, height, -depth * 0.1)]
	for face in [[0, 4, 1], [1, 4, 2], [2, 4, 3], [3, 4, 0], [0, 1, 2], [0, 2, 3]]:
		for vertex in face:
			st.add_vertex(p[vertex])
	st.generate_normals()
	return st.commit()

func _asteroid_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var p: Array[Vector3] = [Vector3(0, 1.05, 0.1), Vector3(0.9, 0.25, 0), Vector3(0.2, 0.1, 1.0), Vector3(-0.9, 0.0, 0.3), Vector3(-0.15, -0.1, -1), Vector3(0.05, -0.9, -0.2)]
	for face in [[0, 2, 1], [0, 3, 2], [0, 4, 3], [0, 1, 4], [5, 1, 2], [5, 2, 3], [5, 3, 4], [5, 4, 1]]:
		for vertex in face:
			st.add_vertex(p[vertex])
	st.generate_normals()
	return st.commit()

func _crystal_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var points: Array[Vector3] = [Vector3(0, 1.1, 0), Vector3(0.6, 0, 0), Vector3(0, 0, 0.6), Vector3(-0.6, 0, 0), Vector3(0, 0, -0.6), Vector3(0, -0.7, 0)]
	for face in [[0, 2, 1], [0, 3, 2], [0, 4, 3], [0, 1, 4], [5, 1, 2], [5, 2, 3], [5, 3, 4], [5, 4, 1]]:
		for vertex in face:
			st.add_vertex(points[vertex])
	st.generate_normals()
	return st.commit()
