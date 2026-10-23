extends RefCounted
## Authoritative arena navigation in world units. Combat is projected into a
## player-relative frame; turning never teleports or grants invulnerability.
const RADIUS := 210.0
const TURN_RADIUS := 184.0
const TURN_DURATION := 2.4
const ANCHOR := Vector3(0,0,5)
var position := Vector3(0,12,125)
var heading := 0.0
var turning := false
var turn_time := 0.0
var turn_from := 0.0
var turn_to := 0.0
var turn_base_height := 0.0
var bank := 0.0
var pitch := 0.0
var velocity := 38.0
var turn_count := 0

func reset() -> void:
	position = Vector3(0,12,125)
	heading = 0.0
	turning = false
	turn_time = 0.0
	bank = 0.0
	pitch = 0.0
	velocity = 38.0
	turn_count = 0

func basis() -> Basis:
	return Basis(Vector3.UP,heading)

func to_local(point: Vector3) -> Vector3:
	return basis().inverse()*(point-position)+ANCHOR

func to_world(point: Vector3) -> Vector3:
	return position+basis()*(point-ANCHOR)

func warning() -> bool:
	return Vector2(position.x,position.z).length()>162.0

func advance(dt: float, axis: Vector2, boost: bool, brake: bool) -> void:
	var radial := Vector3(position.x,0,position.z)
	var forward := basis()*Vector3.FORWARD
	if not turning and radial.length()>=TURN_RADIUS and radial.dot(forward)>0.0:
		turning = true
		turn_time = 0.0
		turn_from = heading
		turn_to = atan2(radial.x,radial.z)
		turn_base_height = position.y
		turn_count += 1
	if turning:
		turn_time += dt
		var t := clampf(turn_time/TURN_DURATION,0.0,1.0)
		heading = lerp_angle(turn_from,turn_to,smoothstep(0.0,1.0,t))
		position.y = turn_base_height+sin(t*PI)*8.0
		velocity = 8.0+24.0*pow(absf(t*2.0-1.0),2.0)
		bank = -signf(angle_difference(turn_from,turn_to))*sin(t*PI)*1.05
		pitch = -sin(t*TAU)*0.55
		if t>=1.0:
			turning = false
			position.y = turn_base_height
	else:
		heading -= axis.x*dt*1.12
		position.y = clampf(position.y+axis.y*dt*20.0,4.0,42.0)
		velocity = lerpf(velocity,60.0 if boost else (22.0 if brake else 38.0),1.0-exp(-dt*4.0))
		bank = -axis.x*0.7
		pitch = -axis.y*0.24
	position += basis()*Vector3.FORWARD*velocity*dt
	# Numerical containment for low frame rates and external test teleports.
	var horizontal := Vector2(position.x,position.z).limit_length(RADIUS-1.0)
	position.x = horizontal.x
	position.z = horizontal.y
