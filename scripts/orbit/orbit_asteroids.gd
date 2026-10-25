extends Node3D
## Bounded visitors reveal gradually in the outer drift. All motion is aesthetic,
## scaled orbital motion; this is not an N-body astronomy simulator.
const ROCK_SHADER = preload("res://shaders/orbit/rock.gdshader")
const MAX_ROCKS := 24
var visitors: Array[Dictionary] = []
var meshes: Array[ArrayMesh] = []
var rng := RandomNumberGenerator.new()
var enabled := true
var spawn_timer := 12.0
var created := 0

func setup() -> void:
	rng.seed = 672144
	for i in range(6): meshes.append(_make_mesh(i))
	for i in range(8): spawn(Vector3.ZERO,true)

func _make_mesh(seed_value: int) -> ArrayMesh:
	var sphere := SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 2.0
	sphere.radial_segments = 18
	sphere.rings = 10
	var arrays := sphere.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	for i in range(vertices.size()):
		var direction := vertices[i].normalized()
		var detail := sin(direction.x*7.0+float(seed_value))*sin(direction.z*5.3+direction.y*8.0)
		var size := .9+detail*.15+sin(direction.y*4.0+float(seed_value)*3.0)*.12
		vertices[i] = direction*size
		normals[i] = (direction+Vector3(detail*.12,0,detail*.1)).normalized()
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	return mesh

func spawn(ship_position: Vector3, existing: bool = false, preferred: Vector3 = Vector3.INF) -> bool:
	if not enabled or visitors.size()>=MAX_ROCKS: return false
	var angle := rng.randf_range(0,TAU)
	var radius := rng.randf_range(390,1150)
	var height := rng.randf_range(-210,280)
	var point := Vector3(sin(angle)*radius,height,cos(angle)*radius)
	if preferred.is_finite():
		point = preferred
		radius = Vector2(point.x,point.z).length()
		if radius<390.0 or radius>1500.0: return false
		angle = atan2(point.x,point.z)
		height = point.y
	if point.distance_to(ship_position)<150.0: return false
	var size := rng.randf_range(5.0,18.0)
	var material := ShaderMaterial.new()
	material.shader = ROCK_SHADER
	material.set_shader_parameter("mineral",rng.randf())
	material.set_shader_parameter("reveal",1.0 if existing else 0.0)
	var node := MeshInstance3D.new()
	node.mesh = meshes[created%meshes.size()]
	node.material_override = material
	node.scale = Vector3(size,size*rng.randf_range(.7,1.3),size*rng.randf_range(.7,1.35))
	node.position = point
	add_child(node)
	visitors.append({"node":node,"position":point,"radius":size*1.5,"angle":angle,"distance":radius,"height":height,"rate":rng.randf_range(.0015,.006),"phase":rng.randf_range(0,TAU),"age":8.0 if existing else 0.0,"life":rng.randf_range(180,330),"material":material})
	created += 1
	return true

func advance(dt: float, ship_position: Vector3) -> void:
	if not enabled: return
	spawn_timer -= dt
	if spawn_timer<=0.0:
		spawn_timer = 18.0
		spawn(ship_position)
	for visitor in visitors.duplicate():
		visitor.age += dt
		# Orbit and spin continue while hovering, independently of navigation input.
		visitor.angle += float(visitor.rate)*dt
		var point := Vector3(sin(float(visitor.angle))*float(visitor.distance),float(visitor.height)+sin(float(visitor.angle)*2.0+float(visitor.phase))*12.0,cos(float(visitor.angle))*float(visitor.distance))
		# Slow visitors yield near the ship so an idle ship remains a quiet safe place.
		if point.distance_to(ship_position)>float(visitor.radius)+30.0:
			visitor.position = point
			visitor.node.position = point
		visitor.node.rotation += Vector3(.015,.022,.008)*dt
		var fade := minf(smoothstep(0.0,6.0,float(visitor.age)),smoothstep(0.0,8.0,float(visitor.life)-float(visitor.age)))
		visitor.material.set_shader_parameter("reveal",fade)
		if float(visitor.age)>float(visitor.life):
			visitor.node.queue_free()
			visitors.erase(visitor)

func set_enabled(value: bool) -> void:
	enabled = value
	visible = value
