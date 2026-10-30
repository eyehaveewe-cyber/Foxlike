extends RefCounted
const Vehicle = preload("res://scripts/duel/duel_vehicle.gd")
const Pilot = preload("res://scripts/duel/duel_pilot.gd")
var id := ""
var uid := 0
var team := 1
var kind := "fighter"
var hp := 100.0
var max_hp := 100.0
var vehicle := Vehicle.new()
var pilot := Pilot.new()
var task := "regroup"
var target := ""
var goal := Vector3.ZERO
var path: Array[Vector3] = []
var waypoint := 0
var cooldown := 0.0
var level := 1
var phase := "active"
var critical := false
var radius := 4.0
var grace := 0.0
var route_side := 1.0
var parts: Dictionary = {}
var burst := 0
var burst_wait := 0.0

static func vec(v: Vector3) -> Array: return [v.x,v.y,v.z]
static func point(v: Array) -> Vector3: return Vector3(float(v[0]),float(v[1]),float(v[2]))

func snapshot() -> Dictionary:
	var motion := {}
	for key in ["position","previous_position","heading","pitch","velocity","speed","energy","depleted","roll_time","roll_wait","roll_direction","bank","angular_rate","boundary","boundary_side","boundary_events","contact_cooldown","pitch_hold"]:
		var value: Variant = vehicle.get(key)
		motion[key] = vec(value) if value is Vector3 else value
	return {"id":id,"uid":uid,"team":team,"kind":kind,"hp":hp,"max_hp":max_hp,"motion":motion,"profile":vehicle.profile.duplicate(true),"task":task,"target":target,"goal":vec(goal),"path":path.map(func(v):return vec(v)),"waypoint":waypoint,"cooldown":cooldown,"level":level,"phase":phase,"critical":critical,"radius":radius,"grace":grace,"route_side":route_side,"parts":parts.duplicate(true),"burst":burst,"burst_wait":burst_wait}

static func restore(record: Dictionary) -> RefCounted:
	var actor := new()
	for key in ["id","uid","team","kind","hp","max_hp","task","target","waypoint","cooldown","level","phase","critical","radius","grace","route_side"]: actor.set(key,record[key])
	actor.goal = point(record.goal)
	actor.parts = record.get("parts",{}).duplicate(true)
	actor.burst = int(record.get("burst",0)); actor.burst_wait = float(record.get("burst_wait",0))
	actor.vehicle.profile = record.get("profile",Vehicle.PROFILE).duplicate(true)
	for value in record.path: actor.path.append(point(value))
	for key in record.motion:
		actor.vehicle.set(key,point(record.motion[key]) if key in ["position","previous_position","velocity"] else record.motion[key])
	actor.pilot.reset(actor.vehicle.position)
	return actor
