extends Node3D
## Newtonian visitors in a scaled co-orbiting local frame. Planet gravity and
## frame forces act on velocities; no prescribed paths or near-ship freezing.
const PLANET_OFFSET := Vector3(-200,5300,6900)
const ORBIT_RATE := .00022
const OMEGA := Vector3(0,.793,-.609)*ORBIT_RATE
const MU := 31900.0

static func acceleration(point: Vector3, velocity: Vector3) -> Vector3:
	var r := PLANET_OFFSET+point
	return -MU*r/pow(maxf(r.length(),6000.0),3.0)+MU*PLANET_OFFSET/pow(PLANET_OFFSET.length(),3.0)-2.0*OMEGA.cross(velocity)-OMEGA.cross(OMEGA.cross(point))

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
	visitors.append({"node":node,"position":point,"radius":size*1.5,"angle":angle,"distance":radius,"height":height,"velocity":Vector3(rng.randf_range(-2.5,2.5),rng.randf_range(-.4,.4),rng.randf_range(-2.5,2.5)),"mass":pow(size,3.0),"phase":rng.randf_range(0,TAU),"age":8.0 if existing else 0.0,"life":rng.randf_range(180,330),"material":material})
	created += 1
	return true

func advance(dt: float, ship_position: Vector3, station: Node3D = null) -> void:
	if not enabled: return
	spawn_timer -= dt
	if spawn_timer<=0.0:
		spawn_timer = 18.0
		spawn(ship_position)
	for visitor in visitors.duplicate():
		visitor.age += dt
		var remaining := dt
		while remaining>.000001:
			var h := minf(remaining,1.0/120.0)
			visitor.velocity += acceleration(visitor.position,visitor.velocity)*h
			var next: Vector3 = visitor.position+visitor.velocity*h
			if station!=null and station.blocked(visitor.position,next,float(visitor.radius)):
				visitor.velocity *= -.8
			else:
				visitor.position = next
			remaining -= h
		visitor.node.position = visitor.position
		visitor.node.rotation += Vector3(.015,.022,.008)*dt
		var fade := minf(smoothstep(0.0,6.0,float(visitor.age)),smoothstep(0.0,8.0,float(visitor.life)-float(visitor.age)))
		visitor.material.set_shader_parameter("reveal",fade)
		if float(visitor.age)>float(visitor.life):
			visitor.node.queue_free()
			visitors.erase(visitor)

	# Pairwise impulses conserve linear momentum; inverse mass separates overlap.
	for i in range(visitors.size()):
		for j in range(i+1,visitors.size()):
			resolve_pair(visitors[i],visitors[j])

static func resolve_pair(a: Dictionary, b: Dictionary) -> void:
	var offset: Vector3 = b.position-a.position
	var distance := offset.length()
	var separation: float = a.radius+b.radius
	if distance>=separation: return
	var normal := offset/distance if distance>.00001 else Vector3.RIGHT
	var inverse_a: float = 1.0/a.mass
	var inverse_b: float = 1.0/b.mass
	var correction := normal*(separation-distance)/(inverse_a+inverse_b)
	a.position -= correction*inverse_a
	b.position += correction*inverse_b
	var closing: float = (b.velocity-a.velocity).dot(normal)
	if closing<0.0:
		var impulse := -1.8*closing/(inverse_a+inverse_b)
		a.velocity -= normal*impulse*inverse_a
		b.velocity += normal*impulse*inverse_b
	if a.has("node"): a.node.position = a.position
	if b.has("node"): b.node.position = b.position

func set_enabled(value: bool) -> void:
	enabled = value
	visible = value
