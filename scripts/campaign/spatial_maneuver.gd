extends RefCounted
## Powered arena envelopes. The complete path is checked before energy is spent.
const Geometry = preload("res://scripts/duel/duel_geometry.gd")
var kind := ""
var elapsed := 0.0
var duration := 0.0
var cooldown := 0.0
var origin := Vector3.ZERO
var axes := Basis.IDENTITY

func offset(time: float) -> Vector3:
	var u := clampf(time/(1.8 if kind=="corkscrew" else duration),0,1)
	match kind:
		"somersault": return Vector3(0,6*(1-cos(TAU*u)),-6*sin(TAU*u))
		"long_loop": return Vector3(0,18*(1-cos(TAU*u)),-60*u-18*sin(TAU*u))
		"corkscrew": return Vector3(8*sin(TAU*u),8*(1-cos(TAU*u)),-60*u-38*maxf(0,time-1.8))
	return Vector3.ZERO

func start(name: String, vehicle: RefCounted, cover: Array, radius: float, ceiling: float) -> bool:
	if not name in ["somersault","long_loop","corkscrew"] or not kind.is_empty() or cooldown>0 or vehicle.energy<30 or vehicle.roll_time>0 or vehicle.boundary: return false
	kind = name; duration = 1.25 if name=="somersault" else 2.65 if name=="long_loop" else 3.3
	origin = vehicle.position; axes = vehicle.orientation(); elapsed = 0
	var previous := origin
	for i in range(1,97):
		var point := origin+axes*offset(duration*i/96.0)
		if Vector2(point.x,point.z).length()>radius-4 or point.y<4 or point.y>ceiling-4 or not Geometry.first_cover(previous,point,cover,4).is_empty(): kind = ""; return false
		previous = point
	vehicle.energy -= 30; cooldown = 4
	return true

func advance(dt: float, vehicle: RefCounted, cover: Array) -> void:
	var previous: Vector3 = vehicle.position
	elapsed = minf(duration,elapsed+dt)
	var point := origin+axes*offset(elapsed)
	var hit := Geometry.first_cover(previous,point,cover,4)
	if not hit.is_empty():
		kind = ""; vehicle.speed = 12; vehicle.velocity = Vector3.ZERO; vehicle.denied = "MANEUVER INTERRUPTED / SOLID COVER"; return
	vehicle.previous_position = previous; vehicle.position = point
	vehicle.velocity = (point-previous)/maxf(dt,.000001); vehicle.speed = vehicle.velocity.length()
	var forward: Vector3 = axes*((offset(minf(duration,elapsed+.001))-offset(maxf(0,elapsed-.001))).normalized())
	if forward.length_squared()>.1:
		vehicle.heading = atan2(-forward.x,-forward.z)
		vehicle.pitch = atan2(forward.y,Vector2(forward.x,forward.z).length())
	if elapsed>=duration:
		vehicle.heading = atan2(-axes.z.x,-axes.z.z)+PI
		vehicle.pitch = asin(clampf(-axes.z.y,-1,1))
		vehicle.speed = minf(60,vehicle.speed); kind = ""

func reset() -> void: kind = ""; elapsed = 0; cooldown = 0
