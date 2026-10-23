extends RefCounted
## Shared forward-muzzle weapons. Bullets exist in world space independently of camera.
const Geometry = preload("res://scripts/duel/duel_geometry.gd")
const SPEED := 210.0
const RANGE := 300.0
const LIFE := 4.0
const COOLDOWN := 0.18
const DAMAGE := 6.0
var shots: Array[Dictionary] = []
var cooldowns := [0.0,0.0]
var events: Array[Dictionary] = []
var next_id := 0

func reset() -> void:
	shots.clear()
	cooldowns = [0.0,0.0]
	events.clear()
	next_id = 0

func fire(owner_id: int, vehicle: RefCounted, cover: Array) -> bool:
	if cooldowns[owner_id]>0.0 or shots.size()>124: return false
	var muzzle_blocked := false
	for side in [-1.0,1.0]:
		var muzzle: Vector3 = vehicle.muzzle(side)
		if not Geometry.first_cover(vehicle.position,muzzle,cover,.13).is_empty():
			muzzle_blocked = true
			continue
		next_id += 1
		shots.append({"id":next_id,"owner":owner_id,"position":muzzle,"previous":muzzle,"velocity":vehicle.forward()*SPEED,"life":LIFE,"travel":0.0})
	cooldowns[owner_id] = COOLDOWN
	if muzzle_blocked: events.append({"type":"muzzle_blocked","owner":owner_id})
	return not muzzle_blocked

func step(dt: float, actors: Array, cover: Array) -> Array[Dictionary]:
	var impacts: Array[Dictionary] = []
	for i in range(2): cooldowns[i] = maxf(0.0,float(cooldowns[i])-dt)
	for i in range(shots.size()-1,-1,-1):
		var shot: Dictionary = shots[i]
		var a: Vector3 = shot.position
		var travel_time := minf(dt,minf(float(shot.life),(RANGE-float(shot.travel))/SPEED))
		if travel_time<=0.0:
			shots.remove_at(i)
			continue
		var b: Vector3 = a+Vector3(shot.velocity)*travel_time
		var hit := Geometry.first_cover(a,b,cover,.13)
		var first := float(hit.t) if not hit.is_empty() else INF
		var target_id := -1
		for actor in actors:
			if int(actor.id)==int(shot.owner): continue
			# Relative sweep handles both a fast aircraft and a fast bolt.
			var t := Geometry.sphere_time(a-Vector3(actor.previous),b-Vector3(actor.position),Vector3.ZERO,4.0)
			if t<first:
				first = t
				target_id = int(actor.id)
		shot.previous = a
		shot.position = b
		shot.life -= dt
		shot.travel += SPEED*travel_time
		if first!=INF:
			var point := a.lerp(b,first)
			impacts.append({"type":"hit" if target_id>=0 else "cover","shot":shot.id,"owner":shot.owner,"target":target_id,"point":point,"damage":DAMAGE,"cover":hit.get("id","")})
			shots.remove_at(i)
		elif float(shot.life)<=0.0 or float(shot.travel)>=RANGE-.001:
			shots.remove_at(i)
	return impacts
