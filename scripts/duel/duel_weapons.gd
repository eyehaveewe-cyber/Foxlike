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

func fire(owner_id: int, vehicle: RefCounted, cover: Array, team: int = -1) -> bool:
	while cooldowns.size()<=owner_id: cooldowns.append(0.0)
	if cooldowns[owner_id]>0.0 or shots.size()>380: return false
	var muzzle_blocked := false
	for side in [-1.0,1.0]:
		var muzzle: Vector3 = vehicle.muzzle(side)
		if not Geometry.first_cover(vehicle.position,muzzle,cover,.13).is_empty():
			muzzle_blocked = true
			continue
		next_id += 1
		shots.append({"id":next_id,"owner":owner_id,"team":owner_id if team<0 else team,"position":muzzle,"previous":muzzle,"velocity":vehicle.forward()*SPEED,"life":LIFE,"travel":0.0})
	cooldowns[owner_id] = COOLDOWN
	if muzzle_blocked: events.append({"type":"muzzle_blocked","owner":owner_id})
	return not muzzle_blocked

func launch(owner_id: int, team: int, origin: Vector3, direction: Vector3, damage: float = DAMAGE, speed: float = SPEED, life: float = LIFE, target: int = -1) -> void:
	if shots.size()>=384: return
	next_id += 1
	shots.append({"id":next_id,"owner":owner_id,"team":team,"position":origin,"previous":origin,"velocity":direction.normalized()*speed,"life":life,"travel":0.0,"damage":damage,"range":speed*life,"target_uid":target,"kind":"missile" if target>=0 else "laser"})

func step(dt: float, actors: Array, cover: Array) -> Array[Dictionary]:
	var impacts: Array[Dictionary] = []
	for i in range(cooldowns.size()): cooldowns[i] = maxf(0.0,float(cooldowns[i])-dt)
	for i in range(shots.size()-1,-1,-1):
		var shot: Dictionary = shots[i]
		if int(shot.get("target_uid",-1))>=0:
			for actor in actors:
				if actor.id==shot.target_uid:
					shot.velocity = Vector3(shot.velocity).slerp(Vector3(shot.position).direction_to(actor.position)*Vector3(shot.velocity).length(),minf(1,dt*3))
		var a: Vector3 = shot.position
		var speed: float = Vector3(shot.velocity).length()
		var range_limit: float = float(shot.get("range",RANGE))
		var travel_time := minf(dt,minf(float(shot.life),(range_limit-float(shot.travel))/maxf(speed,.001)))
		if travel_time<=0.0:
			shots.remove_at(i)
			continue
		var b: Vector3 = a+Vector3(shot.velocity)*travel_time
		var hit := Geometry.first_cover(a,b,cover,.13)
		var first := float(hit.t) if not hit.is_empty() else INF
		var target_id := -1
		for actor in actors:
			if int(actor.id)==int(shot.owner) or int(actor.get("team",actor.id))==int(shot.get("team",shot.owner)): continue
			# Relative sweep handles both a fast aircraft and a fast bolt.
			var t := Geometry.sphere_time(a-Vector3(actor.previous),b-Vector3(actor.position),Vector3.ZERO,float(actor.get("radius",4.0)))
			if t<first:
				first = t
				target_id = int(actor.id)
		shot.previous = a
		shot.position = b
		shot.life -= dt
		shot.travel += speed*travel_time
		if first!=INF:
			var point := a.lerp(b,first)
			impacts.append({"type":"hit" if target_id>=0 else "cover","shot":shot.id,"owner":shot.owner,"team":shot.get("team",shot.owner),"target":target_id,"point":point,"damage":shot.get("damage",DAMAGE),"cover":hit.get("id",""),"blast_radius":18.0 if shot.get("kind","")=="missile" else 0.0})
			shots.remove_at(i)
		elif float(shot.life)<=0.0 or float(shot.travel)>=range_limit-.001:
			shots.remove_at(i)
	return impacts
