extends RefCounted
## Jet-assisted tank: finite hover fuel, gravity and a grounded recharge.
const GROUND_Y := -2.0
const CEILING_Y := 8.0
var height := GROUND_Y
var vertical_speed := 0.0
var fuel := 100.0
var exhausted := false
var hovering := false

func reset() -> void:
	height = GROUND_Y
	vertical_speed = 0.0
	fuel = 100.0
	exhausted = false
	hovering = false

func advance(dt: float, held: bool) -> void:
	if not held: exhausted = false
	if fuel<=0.0: exhausted = true
	hovering = held and not exhausted and fuel>0.0
	if hovering:
		fuel = maxf(0.0,fuel-26.0*dt)
		vertical_speed = move_toward(vertical_speed,10.0,30.0*dt)
	else:
		vertical_speed = maxf(-15.0,vertical_speed-24.0*dt)
	height = clampf(height+vertical_speed*dt,GROUND_Y,CEILING_Y)
	if height>=CEILING_Y: vertical_speed = minf(0.0,vertical_speed)
	if height<=GROUND_Y:
		vertical_speed = maxf(0.0,vertical_speed)
		if not hovering: fuel = minf(100.0,fuel+35.0*dt)
