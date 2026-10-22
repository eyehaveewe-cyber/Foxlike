class_name FoxFlightEffects
extends Node3D
## Bounded, reusable VFX. All public positions are world-space.

const PARTICLE_CAP: int = 400
const WAVE_CAP: int = 12
var _particles: MultiMesh
var _positions: PackedVector3Array = PackedVector3Array()
var _velocities: PackedVector3Array = PackedVector3Array()
var _rotations: PackedVector3Array = PackedVector3Array()
var _spins: PackedVector3Array = PackedVector3Array()
var _sizes: PackedVector3Array = PackedVector3Array()
var _colors: PackedColorArray = PackedColorArray()
var _life: PackedFloat32Array = PackedFloat32Array()
var _life_max: PackedFloat32Array = PackedFloat32Array()
var _cursor: int = 0
var _waves: Array[MeshInstance3D] = []
var _wave_materials: Array[StandardMaterial3D] = []
var _wave_life: PackedFloat32Array = PackedFloat32Array()
var _wave_radius: PackedFloat32Array = PackedFloat32Array()
var _wave_colors: PackedColorArray = PackedColorArray()
var _wave_cursor: int = 0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _built: bool = false


func _ready() -> void:
	_build_pool()


func _build_pool() -> void:
	if _built:
		return
	_built = true
	_rng.randomize()
	_positions.resize(PARTICLE_CAP)
	_velocities.resize(PARTICLE_CAP)
	_rotations.resize(PARTICLE_CAP)
	_spins.resize(PARTICLE_CAP)
	_sizes.resize(PARTICLE_CAP)
	_colors.resize(PARTICLE_CAP)
	_life.resize(PARTICLE_CAP)
	_life_max.resize(PARTICLE_CAP)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.no_depth_test = false
	var shard: BoxMesh = BoxMesh.new()
	shard.size = Vector3.ONE
	shard.material = material
	_particles = MultiMesh.new()
	_particles.transform_format = MultiMesh.TRANSFORM_3D
	_particles.use_colors = true
	_particles.mesh = shard
	_particles.instance_count = PARTICLE_CAP
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.multimesh = _particles
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.custom_aabb = AABB(Vector3(-500, -500, -1000), Vector3(1000, 1000, 1600))
	add_child(instance)
	var hidden: Transform3D = Transform3D(Basis.IDENTITY.scaled(Vector3.ZERO), Vector3.ZERO)
	for i: int in range(PARTICLE_CAP):
		_particles.set_instance_transform(i, hidden)
	_wave_life.resize(WAVE_CAP)
	_wave_radius.resize(WAVE_CAP)
	_wave_colors.resize(WAVE_CAP)
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 0.96
	torus.outer_radius = 1.0
	torus.rings = 40
	torus.ring_segments = 6
	for i: int in range(WAVE_CAP):
		var wave: MeshInstance3D = MeshInstance3D.new()
		wave.mesh = torus
		wave.rotation.x = PI * 0.5
		wave.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var wave_material: StandardMaterial3D = StandardMaterial3D.new()
		wave_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		wave_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		wave_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		wave.material_override = wave_material
		wave.visible = false
		add_child(wave)
		_waves.append(wave)
		_wave_materials.append(wave_material)


func _process(delta: float) -> void:
	if not _built:
		return
	for i: int in range(PARTICLE_CAP):
		if _life[i] <= 0.0:
			continue
		_life[i] = maxf(0.0, _life[i] - delta)
		if _life[i] == 0.0:
			_particles.set_instance_transform(i, Transform3D(Basis.IDENTITY.scaled(Vector3.ZERO), Vector3.ZERO))
			continue
		_positions[i] += _velocities[i] * delta
		_velocities[i] *= exp(-0.85 * delta)
		_rotations[i] += _spins[i] * delta
		var remaining: float = _life[i] / _life_max[i]
		var shrink: float = minf(1.0, remaining * 3.0)
		var basis: Basis = Basis.from_euler(_rotations[i]).scaled(_sizes[i] * shrink)
		_particles.set_instance_transform(i, Transform3D(basis, _positions[i]))
		var color: Color = _colors[i]
		color.a *= minf(1.0, remaining * 2.5)
		_particles.set_instance_color(i, color)
	for i: int in range(WAVE_CAP):
		if _wave_life[i] <= 0.0:
			continue
		_wave_life[i] = maxf(0.0, _wave_life[i] - delta)
		var wave: MeshInstance3D = _waves[i]
		if _wave_life[i] == 0.0:
			wave.visible = false
			continue
		var progress: float = 1.0 - _wave_life[i] / 0.7
		var radius: float = lerpf(0.3, _wave_radius[i], 1.0 - pow(1.0 - progress, 2.0))
		wave.scale = Vector3.ONE * radius
		wave.position.z += delta * 5.0
		var color: Color = _wave_colors[i]
		color.a = (1.0 - progress) * 0.8
		_wave_materials[i].albedo_color = color


func _emit(pos: Vector3, velocity: Vector3, color: Color, dimensions: Vector3, lifetime: float) -> void:
	if not _built:
		_build_pool()
	var i: int = _cursor
	_cursor = (_cursor + 1) % PARTICLE_CAP
	_positions[i] = to_local(pos)
	_velocities[i] = velocity
	_rotations[i] = Vector3(_rng.randf_range(-PI, PI), _rng.randf_range(-PI, PI), _rng.randf_range(-PI, PI))
	_spins[i] = Vector3(_rng.randf_range(-6, 6), _rng.randf_range(-6, 6), _rng.randf_range(-6, 6))
	_sizes[i] = dimensions
	_colors[i] = color
	_life[i] = lifetime
	_life_max[i] = lifetime
	_particles.set_instance_transform(i, Transform3D(Basis.from_euler(_rotations[i]).scaled(dimensions), _positions[i]))
	_particles.set_instance_color(i, color)


func burst(pos: Vector3, color: Color = Color.ORANGE, scale: float = 1.0) -> void:
	if not _built:
		_build_pool()
	var strength: float = clampf(scale, 0.25, 5.0)
	var count: int = mini(80, int(28.0 + strength * 10.0))
	for i: int in range(count):
		var direction: Vector3 = Vector3(_rng.randf_range(-1, 1), _rng.randf_range(-1, 1), _rng.randf_range(-1, 1)).normalized()
		var speed: float = _rng.randf_range(6.0, 24.0) * sqrt(strength)
		var c: Color = color.lerp(Color(1.0, 0.96, 0.74), _rng.randf_range(0.0, 0.85))
		var size: float = _rng.randf_range(0.08, 0.28) * sqrt(strength)
		var dimensions: Vector3 = Vector3(size, size, size * _rng.randf_range(1.0, 5.0))
		_emit(pos + direction * 0.35, direction * speed + Vector3(0, 0, 7), c, dimensions, _rng.randf_range(0.4, 1.25))
	shockwave(pos, color.lerp(Color.WHITE, 0.35), 7.0 * sqrt(strength))
	# A short-lived white central bloom reads even without glow post-processing.
	_emit(pos, Vector3(0, 0, 3), Color(1.0, 0.95, 0.8), Vector3.ONE * strength * 1.2, 0.13)


func spark(pos: Vector3, color: Color = Color("a9f5ff")) -> void:
	if not _built:
		_build_pool()
	for i: int in range(7):
		var velocity: Vector3 = Vector3(_rng.randf_range(-7, 7), _rng.randf_range(-7, 7), _rng.randf_range(1, 12))
		_emit(pos, velocity, color, Vector3(0.08, 0.08, 0.5), _rng.randf_range(0.15, 0.36))


func shockwave(pos: Vector3, color: Color = Color.ORANGE, radius: float = 12.0) -> void:
	if not _built:
		_build_pool()
	var i: int = _wave_cursor
	_wave_cursor = (_wave_cursor + 1) % WAVE_CAP
	_wave_life[i] = 0.7
	_wave_radius[i] = clampf(radius, 1.0, 80.0)
	_wave_colors[i] = color
	_waves[i].position = to_local(pos)
	_waves[i].scale = Vector3.ONE * 0.3
	_waves[i].visible = true
	_wave_materials[i].albedo_color = color


func trail(pos: Vector3, color: Color = Color("68dcff"), size: float = 0.25) -> void:
	_emit(pos, Vector3(0, 0, 18), color, Vector3(size, size, size * 2.8), 0.22)


func clear() -> void:
	if not _built:
		return
	_life.fill(0.0)
	_wave_life.fill(0.0)
	var hidden: Transform3D = Transform3D(Basis.IDENTITY.scaled(Vector3.ZERO), Vector3.ZERO)
	for i: int in range(PARTICLE_CAP):
		_particles.set_instance_transform(i, hidden)
	for wave: MeshInstance3D in _waves:
		wave.visible = false
