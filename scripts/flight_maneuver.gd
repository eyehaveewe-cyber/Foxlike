extends RefCounted
## Controller-owned positions in flight space, forward -Z. Rig angles are radians.
## Sample from elapsed seconds, so frame rate cannot change the authored path.
enum Kind {NONE, SOMERSAULT, LONG_LOOP, CORKSCREW}
const ENERGY_COST := 30.0
const COOLDOWN := 4.0
const FLIP_TIME := 1.25
const SURGE_TIME := 0.45
const LOOP_TIME := 2.20
const CORK_WINDUP := 0.25
const CORK_TIME := 1.80
const SETTLE_TIME := 1.50
var kind: Kind = Kind.NONE
var elapsed := 0.0
var origin := Vector3.ZERO
var position := Vector3.ZERO
var pitch := 0.0
var roll := 0.0
var thrust := 1.0
var speed := 42.0
var recovering := false
var can_fire := true
var _anchor := Vector3.ZERO

func active() -> bool:
	return kind != Kind.NONE

func start(action: Kind, from: Vector3) -> void:
	kind = action
	elapsed = 0.0
	origin = from
	# Ease toward a safe loop center during the initial surge, never teleport.
	_anchor = Vector3(from.x,from.y,0.0) if action == Kind.SOMERSAULT else Vector3(clampf(from.x,-13.0,13.0),clampf(from.y,-6.0,2.0),0.0)
	_sample()

func reset() -> void:
	kind = Kind.NONE
	elapsed = 0.0
	pitch = 0.0
	roll = 0.0
	thrust = 1.0
	speed = 42.0
	recovering = false
	can_fire = true

func advance(dt: float) -> void:
	if not active(): return
	elapsed += dt
	var duration := CORK_TIME + SETTLE_TIME
	if kind == Kind.SOMERSAULT: duration = FLIP_TIME
	elif kind == Kind.LONG_LOOP: duration = SURGE_TIME + LOOP_TIME
	if elapsed >= duration:
		position = Vector3(_anchor.x,_anchor.y,0.0)
		reset()
		return
	_sample()

func _sample() -> void:
	pitch = 0.0
	roll = 0.0
	recovering = false
	can_fire = true
	if kind == Kind.SOMERSAULT:
		var t := smoothstep(0.0,1.0,elapsed/FLIP_TIME)
		pitch = TAU*t
		# Compact flip stays at the current X/Y; ease out any ordinary boost offset.
		position = Vector3(origin.x,origin.y,origin.z*(1.0-t))
		speed = lerpf(60.0,42.0,t)
		thrust = 1.0+sin(PI*t)*0.8
		can_fire = false
	elif kind == Kind.LONG_LOOP:
		if elapsed < SURGE_TIME:
			var t := smoothstep(0.0,1.0,elapsed/SURGE_TIME)
			position = origin.lerp(_anchor+Vector3(0,0,-16),t)
			speed = lerpf(42.0,88.0,t)
			thrust = lerpf(1.0,2.4,t)
		else:
			var t := smoothstep(0.0,1.0,(elapsed-SURGE_TIME)/LOOP_TIME)
			pitch = TAU*t
			position = _anchor+Vector3(0,5.0*(1.0-cos(pitch)),-16.0*(1.0-t)-8.0*sin(pitch))
			speed = lerpf(88.0,42.0,t)
			thrust = lerpf(2.4,1.0,t)
			can_fire = false # Don't emit forward lasers while the airframe faces backwards.
	else:
		var direction := 1.0
		if elapsed < CORK_WINDUP:
			var t := smoothstep(0.0,1.0,elapsed/CORK_WINDUP)
			position = origin.lerp(_anchor+Vector3(0,0,-4),t)
			speed = lerpf(42.0,65.0,t)
			thrust = lerpf(1.0,1.7,t)
		elif elapsed < CORK_TIME:
			var t := smoothstep(0.0,1.0,(elapsed-CORK_WINDUP)/(CORK_TIME-CORK_WINDUP))
			var angle := TAU*t
			roll = -direction*angle
			pitch = sin(PI*t)*0.28
			position = _anchor+Vector3(direction*4.0*sin(angle),3.0*t+3.5*(1.0-cos(angle)),-4.0-14.0*t)
			speed = lerpf(65.0,88.0,smoothstep(0.0,0.45,t))
			thrust = lerpf(1.7,2.4,smoothstep(0.0,0.45,t))
		else:
			recovering = true
			var t := smoothstep(0.0,1.0,(elapsed-CORK_TIME)/SETTLE_TIME)
			position = _anchor+Vector3(0,3.0*(1.0-t),-18.0*(1.0-t))
			speed = lerpf(88.0,42.0,t)
			thrust = lerpf(2.4,1.0,t)

func label() -> String:
	if recovering: return "SETTLING"
	match kind:
		Kind.SOMERSAULT: return "SOMERSAULT"
		Kind.LONG_LOOP: return "LONG LOOP"
		Kind.CORKSCREW: return "CORKSCREW"
	return ""
