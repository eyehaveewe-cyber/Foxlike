extends RefCounted
## Peaceful six-axis thrusters. Neutral input can hold still; no cruise or combat state.
const Geometry = preload("res://scripts/duel/duel_geometry.gd")
const MAX_SPEED := 62.0
const BOOST_SPEED := 125.0
const RADIUS := 1800.0
var position := Vector3(0,12,245)
var previous_position := position
var velocity := Vector3.ZERO
var heading := 0.0
var pitch := 0.0
var assist := true
var status := "STATION KEEPING"

func reset() -> void:
	position = Vector3(0,12,245)
	previous_position = position
	velocity = Vector3.ZERO
	heading = 0.0
	pitch = 0.0
	assist = true
	status = "STATION KEEPING"

func basis() -> Basis:
	return Basis(Vector3.UP,heading)*Basis(Vector3.RIGHT,pitch)

func advance(dt: float, request: Dictionary, station: Node3D, asteroids: Array) -> void:
	var left := dt
	while left>.000001:
		var h := minf(left,1.0/60.0)
		_step(h,request,station,asteroids)
		left -= h

func _step(dt: float, request: Dictionary, station: Node3D, asteroids: Array) -> void:
	previous_position = position
	var turn: Vector2 = request.get("turn",Vector2.ZERO)
	turn = turn.limit_length()
	heading -= turn.x*dt*.85
	pitch = clampf(pitch+turn.y*dt*.85,-1.3,1.3)
	var movement: Vector3 = request.get("move",Vector3.ZERO)
	movement = movement.limit_length()
	var braking: bool = request.get("brake",false)
	var target_speed := BOOST_SPEED if request.get("boost",false) else MAX_SPEED
	if braking:
		velocity *= exp(-dt*5.0)
	elif movement.length()>.01:
		velocity = velocity.move_toward(basis()*movement*target_speed,dt*48.0)
	elif assist:
		velocity *= exp(-dt*2.5)
	velocity = velocity.limit_length(target_speed)
	if velocity.length()<.025: velocity = Vector3.ZERO
	var next := position+velocity*dt
	status = "FREE DRIFT" if not assist else "STATION KEEPING" if velocity.length()<.1 else "THRUSTERS"
	if station!=null and station.blocked(position,next,4.0):
		velocity = Vector3.ZERO
		status = "STATION PROXIMITY / HOLD"
		return
	for asteroid in asteroids:
		if float(asteroid.age)<5.0: continue
		if Geometry.sphere_time(position,next,asteroid.position,float(asteroid.radius)+4.0)!=INF:
			velocity = Vector3.ZERO
			status = "ASTEROID PROXIMITY / HOLD"
			return
	# Gentle outward travel arrest; always preserve the actual position.
	if next.length()>RADIUS and next.dot(velocity)>0.0:
		velocity *= exp(-dt*5.0)
		status = "OUTER ORBIT / BRAKING"
		return
	position = next
