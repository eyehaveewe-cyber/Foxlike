class_name FoxShipModel
extends Node3D
## Original procedural airframes, carrying Project Barrel Roll's swept-wing,
## insect-carrier and articulated RIME design language into real-time flight.
## Gameplay owns this node's transform; all cosmetic movement stays under visual.

var weak_points: Array[Node3D] = []
var core: Node3D
var visual: Node3D
var kind: String = "player"
var _parts: Dictionary = {}
var _materials: Dictionary = {}
var _flames: Array[Node3D] = []
var _flaps: Array[Node3D] = []
var _rotors: Array[Node3D] = []
var _arms: Array[Dictionary] = []
var _tail: Array[Node3D] = []
var _flash: float = 0.0
var _facing: float = 0.0
var _bank: float = 0.0
var _pitch: float = 0.0
var _damage: float = 0.0

func setup(model_kind: String, tint: Color = Color("68dcff")) -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	weak_points.clear()
	_flames.clear()
	_flaps.clear()
	_rotors.clear()
	_arms.clear()
	_tail.clear()
	_parts.clear()
	_materials.clear()
	core = null
	kind = model_kind
	visual = Node3D.new()
	visual.name = "AnimatedAirframe"
	add_child(visual)
	_palette(tint)
	_facing = PI if kind in ["fighter", "interceptor", "bomber", "boss1", "boss2", "boss3"] else 0.0
	visual.rotation.y = _facing
	match kind:
		"player", "wingman": _build_arrow()
		"fighter": _build_enemy(false, false)
		"interceptor": _build_enemy(true, false)
		"bomber": _build_enemy(false, true)
		"boss1": _build_frigate()
		"boss2": _build_rime()
		"boss3": _build_carrier(true)
		"carrier": _build_carrier(false)
		_: _build_arrow()

func _palette(tint: Color) -> void:
	_materials["ivory"] = _mat(Color("e4e8de"), 0.45, 0.42)
	_materials["white"] = _mat(Color("f7f2db"), 0.2, 0.5)
	_materials["armor"] = _mat(Color("4c6378"), 0.65, 0.4)
	_materials["edge"] = _mat(Color("9bafbb"), 0.6, 0.4)
	_materials["dark"] = _mat(Color("101f31"), 0.4, 0.52)
	_materials["black"] = _mat(Color("060d18"), 0.15, 0.68)
	_materials["orange"] = _mat(Color("f05b37"), 0.35, 0.48)
	_materials["gold"] = _mat(Color("e8b871"), 0.7, 0.35)
	_materials["tint"] = _mat(tint, 0.6, 0.35)
	_materials["glass"] = _mat(Color("106d8c"), 0.75, 0.16, Color("1cb4d4"), 0.28)
	_materials["cyan"] = _mat(Color("78f6ff"), 0.0, 0.5, Color("4edbff"), 2.8)
	_materials["warm"] = _mat(Color("ffe9bd"), 0.0, 0.7, Color("ffc578"), 3.0)
	_materials["red"] = _mat(Color("ff645b"), 0.0, 0.5, Color("fa3d4f"), 2.5)
	_materials["purple"] = _mat(Color("de90ff"), 0.0, 0.5, Color("bd58e8"), 2.0)

func _mat(color: Color, metal: float, rough: float, glow: Color = Color.BLACK, energy: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metal
	material.roughness = rough
	material.emission_enabled = energy > 0.0
	material.emission = glow
	material.emission_energy_multiplier = energy
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material

func _node(parent: Node3D, label: String, point: Vector3 = Vector3.ZERO) -> Node3D:
	var node := Node3D.new()
	node.name = label
	node.position = point
	parent.add_child(node)
	return node

func _mesh(parent: Node3D, label: String, mesh: Mesh, point: Vector3, material: String) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = label
	instance.mesh = mesh
	instance.position = point
	instance.material_override = _materials[material]
	parent.add_child(instance)
	return instance

func _box(parent: Node3D, label: String, size: Vector3, point: Vector3, material: String) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _mesh(parent, label, mesh, point, material)

func _sphere(parent: Node3D, label: String, size: Vector3, point: Vector3, material: String) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	mesh.radial_segments = 12
	mesh.rings = 6
	var instance := _mesh(parent, label, mesh, point, material)
	instance.scale = size
	return instance

func _cylinder(parent: Node3D, label: String, radius: float, length: float, point: Vector3, material: String, top: float = -1.0, sides: int = 12) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.bottom_radius = radius
	mesh.top_radius = radius if top < 0.0 else top
	mesh.height = length
	mesh.radial_segments = sides
	mesh.rings = 1
	return _mesh(parent, label, mesh, point, material)

func _ring(parent: Node3D, label: String, inner: float, outer: float, point: Vector3, material: String) -> MeshInstance3D:
	var mesh := TorusMesh.new()
	mesh.inner_radius = inner
	mesh.outer_radius = outer
	mesh.rings = 24
	mesh.ring_segments = 6
	var instance := _mesh(parent, label, mesh, point, material)
	instance.rotation.x = PI * 0.5
	return instance

func _extrude(parent: Node3D, label: String, polygon: Array[Vector2], thickness: float, point: Vector3, material: String) -> MeshInstance3D:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var center := Vector2.ZERO
	var signed_area: float = 0.0
	for index in range(polygon.size()):
		var a: Vector2 = polygon[index]
		var b: Vector2 = polygon[(index + 1) % polygon.size()]
		signed_area += a.x * b.y - b.x * a.y
	for vertex in polygon:
		center += vertex
	center /= float(polygon.size())
	for index in range(polygon.size()):
		var a: Vector2 = polygon[index]
		var b: Vector2 = polygon[(index + 1) % polygon.size()]
		for side in [-1.0, 1.0]:
			var y: float = thickness * side * 0.5
			surface.set_normal(Vector3.UP * side)
			surface.add_vertex(Vector3(center.x, y, center.y))
			surface.add_vertex(Vector3(a.x, y, a.y))
			surface.add_vertex(Vector3(b.x, y, b.y))
		var va := Vector3(a.x, -thickness * 0.5, a.y)
		var vb := Vector3(b.x, -thickness * 0.5, b.y)
		var vc := Vector3(b.x, thickness * 0.5, b.y)
		var vd := Vector3(a.x, thickness * 0.5, a.y)
		var edge: Vector2 = b-a
		surface.set_normal(Vector3(edge.y,0,-edge.x).normalized() * signf(signed_area))
		for vertex in [va, vb, vc, va, vc, vd]:
			surface.add_vertex(vertex)
	return _mesh(parent, label, surface.commit(), point, material)

func _engine(parent: Node3D, point: Vector3, radius: float = 0.34, tint: String = "cyan") -> void:
	var engine := _node(parent, "Engine", point)
	var body := _cylinder(engine, "TurbineHousing", radius * 1.28, 0.9, Vector3.ZERO, "dark", radius * 1.05)
	body.rotation.x = PI * 0.5
	_ring(engine, "NozzleRim", radius * 0.84, radius * 1.05, Vector3(0, 0, 0.48), "edge")
	var glow := _cylinder(engine, "HotCore", radius * 0.82, 0.06, Vector3(0, 0, 0.5), tint)
	glow.rotation.x = PI * 0.5
	var plume := _node(engine, "ExhaustPlume", Vector3(0, 0, 0.5))
	var flame := _cylinder(plume, "OuterFlame", radius * 0.78, 2.0, Vector3(0, 0, 1.0), tint, 0.01, 8)
	flame.rotation.x = PI * 0.5
	var flame_core := _cylinder(plume, "InnerFlame", radius * 0.42, 1.4, Vector3(0, 0, 0.7), "warm", 0.0, 6)
	flame_core.rotation.x = PI * 0.5
	_flames.append(plume)

func _build_arrow() -> void:
	_extrude(visual, "Keel", [Vector2(0, -3.1), Vector2(0.63, -1.4), Vector2(0.78, 1.6), Vector2(0.46, 2.2), Vector2(-0.46, 2.2), Vector2(-0.78, 1.6), Vector2(-0.63, -1.4)], 0.6, Vector3.ZERO, "ivory")
	_extrude(visual, "UpperFuselage", [Vector2(0, -2.8), Vector2(0.46, -0.95), Vector2(0.48, 1.5), Vector2(-0.48, 1.5), Vector2(-0.46, -0.95)], 0.28, Vector3(0, 0.4, 0), "white")
	_extrude(visual, "NoseStripe", [Vector2(0, -2.9), Vector2(0.12, -1.5), Vector2(-0.12, -1.5)], 0.012, Vector3(0, 0.555, 0), "orange")
	_sphere(visual, "Canopy", Vector3(0.46, 0.37, 0.91), Vector3(0, 0.64, -0.6), "glass")
	_box(visual, "CanopySpine", Vector3(0.055, 0.035, 1.7), Vector3(0, 1.01, -0.55), "edge")
	_box(visual, "NoseSensor", Vector3(0.1, 0.06, 0.42), Vector3(0, 0.35, -2.65), "cyan")
	for side in [-1.0, 1.0]:
		var wing := _node(visual, "Wing", Vector3(side * 0.42, 0.02, 0.1))
		wing.set_meta("side", side)
		var polygon: Array[Vector2] = [Vector2(0, -0.8), Vector2(side * 0.65, -0.55), Vector2(side * 3.05, 1.0), Vector2(side * 2.8, 1.55), Vector2(0, 0.8)]
		_extrude(wing, "SweptWing", polygon, 0.15, Vector3.ZERO, "ivory")
		_extrude(wing, "WingStripe", [Vector2(side * 0.95, -0.27), Vector2(side * 1.25, -0.07), Vector2(side * 2.8, 1.06), Vector2(side * 2.6, 1.25)], 0.015, Vector3(0, 0.083, 0), "orange")
		_extrude(wing, "Aileron", [Vector2(side * 1.0, 0.85), Vector2(side * 2.8, 1.4), Vector2(side * 2.4, 1.69), Vector2(side * 0.9, 1.05)], 0.1, Vector3(0, 0.03, 0), "dark")
		_box(wing, "WingTipLight", Vector3(0.08, 0.11, 0.46), Vector3(side * 2.96, 0.02, 1.03), "cyan")
		_flaps.append(wing)
		var stabilizer := _extrude(visual, "RearStabilizer", [Vector2(0, 0), Vector2(side * 1.25, 0.7), Vector2(side * 1.0, 1.08), Vector2(0, 0.48)], 0.12, Vector3(side * 0.43, 0.36, 1.06), "ivory")
		stabilizer.rotation.z = side * 0.35
		_box(visual, "GunRail", Vector3(0.14, 0.17, 1.8), Vector3(side * 1.2, -0.06, -0.06), "dark")
		_box(visual, "GunMuzzle", Vector3(0.11, 0.12, 0.13), Vector3(side * 1.2, -0.06, -1.02), "cyan")
		_engine(visual, Vector3(side * 0.92, -0.07, 1.52), 0.35)
	var fin := _extrude(visual, "DorsalFin", [Vector2(0, -0.5), Vector2(0.9, 0.6), Vector2(0.9, 1.2), Vector2(0, 1.1)], 0.12, Vector3(0, 0.43, 0.8), "orange")
	fin.rotation.z = PI * 0.5
	if kind == "wingman":
		_materials["orange"].albedo_color = _materials["tint"].albedo_color

func _build_enemy(interceptor: bool, bomber: bool) -> void:
	var width: float = 1.45 if bomber else 0.7
	var length: float = 3.8 if interceptor else 2.9
	_extrude(visual, "EnemyHull", [Vector2(0, -length), Vector2(width, -0.7), Vector2(width, 1.2), Vector2(0, 1.8), Vector2(-width, 1.2), Vector2(-width, -0.7)], 0.7 if bomber else 0.45, Vector3.ZERO, "armor")
	_sphere(visual, "SensorCanopy", Vector3(0.47, 0.28, 0.6), Vector3(0, 0.43, -0.6), "red")
	for side in [-1.0, 1.0]:
		var span: float = 3.0 if bomber else (2.1 if interceptor else 2.6)
		var wing := _node(visual, "EnemyWing", Vector3(side * width * 0.7, 0, 0.25))
		wing.set_meta("side", side)
		_extrude(wing, "Blade", [Vector2(0, -1.0), Vector2(side * span, -1.7 if interceptor else 0.3), Vector2(side * span * 0.8, 1.4), Vector2(0, 0.7)], 0.18, Vector3.ZERO, "orange" if bomber else "dark")
		_box(wing, "RedEdge", Vector3(0.1, 0.12, 0.65), Vector3(side * span * 0.85, 0.1, 0.6), "red")
		_flaps.append(wing)
		_engine(visual, Vector3(side * width * 0.75, -0.1, 1.38), 0.32 if bomber else 0.24, "red")
		if bomber:
			var pod := _cylinder(visual, "BombPod", 0.5, 2.6, Vector3(side * 2.3, -0.5, 0.4), "dark", 0.35, 8)
			pod.rotation.x = PI * 0.5
			_box(visual, "BombPort", Vector3(0.48, 0.25, 0.15), Vector3(side * 2.3, -0.5, -0.94), "warm")

func _weak_point(parent: Node3D, point: Vector3, radius: float = 0.85, color: String = "red") -> Node3D:
	var marker := _node(parent, "WeaponNode" + str(weak_points.size() + 1), point)
	_sphere(marker, "TargetCore", Vector3.ONE * radius, Vector3.ZERO, color)
	_ring(marker, "ArmorCollar", radius * 1.05, radius * 1.28, Vector3(0, 0, -0.1), "gold")
	_box(marker, "Sight", Vector3(radius * 0.3, radius * 1.8, 0.12), Vector3(0, 0, -radius * 0.94), "black")
	weak_points.append(marker)
	return marker

func _build_frigate() -> void:
	_extrude(visual, "FrigateKeel", [Vector2(0, -8), Vector2(3.4, -4.3), Vector2(3.2, 5.5), Vector2(-3.2, 5.5), Vector2(-3.4, -4.3)], 3.0, Vector3.ZERO, "armor")
	_extrude(visual, "ArmoredSpine", [Vector2(0, -7), Vector2(1.35, -2.4), Vector2(1.35, 5.2), Vector2(-1.35, 5.2), Vector2(-1.35, -2.4)], 0.9, Vector3(0, 1.8, 0), "edge")
	for side in [-1.0, 1.0]:
		_extrude(visual, "DreadWing", [Vector2(0, -2), Vector2(side * 9.2, -1), Vector2(side * 8.2, 4.7), Vector2(side * 2.4, 4.0)], 1.0, Vector3(side * 1.5, 0, 0), "dark")
		_extrude(visual, "DreadWingArmor", [Vector2(0, -0.8), Vector2(side * 7.0, -0.2), Vector2(side * 6.3, 2.0), Vector2(side * 1.8, 1.8)], 0.24, Vector3(side * 2.0, 0.64, 0.5), "armor")
		_box(visual, "WarningStripe", Vector3(0.55, 0.14, 4.3), Vector3(side * 6.5, 0.75, 1.3), "orange")
		var pod := _cylinder(visual, "GunPod", 1.1, 5.0, Vector3(side * 7.0, 0, -0.7), "edge", 0.85, 8)
		pod.rotation.x = PI * 0.5
		_weak_point(visual, Vector3(side * 7.0, 0, -3.25), 0.88)
		_engine(visual, Vector3(side * 2.0, -0.2, 5.5), 0.9, "red")
	core = _weak_point(visual, Vector3(0, 0.0, -7.5), 1.35, "warm")
	_box(visual, "Bridge", Vector3(2.8, 0.8, 3.0), Vector3(0, 2.6, 1), "dark")
	_box(visual, "BridgeWindow", Vector3(2.3, 0.3, 0.15), Vector3(0, 2.7, -0.55), "red")
	for z in [-3.4, -1.1, 1.2, 3.5]:
		_box(visual, "DeckRib", Vector3(3.0, 0.12, 0.3), Vector3(0, 2.31, z), "orange")

func _build_rime() -> void:
	_sphere(visual, "RimeCarapace", Vector3(4.4, 3.1, 3.9), Vector3.ZERO, "armor")
	var waist := _cylinder(visual, "RimeWaist", 3.7, 3.5, Vector3(0, -0.2, 0), "dark", 2.9, 8)
	waist.rotation.x = PI * 0.5
	core = _weak_point(visual, Vector3(0, 0.1, -3.7), 1.55, "purple")
	var rotor := _node(visual, "CoreIris", Vector3(0, 0.1, -3.5))
	_rotors.append(rotor)
	for index in range(8):
		var angle: float = float(index) * TAU / 8.0
		var blade := _box(rotor, "IrisTooth", Vector3(0.65, 1.5, 0.4), Vector3(cos(angle) * 2.05, sin(angle) * 2.05, 0), "edge")
		blade.rotation.z = angle - PI * 0.5
	for index in range(6):
		var angle: float = float(index) * TAU / 6.0 + PI / 6.0
		var base := Vector3(cos(angle) * 3.0, sin(angle) * 2.4, 0)
		var anchor := _node(visual, "Tentacle" + str(index + 1), base)
		_sphere(anchor, "Hip", Vector3.ONE * 0.72, Vector3.ZERO, "gold")
		var pieces: Array[Node3D] = []
		for segment in range(3):
			var piece := _cylinder(visual, "ArmSegment", 0.48 - segment * 0.07, 1.0, Vector3.ZERO, "edge" if segment % 2 == 0 else "dark", -1, 8)
			pieces.append(piece)
		var tip := _weak_point(visual, Vector3.ZERO, 0.85, "red" if index % 2 == 0 else "warm")
		_arms.append({"base":base, "angle":angle, "pieces":pieces, "tip":tip, "index":index, "collapse":0.0})
		_box(visual, "CarapaceStripe", Vector3(0.22, 1.1, 0.15), Vector3(cos(angle) * 2.6, sin(angle) * 2.6, -2.8), "orange")
	_engine(visual, Vector3(-1.8, 0, 3.5), 0.8, "purple")
	_engine(visual, Vector3(1.8, 0, 3.5), 0.8, "purple")
	_pose_arms(0.0)

func _build_carrier(hostile: bool) -> void:
	# The broad head, heavy thorax and seven tapering tail sections follow
	# Project Barrel Roll's Dragonfly carrier; the armor/deck/iris are original.
	_extrude(visual, "Thorax", [Vector2(-4,-9),Vector2(4,-9),Vector2(6,-3),Vector2(5,9),Vector2(-5,9),Vector2(-6,-3)], 5.4, Vector3.ZERO, "armor")
	_extrude(visual, "RaisedSpine", [Vector2(-1.8,-9),Vector2(1.8,-9),Vector2(2,7),Vector2(-2,7)], 1.2, Vector3(0,3.0,0), "edge")
	_box(visual, "Belly", Vector3(7, 1.0, 15), Vector3(0,-3.0,0), "dark")
	for side in [-1.0, 1.0]:
		_extrude(visual, "HeadLobe", [Vector2(-3,-4),Vector2(3,-4),Vector2(4,-1),Vector2(3,5),Vector2(-3,5)], 4.9, Vector3(side * 7.5,0,-11.0), "armor")
		_box(visual, "Brow", Vector3(5.7,0.7,1.2), Vector3(side*7.5,2.3,-15.0), "edge")
		_box(visual, "Eye", Vector3(4.6,0.65,0.22), Vector3(side*7.5,1.25,-15.13), "red" if hostile else "cyan")
		_box(visual, "CheekPanel", Vector3(4.4,1.8,0.18), Vector3(side*7.5,-0.9,-15.15), "dark")
		_box(visual, "CheekMark", Vector3(2.5,0.25,0.2), Vector3(side*7.5,-1.1,-15.26), "orange" if hostile else "gold")
		_box(visual, "LaunchRail", Vector3(0.3,0.25,10), Vector3(side*2.7,-2.3,-15), "red" if hostile else "cyan")
		_engine(visual, Vector3(side * 4.5,-0.4,8.0),1.25,"red" if hostile else "cyan")
		var door := _box(visual, "HangarDoor", Vector3(2.5,3.5,0.4),Vector3(side*1.45,-0.2,-10),"dark")
		_parts["door" + str(int(side))] = door
		if hostile:
			_weak_point(visual,Vector3(side*7.5,-0.9,-15.5),1.4,"red")
	_box(visual,"CommandBridge",Vector3(5.3,1.7,3.5),Vector3(0,4.4,-6.0),"dark")
	_box(visual,"BridgeWindow",Vector3(4.6,0.6,0.15),Vector3(0,4.45,-7.8),"red" if hostile else "cyan")
	for index in range(7):
		var fraction: float = float(index) / 7.0
		var radius: float = lerpf(3.3,0.65,fraction)
		var piece := _cylinder(visual,"TailSegment" + str(index),radius,4.1,Vector3(0,0,11.5+index*4.5),"armor" if index%2==0 else "dark",radius*0.84,8)
		piece.rotation.x=PI*0.5
		_tail.append(piece)
		_box(visual,"TailBand",Vector3(radius*1.5,0.2,0.45),Vector3(0,radius*0.96,11.5+index*4.5),"edge")
	_box(visual,"TailBeacon",Vector3(0.45,0.45,0.6),Vector3(0,0,41),"red" if hostile else "cyan")
	for index in range(5):
		_box(visual,"DeckStripe",Vector3(8.0,0.08,0.3),Vector3(0,2.74,-4+index*2.2),"orange" if hostile else "cyan")
	if hostile:
		core = _weak_point(visual,Vector3(0,0,-11.4),2.1,"purple")
		var iris := _node(visual,"ReactorIris",Vector3(0,0,-11.2))
		_rotors.append(iris)
		for index in range(10):
			var angle: float = float(index)*TAU/10.0
			var tooth := _box(iris,"ReactorTooth",Vector3(0.6,1.4,0.4),Vector3(cos(angle)*2.8,sin(angle)*2.8,0),"gold")
			tooth.rotation.z=angle-PI*0.5

func _pose_arms(time: float, delta: float = 0.0) -> void:
	for arm in _arms:
		var angle: float = arm.angle
		var index: int = arm.index
		var curl: float = sin(time*1.65+index*0.9)
		var base: Vector3 = arm.base
		var reach: float = 8.2 + sin(time*1.1+index)*1.1
		var elbow := Vector3(cos(angle)*5.8,sin(angle)*5.0,1.2+curl*1.0)
		var wrist := Vector3(cos(angle+curl*0.12)*reach,sin(angle+curl*0.12)*reach*0.78,-0.6+curl)
		var end := Vector3(cos(angle+curl*0.18)*(reach+1.7),sin(angle+curl*0.18)*(reach+1.7)*0.78,-3.1+cos(time*1.2+index))
		var tip: Node3D = arm.tip
		var collapse: float = lerpf(float(arm.collapse), 0.0 if tip.visible else 1.0, 1.0-exp(-delta*3.4))
		arm.collapse=collapse
		elbow=elbow.lerp(base+Vector3(cos(angle)*1.5,-2.8,1.5),collapse)
		wrist=wrist.lerp(base+Vector3(cos(angle)*2.1,-5.0,2.0),collapse)
		end=end.lerp(base+Vector3(cos(angle)*2.4,-6.4,2.5),collapse)
		var points: Array[Vector3] = [base,elbow,wrist,end]
		var segments: Array = arm.pieces
		for segment in range(3):
			var piece: Node3D = segments[segment]
			var start: Vector3 = points[segment]
			var finish: Vector3 = points[segment+1]
			piece.position=(start+finish)*0.5
			piece.quaternion=Quaternion(Vector3.UP,(finish-start).normalized())
			piece.scale.y=start.distance_to(finish)
		tip.position=end
		tip.rotation.z=curl*0.18

func animate(time: float, delta: float, bank: float = 0.0, pitch: float = 0.0, thrust: float = 1.0, roll_angle: float = 0.0, damage: float = 0.0, maneuver_pitch: float = 0.0) -> void:
	if visual == null:
		return
	var blend: float = 1.0-exp(-delta*12.0)
	_bank=lerpf(_bank,clampf(bank,-1.2,1.2),blend)
	_pitch=lerpf(_pitch,clampf(pitch,-0.65,0.65),blend)
	# Full revolutions are added after the bounded steering pose. Never smooth a 360-degree spin by shortest arc.
	visual.rotation=Vector3(_pitch+maneuver_pitch,_facing,_bank+roll_angle)
	_damage=clampf(damage,0.0,1.0)
	for index in range(_flames.size()):
		var flame: Node3D = _flames[index]
		flame.scale=Vector3(1.0+sin(time*27.0+index)*0.05,1.0+cos(time*23.0+index)*0.05,maxf(0.15,thrust)*(0.85+sin(time*32.0+index)*0.12))
	for flap in _flaps:
		var side: float=flap.get_meta("side",1.0)
		flap.rotation.z=side*(0.045+maxf(0.0,1.0-thrust)*0.22)+_bank*0.12
		flap.rotation.x=_pitch*0.16+maxf(0.0,1.0-thrust)*0.16+sin(time*29.0+side)*_damage*0.018
	for index in range(_rotors.size()):
		_rotors[index].rotation.z=time*(0.34+float(index)*0.15)
	for index in range(_tail.size()):
		_tail[index].rotation.z=sin(time*0.8-float(index)*0.38)*0.018*float(index+1)/7.0
	if kind == "boss2":
		_pose_arms(time,delta)
	if kind == "carrier":
		for side in [-1,1]:
			var door: Node3D=_parts.get("door"+str(side))
			if door:
				door.position.x=float(side)*(1.45+1.2*(0.5+0.5*sin(time*0.35)))
	if _flash>0.0:
		_flash=maxf(0.0,_flash-delta)
		for key in ["ivory","armor","dark","edge","orange"]:
			var material: StandardMaterial3D=_materials[key]
			material.emission_enabled=_flash>0.0
			material.emission=Color(1.0,0.35,0.16)
			material.emission_energy_multiplier=_flash*7.5

func hit_flash() -> void:
	_flash=0.16
