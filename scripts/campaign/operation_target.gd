extends RefCounted
## A live, resolved combat mark. Saves retain only the stable string ID.
const Actor = preload("res://scripts/campaign/operation_actor.gd")
const Geometry = preload("res://scripts/duel/duel_geometry.gd")
const COMPONENT_BASE := 1000
const CORE_UID := 1100
const PART_BASE := 2000
const PART_STRIDE := 8
enum Kind { AIRCRAFT, PART, COMPONENT, CORE }
var id := ""
var uid := -1
var actor_id := ""
var kind := Kind.AIRCRAFT
var point := Vector3.ZERO
var label := ""
var hp := 0.0

static func resolve(session: RefCounted, mark_id: String) -> RefCounted:
	var mark := new(); mark.id = mark_id
	var names := mark_id.split(":")
	if names.size()==2:
		var actor = session.actors.get(names[0])
		if actor==null or actor.team!=1 or actor.phase!="active" or actor.hp<=0 or not actor.parts.has(names[1]) or actor.parts[names[1]].hp<=0: return null
		mark.kind = Kind.PART; mark.actor_id = actor.id
		mark.uid = PART_BASE+actor.uid*PART_STRIDE+actor.parts.keys().find(names[1])
		mark.point = actor.vehicle.position+actor.vehicle.orientation()*Actor.point(actor.parts[names[1]].offset)
		mark.label = actor.display_name()+" / "+names[1]; mark.hp = actor.parts[names[1]].hp
	elif session.actors.has(mark_id):
		var actor = session.actors[mark_id]
		if actor.team!=1 or actor.phase!="active" or actor.hp<=0: return null
		mark.actor_id = actor.id; mark.uid = actor.uid; mark.point = actor.vehicle.position
		mark.label = actor.display_name(); mark.hp = actor.hp
	elif session.components.has(mark_id):
		var part: Dictionary = session.components[mark_id]
		if part.hp<=0 or part.disabled: return null
		mark.kind = Kind.COMPONENT; mark.uid = COMPONENT_BASE+session.components.keys().find(mark_id)
		mark.point = Actor.point(part.point); mark.label = mark_id; mark.hp = part.hp
	elif mark_id=="CORE" and session.core_hp>0:
		mark.kind = Kind.CORE; mark.uid = CORE_UID; mark.point = session.boss_position
		mark.label = "CORE"; mark.hp = session.core_hp
	else: return null
	return mark

func visible_from(origin: Vector3, cover: Array) -> bool:
	return Geometry.first_cover(origin,point,cover,.13).is_empty()

func firing_solution(vehicle: RefCounted, cover: Array, distance: float, alignment: float) -> bool:
	return vehicle.position.distance_to(point)<=distance and vehicle.forward().dot(vehicle.position.direction_to(point))>=alignment and visible_from(vehicle.muzzle(),cover)
