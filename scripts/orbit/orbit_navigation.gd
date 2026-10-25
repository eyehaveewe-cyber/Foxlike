extends RefCounted
## Peaceful six-axis thrusters. Neutral input can hold still; no cruise or combat state.
const Geometry = preload("res://scripts/duel/duel_geometry.gd")
const MAX_SPEED := 62.0
const BOOST_SPEED := 125.0
const RADIUS := 100000.0
const TRAVEL_SPEED := 1500.0
var sector: Node3D
var travel_drive := false
var position := Vector3(0,12,245)
var previous_position := position
var velocity := Vector3.ZERO
var heading := 0.0
var pitch := 0.0
var engines_on := true
var assist := true
var status := "STATION KEEPING"

func reset() -> void:
	position = Vector3(0,12,245)
	previous_position = position
	velocity = Vector3.ZERO
	heading = 0.0
	pitch = 0.0
	travel_drive = false
	engines_on = true
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
	if travel_drive:
		var distance: float = request.get("drive_clearance",10000.0)
		target_speed = clampf((distance-400.0)*.65,BOOST_SPEED,TRAVEL_SPEED)
	if engines_on:
		if travel_drive and velocity.length()>target_speed:
			velocity = velocity.move_toward(velocity.normalized()*target_speed,dt*900.0)
		if braking:
			velocity *= exp(-dt*5.0)
		elif movement.length()>.01:
			# Thrusters accelerate along the nose; turning alone cannot redirect momentum.
			var acceleration := basis()*movement*(700.0 if travel_drive else 48.0)
			# A powered governor limits further acceleration, never trims a coast.
			if velocity.length()>=target_speed and acceleration.dot(velocity)>0.0:
				acceleration -= velocity.normalized()*acceleration.dot(velocity.normalized())
			var candidate := velocity+acceleration*dt
			velocity = candidate.limit_length(maxf(target_speed,velocity.length()))
		elif assist:
			velocity *= exp(-dt*2.5)
		if velocity.length()<.025: velocity = Vector3.ZERO
	var next := position+velocity*dt
	status = "ENGINE OFF / INERTIAL COAST" if not engines_on else "FREE DRIFT" if not assist else "STATION KEEPING" if velocity.length()<.1 else "THRUSTERS"
	if travel_drive and engines_on and not braking: status = "TRAVEL DRIVE / APPROACH GOVERNOR" if target_speed<TRAVEL_SPEED else "TRAVEL DRIVE"
	if sector!=null and sector.blocked(position,next,25.0):
		velocity = Vector3.ZERO
		status = "CELESTIAL PROXIMITY / HOLD"
		return
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
