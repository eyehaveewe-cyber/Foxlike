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
	_clock = 0.0
	stage = clampi(new_stage, 0, 2)
	_rng.seed = 38229 + stage * 997
	_build_lighting()
	match stage:
		0: _build_viridia_background()
		1: _build_aurora_background()
		2: _build_terminus_background()
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
	else:
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
	key.light_color = Color("ffd5a2") if stage == 0 else Color("bbd8ff")
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
