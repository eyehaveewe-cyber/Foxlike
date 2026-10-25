extends Node3D
## One selected planet and every catalogued moon share a continuous flight space.
const Catalog = preload("res://scripts/orbit/pbr_catalog.gd")
const Geometry = preload("res://scripts/duel/duel_geometry.gd")
const SURFACE = preload("res://shaders/orbit/planet.gdshader")
const CLOUDS = preload("res://shaders/orbit/clouds.gdshader")
const AIR = preload("res://shaders/orbit/atmosphere.gdshader")
const RINGS = preload("res://shaders/orbit/rings.gdshader")
const SUN := Vector3(-.85,.22,.42)
var body: Dictionary
var bodies: Array[Dictionary] = []
var planet: MeshInstance3D
var clouds: MeshInstance3D
var atmosphere: MeshInstance3D
var ring: MeshInstance3D
var meshes: Array[SphereMesh] = []
var ring_meshes: Array[ArrayMesh] = []
var lod_clock := 0.0
var lod_updates := 0

func _ready() -> void:
	for resolution in [Vector2i(128,64),Vector2i(48,24),Vector2i(16,8)]:
		var sphere := SphereMesh.new()
		sphere.radius = 1.0
		sphere.height = 2.0
		sphere.radial_segments = resolution.x
		sphere.rings = resolution.y
		meshes.append(sphere)
	for resolution in [128,32]: ring_meshes.append(_ring_mesh(resolution))

func _sphere(radius: float, point: Vector3, material: ShaderMaterial) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = meshes[1]
	node.scale = Vector3.ONE*radius
	node.position = point
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(node)
	return node

func _material(shader: Shader) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("sun_direction",SUN)
	return material

func load_world(id: String) -> bool:
	var found: Dictionary = {}
	for entry in Catalog.planets():
		if entry.id==id: found = entry; break
	if found.is_empty(): return false
	body = found
	for child in get_children():
		remove_child(child)
		child.queue_free()
	bodies.clear()
	ring = null
	var radius := 6000.0*float(body.radius)/49.0
	var center := Vector3(200,-5300,-6900).normalized()*(radius+2700.0)
	var mode := {"ember":1,"dune":2,"pelagos":3,"viridia":0,"vesper":4,"cobalt":5,"jovian":6,"boreas":6,"aurora":7,"chronos":6,"nyx":8,"terminus":9}
	var material := _material(SURFACE)
	material.set_shader_parameter("surface_type",mode[id])
	material.set_shader_parameter("base_color",body.color)
	material.set_shader_parameter("accent_color",body.accent)
	material.set_shader_parameter("seed",0.0 if id=="viridia" else float(body.stage)*4.7+2.3)
	planet = _sphere(radius,center,material)
	bodies.append({"id":id,"name":body.name,"position":center,"radius":radius,"node":planet,"material":material,"lod":1})
	var cloud_material := _material(CLOUDS)
	cloud_material.set_shader_parameter("cloud_tint",body.accent)
	clouds = _sphere(radius*1.003,center,cloud_material)
	clouds.set_meta("has_clouds",id in ["viridia","pelagos","cobalt"])
	var air_material := _material(AIR)
	air_material.set_shader_parameter("air_color",Color("1463ca") if id=="viridia" else body.accent)
	atmosphere = _sphere(radius*1.014,center,air_material)
	if bool(body.ringed):
		ring = MeshInstance3D.new()
		ring.mesh = ring_meshes[0]
		ring.position = center
		ring.scale = Vector3.ONE*radius
		ring.rotation.z = -.25
		ring.material_override = _material(RINGS)
		ring.material_override.set_shader_parameter("tint",body.accent)
		ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(ring)
	var outward := -center.normalized()
	var tangent := Vector3.UP.cross(outward).normalized()
	var rng := RandomNumberGenerator.new()
	rng.seed = absi(id.hash())+2907
	for i in range(int(body.moons)):
		var moon_radius := rng.randf_range(330.0,800.0)
		var distance := radius+6900.0+float(i)*2400.0
		var phase := float(i)*2.39996
		var point := center+(outward*cos(phase)+tangent*sin(phase))*distance
		var moon_material := _material(SURFACE)
		moon_material.set_shader_parameter("surface_type",7 if id in ["aurora","boreas"] and i%2==0 else 1)
		moon_material.set_shader_parameter("base_color",Color("86969f").lerp(body.color,.22))
		moon_material.set_shader_parameter("accent_color",Color("d5dad9"))
		moon_material.set_shader_parameter("seed",float(i)*17.3+float(body.stage)*2.1+9.0)
		var node := _sphere(moon_radius,point,moon_material)
		bodies.append({"id":id+"_moon_"+str(i+1),"name":body.name+" "+str(i+1).pad_zeros(2),"position":point,"radius":moon_radius,"node":node,"material":moon_material,"distance":distance,"phase":phase,"rate":.000012/sqrt(float(i+1)),"outward":outward,"tangent":tangent,"lod":1})
	lod_clock = 0.0
	advance(0.0,0.0,Vector3.ZERO)
	return true

func advance(dt: float, clock: float, viewer: Vector3) -> void:
	for i in range(bodies.size()):
		var entry := bodies[i]
		entry.material.set_shader_parameter("spin",clock*.00022+float(i)*.17)
		if i==0: continue
		var angle: float = entry.phase+clock*entry.rate
		entry.position = bodies[0].position+(entry.outward*cos(angle)+entry.tangent*sin(angle))*entry.distance
		entry.node.position = entry.position
	clouds.material_override.set_shader_parameter("spin",clock*.00031+.12)
	lod_clock -= dt
	if lod_clock<=0.0:
		lod_clock = .2
		update_lod(viewer)

func update_lod(viewer: Vector3) -> void:
	lod_updates += 1
	for entry in bodies:
		var apparent: float = entry.radius/maxf(1.0,viewer.distance_to(entry.position))
		var level := 0 if apparent>.10 else 1 if apparent>.015 else 2
		entry.lod = level
		entry.node.mesh = meshes[level]
		entry.material.set_shader_parameter("detail_level",level)
	var planet_apparent: float = bodies[0].radius/maxf(1.0,viewer.distance_to(bodies[0].position))
	clouds.visible = bool(clouds.get_meta("has_clouds")) and planet_apparent>.025
	atmosphere.visible = planet_apparent>.008
	clouds.mesh = meshes[0 if planet_apparent>.10 else 1]
	atmosphere.mesh = meshes[0 if planet_apparent>.10 else 1]
	if ring!=null: ring.mesh = ring_meshes[0 if planet_apparent>.07 else 1]

func blocked(a: Vector3, b: Vector3, extent: float) -> bool:
	for entry in bodies:
		if Geometry.sphere_time(a,b,entry.position,float(entry.radius)+extent)!=INF: return true
	return false

func clearance(point: Vector3) -> float:
	var result := INF
	for entry in bodies: result = minf(result,point.distance_to(entry.position)-float(entry.radius))
	return result

func _ring_mesh(segments: int) -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(segments):
		var a := TAU*float(i)/float(segments)
		var b := TAU*float(i+1)/float(segments)
		var points := [Vector3(cos(a),0,sin(a))*1.28,Vector3(cos(a),0,sin(a))*2.15,Vector3(cos(b),0,sin(b))*2.15,Vector3(cos(b),0,sin(b))*1.28]
		for index in [0,1,2,0,2,3]:
			tool.set_normal(Vector3.UP)
			tool.add_vertex(points[index])
	return tool.commit()

func clear_point(point: Vector3, extent: float) -> Vector3:
	for entry in bodies:
		var offset: Vector3 = point-entry.position
		if offset.length()<float(entry.radius)+extent:
			point = entry.position+(offset.normalized() if offset.length()>.01 else Vector3.UP)*(float(entry.radius)+extent)
	return point
