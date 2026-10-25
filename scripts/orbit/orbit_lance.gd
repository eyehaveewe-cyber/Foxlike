extends Node3D
## A powered fantasy tether. Asteroid integration and collision remain authoritative.
const RANGE := 700.0
var held: Dictionary = {}
var charge := 0.0
var message := "G / LMB catch asteroid"
var beam: MeshInstance3D

func _ready() -> void:
	beam = MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = .28
	cylinder.bottom_radius = .6
	cylinder.radial_segments = 8
	beam.mesh = cylinder
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color("9cfaff")
	material.emission_enabled = true
	material.emission = Color("49dfff")
	material.emission_energy_multiplier = 3.0
	beam.material_override = material
	beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(beam)
	beam.hide()

func candidate(nav: RefCounted, field: Node3D, station: Node3D) -> Dictionary:
	var best: Dictionary = {}
	var score := -INF
	if not field.enabled: return best
	var forward: Vector3 = -nav.basis().z
	for rock in field.visitors:
		if float(rock.age)<5.0: continue
		var offset: Vector3 = rock.position-nav.position
		var distance := offset.length()
		if distance>RANGE or distance<float(rock.radius)+12.0: continue
		var alignment := forward.dot(offset.normalized())
		if alignment<.94: continue
		if station.blocked(nav.position,rock.position,.5): continue
		var value := alignment*1000.0-distance*.05
		if value>score:
			best = rock
			score = value
	return best

func trigger(nav: RefCounted, field: Node3D, station: Node3D) -> void:
	if not held.is_empty():
		var forward: Vector3 = -nav.basis().z
		var swing: Vector3 = (held.velocity-nav.velocity).limit_length(140.0)
		held.velocity = nav.velocity+forward*lerpf(120.0,320.0,charge)+swing*.7
		message = "FLUNG / %.0f m/s" % held.velocity.length()
		cancel()
		return
	held = candidate(nav,field,station)
	charge = 0.0
	message = "LANCE LOCKED / G or LMB to fling" if not held.is_empty() else "NO LOCK / aim nose at a visible asteroid within 700 m"

func cancel() -> void:
	if not held.is_empty(): held.erase("tether_anchor")
	held = {}
	charge = 0.0
	if is_instance_valid(beam): beam.hide()

func prepare(dt: float, nav: RefCounted, field: Node3D, station: Node3D) -> void:
	if held.is_empty(): return
	if not field.enabled or not field.visitors.has(held) or not is_instance_valid(held.node):
		cancel()
		return
	if nav.position.distance_to(held.position)>RANGE*1.3 or station.blocked(nav.position,held.position,.5):
		message = "TETHER BROKEN / cover or range"
		cancel()
		return
	charge = minf(1.0,charge+dt/2.0)
	held.tether_anchor = nav.position-nav.basis().z*(70.0+float(held.radius))
	held.tether_velocity = nav.velocity
	# Keep a held visitor alive; release returns it to the ordinary lifetime clock.
	held.life = maxf(float(held.life),float(held.age)+20.0)

func update_beam(nav: RefCounted) -> void:
	if held.is_empty():
		beam.hide()
		return
	var start: Vector3 = nav.position-nav.basis().z*6.0
	var offset: Vector3 = held.position-start
	beam.position = start+offset*.5
	beam.basis = Basis(Quaternion(Vector3.UP,offset.normalized()))
	beam.scale = Vector3(1.0+charge,offset.length()*.5,1.0+charge)
	beam.show()
