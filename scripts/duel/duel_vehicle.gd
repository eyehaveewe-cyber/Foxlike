extends RefCounted
## One world-space locomotion authority for human and observed AI requests.
## Neutral model forward -Z, up +Y. No pilot identity enters this controller.
const Geometry = preload("res://scripts/duel/duel_geometry.gd")
const PROFILE := {"id":"arrow-duel-v1","brake":22.0,"cruise":38.0,"boost":60.0,"angular_rate":1.12,"pitch_limit":1.134464,"response":4.0,"boost_drain":28.0,"recharge":18.0,"extent":4.0,"roll_duration":0.68,"roll_cooldown":1.15}
var position := Vector3.ZERO
var previous_position := Vector3.ZERO
var heading := 0.0
var pitch := 0.0
var velocity := Vector3.ZERO
var speed := 38.0
var energy := 100.0
var depleted := false
var roll_time := 0.0
var roll_wait := 0.0
var roll_direction := 1.0
var bank := 0.0
var angular_rate := 0.0
var boundary := false
var boundary_side := 1.0
var boundary_events := 0
var denied := ""
var events: Array[String] = []
var contact_cooldown := 0.0
var pitch_hold := true

func reset(point: Vector3, yaw: float, tilt: float = 0.0) -> void:
	position = point
	previous_position = point
	heading = yaw
	pitch = tilt
	speed = PROFILE.cruise
	velocity = forward()*speed
	energy = 100.0
	depleted = false
	roll_time = 0.0
	roll_wait = 0.0
	boundary = false
	boundary_events = 0
	contact_cooldown = 0.0
	bank = 0.0
	angular_rate = 0.0
	denied = ""
	events.clear()

func orientation() -> Basis:
	return Basis(Vector3.UP,heading)*Basis(Vector3.RIGHT,pitch)

func forward() -> Vector3:
	return orientation()*Vector3.FORWARD

func muzzle(side: float = 0.0) -> Vector3:
	return position+orientation()*Basis(Vector3.BACK,bank+roll_angle())*Vector3(side*1.2,-0.05,-3.1)

func roll_angle() -> float:
	return roll_direction*TAU*smoothstep(0.0,1.0,1.0-roll_time/float(PROFILE.roll_duration)) if roll_time>0 else 0.0

func protected() -> bool:
	return roll_time>0.0

func warning(radius: float, ceiling: float) -> bool:
	var margin := speed/float(PROFILE.angular_rate)+float(PROFILE.extent)+12.0
	return Vector2(position.x,position.z).length()>radius-margin or (pitch>0.2 and position.y>ceiling-margin*.65) or (pitch<-.2 and position.y<margin*.65)

func step(dt: float, request: Dictionary, cover: Array, radius: float, ceiling: float) -> void:
	# Substep large frames: prediction and sweeps remain valid at 20/60/120 Hz.
	var remaining := dt
	events.clear()
	denied = ""
	while remaining>0.000001:
		var h := minf(remaining,1.0/120.0)
		_advance(h,request,cover,radius,ceiling)
		remaining -= h

func _advance(dt: float, request: Dictionary, cover: Array, radius: float, ceiling: float) -> void:
	previous_position = position
	roll_wait = maxf(0.0,roll_wait-dt)
	roll_time = maxf(0.0,roll_time-dt)
	contact_cooldown = maxf(0.0,contact_cooldown-dt)
	var steering: Vector2 = request.get("steer",Vector2.ZERO)
	steering = steering.limit_length()
	if not pitch_hold and absf(steering.y)<.01:
		steering.y = clampf(-pitch*.65,-.35,.35)
	var wants_boost: bool = request.get("boost",false)
	if not wants_boost: depleted = false
	if energy<=.01: depleted = true
	var boost_allowed := wants_boost and not depleted and energy>.01
	if wants_boost and not boost_allowed: denied = "BOOST EMPTY / RELEASE TO REARM"
	var throttle: float = PROFILE.boost if boost_allowed else (PROFILE.brake if request.get("brake",false) else PROFILE.cruise)
	var angular: float = PROFILE.angular_rate
	var extent: float = PROFILE.extent
	var radial := Vector3(position.x,0,position.z)
	var outward: float = radial.normalized().dot(forward())
	# Activate before a full-speed turn's worst outward excursion plus hull margin.
	var clearance := maxf(speed,38.0)/angular+extent+14.0
	var vertical_distance := ceiling-extent-position.y if pitch>0 else position.y-extent
	var vertical_needed := speed/angular*(1.0-cos(pitch))+5.0
	if not boundary and ((radial.length()>radius-clearance and outward>0.05) or (absf(pitch)>.08 and vertical_distance<vertical_needed)):
		boundary = true
		boundary_events += 1
		boundary_side = _choose_recovery(cover,radius,ceiling)
		events.append("boundary_begin")
	if boundary:
		# Level or descending at the roof; all changes use the ordinary rate cap.
		var target_yaw := atan2(radial.x,radial.z)
		var error := angle_difference(heading,target_yaw)
		steering = Vector2(-boundary_side,clampf(-pitch*2.0,-1.0,1.0)).limit_length()
		if absf(pitch)>.08 and vertical_distance<vertical_needed+4.0:
			steering = Vector2(0.0,-signf(pitch))
		if absf(error)<.28: steering.x = clampf(-error*3.0,-1.0,1.0)
		throttle = PROFILE.brake
		boost_allowed = false
		if radial.length()<radius-clearance*.7 and outward<-.35 and absf(pitch)<.15:
			boundary = false
			events.append("boundary_end")
	if request.get("roll",0.0)!=0.0 and roll_wait<=0.0 and not boundary:
		roll_time = PROFILE.roll_duration
		roll_wait = PROFILE.roll_cooldown
		roll_direction = signf(float(request.roll))
		events.append("roll")
	if request.get("maneuver","")!="": denied = "ARENA STUNTS DEFERRED"
	energy = clampf(energy+dt*(-float(PROFILE.boost_drain) if boost_allowed else float(PROFILE.recharge)),0.0,100.0)
	var old_forward := forward()
	heading -= steering.x*angular*dt
	pitch = clampf(pitch+steering.y*angular*dt,-float(PROFILE.pitch_limit),float(PROFILE.pitch_limit))
	var new_forward := forward()
	angular_rate = old_forward.angle_to(new_forward)/dt
	bank = -steering.x*.7
	var old_speed := speed
	speed = lerpf(speed,throttle,1.0-exp(-dt*float(PROFILE.response)))
	# Analytic distance under exponential acceleration avoids FPS-dependent travel.
	var distance: float = throttle*dt+(old_speed-throttle)*(1.0-exp(-dt*float(PROFILE.response)))/float(PROFILE.response)
	var desired := position+(old_forward+new_forward).normalized()*distance
	var hit := Geometry.first_cover(position,desired,cover,extent)
	if not hit.is_empty():
		if bool(hit.get("inside",false)):
			# A level reset should never spawn inside cover. Reject movement rather than snap out.
			desired = position
		else:
			desired = Vector3(hit.point)+Vector3(hit.normal)*.025
		var lost_speed := speed
		speed = minf(speed,12.0)
		denied = "SOLID COVER / TURN AWAY"
		if contact_cooldown<=0.0:
			events.append("collision:%s:%.1f" % [str(hit.id),lost_speed])
			contact_cooldown = 1.0
	# Hard envelope is a collision surface, not a position clamp or teleport.
	var horizontal := Vector2(desired.x,desired.z)
	if horizontal.length()>radius-extent:
		var wall := Vector3(horizontal.normalized().x,0,horizontal.normalized().y)
		var travel := desired-position
		var outward_travel := maxf(0.0,travel.dot(wall))
		desired -= wall*outward_travel
		speed = minf(speed,22.0)
		denied = "PERIMETER CONTACT"
	if desired.y<extent or desired.y>ceiling-extent:
		desired.y = position.y
		speed = minf(speed,22.0)
		denied = "HEIGHT CONTACT"
	position = desired
	velocity = (position-previous_position)/dt

func _choose_recovery(cover: Array, radius: float, ceiling: float) -> float:
	var best_side := 1.0
	var best_clearance := -INF
	for side in [-1.0,1.0]:
		var at := position
		var yaw := heading
		var tilt := pitch
		var score := INF
		for i in range(90):
			yaw += side*float(PROFILE.angular_rate)/30.0*.8
			tilt = move_toward(tilt,0.0,float(PROFILE.angular_rate)/30.0*.6)
			var next := at+(Basis(Vector3.UP,yaw)*Basis(Vector3.RIGHT,tilt)*Vector3.FORWARD)*speed/30.0
			score = minf(score,radius-Vector2(next.x,next.z).length())
			score = minf(score,minf(next.y,ceiling-next.y))
			if not Geometry.first_cover(at,next,cover,float(PROFILE.extent)).is_empty(): score -= 500.0
			at = next
		if score>best_clearance:
			best_clearance = score
			best_side = side
	return best_side

func snapshot() -> Dictionary:
	return {"position":[position.x,position.y,position.z],"velocity":[velocity.x,velocity.y,velocity.z],"speed":velocity.length(),"angular_rate":angular_rate,"energy":energy,"pitch":pitch,"heading":heading,"boundary":boundary,"roll":roll_time,"denied":denied}
