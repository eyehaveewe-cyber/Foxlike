extends Node3D
## Station architecture with matching hull safety volumes, not a decorative backdrop.
const Geometry = preload("res://scripts/duel/duel_geometry.gd")
var solids: Array[AABB] = []
var rings: Array[Vector3] = [] # radius, height, tube radius
var dishes: Array[Node3D] = []
var material_cache: Dictionary = {}
var window_multimesh: MultiMeshInstance3D
var observation_point := Vector3(0,26,155)

func setup() -> void:
	for child in get_children(): child.queue_free()
	solids.clear()
	rings.clear()
	dishes.clear()
	material_cache.clear()
	_build()

func mat(color: String, glow: float = 0.0, metal: float = .45) -> StandardMaterial3D:
	var key := color+str(glow)+str(metal)
	if material_cache.has(key): return material_cache[key]
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color)
	material.metallic = metal
	material.roughness = .46
	if glow>0:
		material.emission_enabled = true
		material.emission = Color(color)
		material.emission_energy_multiplier = glow
	material_cache[key] = material
	return material

func mesh_at(mesh: Mesh, material: Material, point: Vector3, size: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var out := MeshInstance3D.new()
	out.mesh = mesh
	out.material_override = material
	out.position = point
	out.scale = size
	add_child(out)
	return out

func block(point: Vector3, size: Vector3, material: Material, solid: bool = true) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = size
	if solid: solids.append(AABB(point-size*.5,size))
	return mesh_at(box,material,point)

func ring(radius: float, height: float, tube: float, material: Material, solid: bool = false) -> MeshInstance3D:
	var torus := TorusMesh.new()
	torus.inner_radius = radius-tube
	torus.outer_radius = radius+tube
	torus.rings = 128
	torus.ring_segments = 12
	if solid: rings.append(Vector3(radius,height,tube))
	return mesh_at(torus,material,Vector3(0,height,0))

func cylinder(point: Vector3, radius: float, height: float, material: Material) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 32
	return mesh_at(mesh,material,point)

func _build() -> void:
	var hull := mat("a4b4b7",0,.72)
	var dark := mat("1a2a39",0,.68)
	var ribs := mat("596d7c",0,.7)
	var copper := mat("b58859",0,.7)
	var light := mat("9dedf2",2.0,.2)
	var warm := mat("f3c98d",1.6,.2)
	# A tall central spine and two walkable-scale toroidal habitats.
	block(Vector3(0,8,0),Vector3(23,84,23),hull)
	for y in [-30.0,47.0]:
		block(Vector3(0,y,0),Vector3(33,7,33),dark)
		cylinder(Vector3(0,y+5,0),9,4,copper)
	for y in [-12.0,27.0]:
		ring(112,y,6.5,hull,true)
		ring(112,y+6.2,.7,dark)
		ring(112,y-6.2,.7,copper)
		ring(119,y,.32,light)
		ring(104.8,y,.28,warm)
	# Four broad spokes and eight docking modules leave generous approach gaps.
	for side in [-1.0,1.0]:
		block(Vector3(side*61,-12,0),Vector3(105,7,8),ribs)
		block(Vector3(0,-12,side*61),Vector3(8,7,105),ribs)
		block(Vector3(side*61,27,0),Vector3(105,5,6),hull)
		block(Vector3(0,27,side*61),Vector3(6,5,105),hull)
		for z in [-1.0,1.0]:
			var point := Vector3(side*79,-10,z*79)
			block(point,Vector3(24,18,24),hull)
			block(point+Vector3(0,10,0),Vector3(27,2,27),dark)
			block(point+Vector3(0,0,z*12.15),Vector3(18,6,.4),warm,false)
		# Solar sails: panel tiling is instanced, not hundreds of draw calls.
		block(Vector3(side*185,-15,0),Vector3(100,4,4),ribs)
		block(Vector3(side*229,-15,0),Vector3(8,8,8),copper)
		# Dock piers straddle the open entry rather than close it with an invisible wall.
		for x in [-1.0,1.0]:
			block(Vector3(x*25,-4,side*154),Vector3(7,6,70),hull)
			block(Vector3(x*25,-.8,side*154),Vector3(3,.4,63),light,false)
			block(Vector3(x*25,0,side*190),Vector3(11,14,7),dark)
			block(Vector3(x*25,7.2,side*190),Vector3(4,.5,4),warm,false)
	# Windows around both habitats: 512 lit panes in one multimesh.
	var window_transforms: Array[Transform3D] = []
	for y in [-12.0,27.0]:
		for i in range(128):
			var angle := TAU*float(i)/128.0
			for row in [-1.0,1.0]:
				var point := Vector3(sin(angle)*118.25,y+row*1.7,cos(angle)*118.25)
				window_transforms.append(Transform3D(Basis(Vector3.UP,angle).scaled(Vector3(1.4,.8,.25)),point))
	window_multimesh = instances(BoxMesh.new(),warm,window_transforms)
	var panel_transforms: Array[Transform3D] = []
	for side in [-1.0,1.0]:
		for x in range(9):
			for z in range(16):
				var point := Vector3(side*(145+float(x)*9),-13.0,-66+float(z)*8.8)
				panel_transforms.append(Transform3D(Basis.IDENTITY.scaled(Vector3(8.1,.6,7.7)),point))
	instances(BoxMesh.new(),mat("16325a",0,.55),panel_transforms)
	# A physical slim slab below each solar field matches the visible array.
	for side in [-1.0,1.0]: solids.append(AABB(Vector3(140 if side>0 else -224,-14.0,-70),Vector3(84,2,142)))
	# Restrained radar dishes and communications spars on top of the station.
	for side in [-1.0,1.0]:
		block(Vector3(side*11,57,0),Vector3(1,22,1),ribs)
		var dish := cylinder(Vector3(side*11,67,0),6,1.5,hull)
		dish.rotation.z = side*.35
		dishes.append(dish)
		block(Vector3(side*11,69,0),Vector3(.4,8,.4),copper,false)
	for i in range(5):
		block(Vector3(-7+float(i)*3.5,15,11.8),Vector3(1.6,30,.5),light,false)
	var nameplate := Label3D.new()
	nameplate.text = "VIRIDIA\nORBITAL OBSERVATORY"
	nameplate.font_size = 64
	nameplate.pixel_size = .035
	nameplate.modulate = Color("d7edf0")
	nameplate.position = Vector3(0,11,13)
	nameplate.outline_size = 6
	add_child(nameplate)

func instances(mesh: Mesh, material: Material, transforms: Array[Transform3D]) -> MultiMeshInstance3D:
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = mesh
	multi.instance_count = transforms.size()
	for i in range(transforms.size()): multi.set_instance_transform(i,transforms[i])
	var instance := MultiMeshInstance3D.new()
	instance.multimesh = multi
	instance.material_override = material
	add_child(instance)
	return instance

func advance(dt: float, clock: float) -> void:
	for i in range(dishes.size()): dishes[i].rotation.y = sin(clock*.025+float(i))*0.4

func blocked(a: Vector3, b: Vector3, extent: float) -> bool:
	for solid in solids:
		if not Geometry.sweep_box(a,b,solid,extent).is_empty(): return true
	var samples := maxi(1,int(ceil(a.distance_to(b)/1.5)))
	for i in range(samples+1):
		var at := a.lerp(b,float(i)/float(samples))
		for shape in rings:
			var q := Vector2(Vector2(at.x,at.z).length()-shape.x,at.y-shape.y)
			if q.length()<shape.z+extent: return true
	return false
