class_name FoxGroundWalker
extends Node3D
## Two-legged ground vehicle. All gait offsets are local to this model.
## A future tactical actor can own the root transform and sample this visual rig.

const CYCLE_SECONDS := 1.35
const THIGH_LENGTH := 1.58
const SHIN_LENGTH := 1.58
const HIP_X := 1.35
const HIP_HEIGHT := 3.12
const ANKLE_HEIGHT := 0.48
const FOOT_REST := 0.21
const STRIDE := 0.72
const LIFT := 0.68

var walking := false
var gait_phase := 0.0
var motion_weight := 0.0
var body: Node3D
var legs: Array[Dictionary] = []
var foot_targets: Array[Vector3] = []
var hip_points: Array[Vector3] = []
var knee_points: Array[Vector3] = []
var ankle_points: Array[Vector3] = []

func _ready() -> void:
	build_model()
	sample_at(0.0, 0.0)

func material(color: Color, metal: float = 0.25, glow: float = 0.0) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.metallic = metal
	result.roughness = 0.53
	result.cull_mode = BaseMaterial3D.CULL_DISABLED
	if glow > 0.0:
		result.emission_enabled = true
		result.emission = color
		result.emission_energy_multiplier = glow
	return result

func part(parent: Node3D, label: String, mesh: Mesh, color: Color, point: Vector3 = Vector3.ZERO, glow: float = 0.0) -> MeshInstance3D:
	var result := MeshInstance3D.new()
	result.name = label
	result.mesh = mesh
	result.material_override = material(color, 0.18 if glow > 0.0 else 0.45, glow)
	result.position = point
	parent.add_child(result)
	return result

func box(parent: Node3D, label: String, size: Vector3, color: Color, point: Vector3 = Vector3.ZERO, glow: float = 0.0) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return part(parent, label, mesh, color, point, glow)

func sphere(parent: Node3D, label: String, radius: float, color: Color) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 12
	mesh.rings = 6
	return part(parent, label, mesh, color)

func tapered_hull() -> ArrayMesh:
	# Broad rear shoulders taper toward the direction of travel (-Z).
	var a := [
		Vector3(-2.12, 3.05, 1.40), Vector3(2.12, 3.05, 1.40),
		Vector3(-1.22, 3.08, -1.72), Vector3(1.22, 3.08, -1.72),
		Vector3(-2.22, 4.06, 1.32), Vector3(2.22, 4.06, 1.32),
		Vector3(-1.42, 3.98, -1.64), Vector3(1.42, 3.98, -1.64)]
	var faces := [[0, 1, 3, 2], [4, 6, 7, 5], [0, 2, 6, 4],
		[1, 5, 7, 3], [2, 3, 7, 6], [0, 4, 5, 1]]
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for quad: Array in faces:
		for triangle in [[0, 1, 2], [0, 2, 3]]:
			var p: Vector3 = a[quad[triangle[0]]]
			var q: Vector3 = a[quad[triangle[1]]]
			var r: Vector3 = a[quad[triangle[2]]]
			var normal := (q - p).cross(r - p).normalized()
			for vertex: Vector3 in [p, q, r]:
				surface.set_normal(normal)
				surface.add_vertex(vertex)
	return surface.commit()

func build_model() -> void:
	body = Node3D.new()
	body.name = "ArmoredBody"
	add_child(body)
	part(body, "TaperedHull", tapered_hull(), Color("40596a"))
	box(body, "RoofArmor", Vector3(2.85, 0.24, 2.22), Color("657d89"), Vector3(0, 4.12, 0.17))
	box(body, "Cabin", Vector3(2.15, 0.66, 1.72), Color("293c49"), Vector3(0, 4.52, 0.12))
	box(body, "FrontGlass", Vector3(1.80, 0.43, 0.10), Color("50bdd0"), Vector3(0, 4.55, -0.79), 1.0)
	box(body, "CabinCap", Vector3(2.31, 0.15, 1.93), Color("879da5"), Vector3(0, 4.91, 0.12))
	box(body, "NosePlate", Vector3(2.35, 0.34, 0.22), Color("8396a0"), Vector3(0, 3.39, -1.77))
	box(body, "Undercarriage", Vector3(2.55, 0.35, 2.44), Color("1b2c38"), Vector3(0, 2.96, 0.10))
	for side in [-1.0, 1.0]:
		box(body, "ShoulderArmor", Vector3(0.32, 0.72, 1.90), Color("81939d"), Vector3(side * 2.13, 3.65, 0.30))
		box(body, "NoseLamp", Vector3(0.30, 0.16, 0.10), Color("ffc672"), Vector3(side * 0.89, 3.56, -1.90), 1.9)
		box(body, "EngineVent", Vector3(0.35, 0.42, 0.91), Color("1a303a"), Vector3(side * 1.54, 3.47, 1.33))
		box(body, "SignalStripe", Vector3(0.14, 0.08, 1.42), Color("f4a653"), Vector3(side * 1.58, 4.17, 0.08), 0.35)
		var upper := box(self, "LeftThigh" if side < 0 else "RightThigh", Vector3(0.52, 1.0, 0.60), Color("849aa2"))
		var lower := box(self, "LeftShin" if side < 0 else "RightShin", Vector3(0.43, 1.0, 0.49), Color("526d79"))
		var hip := sphere(self, "LeftHip" if side < 0 else "RightHip", 0.46, Color("263d4b"))
		var knee := sphere(self, "LeftKnee" if side < 0 else "RightKnee", 0.34, Color("eda75e"))
		var ankle := sphere(self, "LeftAnkle" if side < 0 else "RightAnkle", 0.29, Color("9eb6b9"))
		var foot := Node3D.new()
		foot.name = "LeftFoot" if side < 0 else "RightFoot"
		add_child(foot)
		box(foot, "FootPad", Vector3(0.97, 0.36, 1.04), Color("344e5d"))
		box(foot, "ToeArmor", Vector3(1.06, 0.18, 0.39), Color("9fb1b6"), Vector3(0, 0.10, -0.40))
		box(foot, "ToeLamp", Vector3(0.36, 0.08, 0.09), Color("ffbf65"), Vector3(0, 0.09, -0.62), 1.2)
		legs.append({"side":side, "upper":upper, "lower":lower, "hip":hip,
			"knee":knee, "ankle":ankle, "foot":foot})
		foot_targets.append(Vector3.ZERO)
		hip_points.append(Vector3.ZERO)
		knee_points.append(Vector3.ZERO)
		ankle_points.append(Vector3.ZERO)

func set_walking(enabled: bool) -> void:
	walking = enabled

func _process(delta: float) -> void:
	advance(delta)

func advance(delta: float) -> void:
	if walking:
		gait_phase = fposmod(gait_phase + delta / CYCLE_SECONDS, 1.0)
	motion_weight = move_toward(motion_weight, 1.0 if walking else 0.0, delta * 3.0)
	pose(gait_phase, motion_weight)

func sample_at(progress: float, weight: float = 1.0) -> void:
	gait_phase = fposmod(progress, 1.0)
	motion_weight = clampf(weight, 0.0, 1.0)
	pose(gait_phase, motion_weight)

func pose(progress: float, weight: float) -> void:
	if body == null:
		return
	var bob := weight * 0.08 * pow(sin(TAU * progress * 2.0), 2.0)
	body.position.y = bob
	for i in legs.size():
		var leg: Dictionary = legs[i]
		var side: float = leg.side
		var step: float = fposmod(progress + (0.0 if i == 0 else 0.5), 1.0)
		var foot_z := 0.0
		var foot_y := FOOT_REST
		if step < 0.60:
			foot_z = lerpf(-STRIDE, STRIDE, step / 0.60)
		else:
			var swing := (step - 0.60) / 0.40
			foot_z = lerpf(STRIDE, -STRIDE, swing)
			foot_y += LIFT * sin(PI * swing)
		foot_z *= weight
		foot_y = lerpf(FOOT_REST, foot_y, weight)
		var foot := Vector3(side * HIP_X, foot_y, foot_z)
		var ankle := foot + Vector3(0, ANKLE_HEIGHT - FOOT_REST, 0.10)
		var hip := Vector3(side * HIP_X, HIP_HEIGHT + bob, 0.35)
		var span := ankle - hip
		var half := span.length() * 0.5
		var bend := sqrt(maxf(0.0, THIGH_LENGTH * THIGH_LENGTH - half * half))
		var direction := span.normalized()
		var backward := Vector3(0, direction.z, -direction.y).normalized()
		var knee := (hip + ankle) * 0.5 + backward * bend
		place_link(leg.upper, hip, knee)
		place_link(leg.lower, knee, ankle)
		leg.hip.position = hip
		leg.knee.position = knee
		leg.ankle.position = ankle
		leg.foot.position = foot
		foot_targets[i] = foot
		hip_points[i] = hip
		knee_points[i] = knee
		ankle_points[i] = ankle

func place_link(mesh: MeshInstance3D, start: Vector3, finish: Vector3) -> void:
	mesh.position = (start + finish) * 0.5
	mesh.quaternion = Quaternion(Vector3.UP, (finish - start).normalized())
	mesh.scale.y = start.distance_to(finish)
