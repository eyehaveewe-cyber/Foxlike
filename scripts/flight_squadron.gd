extends RefCounted
## Roster rules and saved loadout. Runtime damage, motion and projectiles belong to flight_game.
const FORMATIONS := ["WIDE V", "SPEARHEAD", "CLOSE GUARD"]
const ROSTER := [
	{"id":"latch","name":"LATCH","role":"Interceptor","hp":110.0,"interval":0.95,"damage":0.45,"ability":"guard","cooldown":9.0,"gate":-1,"color":"ffc075","description":"Dashes ahead to absorb an incoming shot."},
	{"id":"glint","name":"GLINT","role":"Rapid gunner","hp":75.0,"interval":0.28,"damage":0.24,"ability":"burst","cooldown":7.0,"gate":-1,"color":"7de3cb","description":"Fast lasers and a six-shot overdrive burst."},
	{"id":"pike","name":"PIKE","role":"Missile specialist","hp":95.0,"interval":0.90,"damage":0.40,"ability":"missile","cooldown":11.0,"gate":0,"color":"95baff","description":"Fires a homing missile at a forward target."},
	{"id":"ember","name":"EMBER","role":"Nova specialist","hp":90.0,"interval":1.20,"damage":0.45,"ability":"nova","cooldown":22.0,"gate":1,"color":"ff9679","description":"Launches a Nova with a local area blast."},
	{"id":"bastion","name":"BASTION","role":"Heavy bodyguard","hp":165.0,"interval":1.40,"damage":0.50,"ability":"guard","cooldown":4.5,"gate":2,"color":"d5a4ff","description":"Heavy shields and frequent shot interception."}
]

static func profile(id: String) -> Dictionary:
	for entry in ROSTER:
		if entry.id == id: return entry
	return {}

static func available(id: String, progress: Dictionary) -> bool:
	var pilot := profile(id)
	return not pilot.is_empty() and (int(pilot.gate)<0 or progress.get("completed_stages",[]).has(int(pilot.gate)))

static func unlock_text(pilot: Dictionary) -> String:
	return "READY" if int(pilot.gate)<0 else "Clear " + ["Viridia","Aurora","Terminus"][int(pilot.gate)]

static func normalize(progress: Dictionary) -> void:
	var completed: Array[int] = []
	var raw: Variant = progress.get("completed_stages",[])
	if raw is Array:
		for stage: Variant in raw:
			if (stage is int or stage is float) and stage == int(stage) and stage>=0 and stage<=2 and not completed.has(int(stage)):
				completed.append(int(stage))
	# Migration: old mission unlocks and positive clear records prove prior victories.
	for stage in range(clampi(int(progress.get("unlocked",1))-1,0,2)):
		if not completed.has(stage): completed.append(stage)
	var records: Variant = progress.get("records",{})
	if records is Dictionary:
		for stage in range(3):
			for difficulty in ["Cadet","Standard","Ace"]:
				if float(records.get("%d_%s" % [stage,difficulty],0))>0 and not completed.has(stage): completed.append(stage)
	completed.sort()
	progress.completed_stages = completed
	var selected: Array[String] = []
	raw = progress.get("companions",[])
	if raw is Array:
		for id: Variant in raw:
			if id is String and available(id,progress) and not selected.has(id) and selected.size()<2: selected.append(id)
	for id in ["latch","glint"]:
		if selected.size()<2 and not selected.has(id): selected.append(id)
	progress.companions = selected
	raw = progress.get("formation",0)
	progress.formation = clampi(int(raw),0,2) if (raw is int or raw is float) else 0

static func offset(formation: int, slot: int) -> Vector3:
	var side := -1.0 if slot==0 else 1.0
	match formation:
		1: return Vector3(side*3.8,1.0,-17.0-float(slot)*2.0)
		2: return Vector3(side*3.2,0.8,-5.0)
	return Vector3(side*10.0,2.5,-8.0-float(slot)*3.0)

static func ability_cooldown(wing: Dictionary) -> float:
	return float(profile(str(wing.id)).cooldown)/(1.0+0.18*float(int(wing.level)-1))
