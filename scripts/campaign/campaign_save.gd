extends RefCounted
## Versioned stable-ID saves and atomic, idempotent result/checkpoint settlement.
const Catalog = preload("res://scripts/campaign/operation_catalog.gd")
const VERSION := 2
var path := "user://foxlike_save.json"
var data: Dictionary = {}
var error := ""

func fresh() -> Dictionary:
	return {"version":VERSION,"completed":[],"legacy_access":[],"records":{},"companions":["latch","glint"],"companion_condition":{},"formation":0,"muted":false,"difficulty":"Standard","best":0,"frontier":Catalog.IDS[0],"checkpoint":{},"rivals":{},"rescues":[],"carrier":{"hull":100.0,"drive_overstrained":false,"parts_secured":false,"repaired":false},"settled":[],"finished":false,"settings":Catalog.DEFAULTS.duplicate(true),"bindings":{},"pad_bindings":{}}

func _init() -> void: data = fresh()

func decode(raw: Variant) -> Dictionary:
	error = ""
	if not raw is Dictionary:
		error = "The save is malformed. Keep it for recovery or explicitly start a new campaign."
		return {}
	if raw.has("version") and (not (raw.version is int or raw.version is float) or raw.version>VERSION):
		error = "This save needs a newer game version. Its progress has not been overwritten."
		return {}
	var result := fresh()
	for key in ["muted","difficulty","companions","formation","best"]:
		if raw.has(key): result[key] = raw[key]
	if not result.muted is bool: result.muted = false
	if not result.difficulty in ["Cadet","Standard","Ace"]: result.difficulty = "Standard"
	result.formation = clampi(int(result.formation),0,2) if result.formation is float or result.formation is int else 0
	result.best = clampi(int(result.best),0,999999999) if result.best is float or result.best is int else 0
	if int(raw.get("version",0))==VERSION:
		for key in ["records","checkpoint","rivals","carrier","settings","bindings","pad_bindings","companion_condition"]:
			if raw.get(key) is Dictionary: result[key].merge(raw[key],true)
		for key in ["completed","legacy_access","rescues","settled"]:
			if raw.get(key) is Array: result[key] = raw[key].duplicate(true)
		result.completed = result.completed.filter(func(id):return id in Catalog.IDS)
		result.legacy_access = result.legacy_access.filter(func(id):return id in Catalog.IDS)
		result.frontier = raw.get("frontier",Catalog.IDS[0])
		if not result.frontier in Catalog.IDS: result.frontier = Catalog.IDS[0]
		result.finished = raw.get("finished",false)==true
	else:
		var unlocked := clampi(int(raw.get("unlocked",1)),1,6) if raw.get("unlocked",1) is float or raw.get("unlocked",1) is int else 1
		for i in range(unlocked): result.legacy_access.append(Catalog.LEGACY[i])
		var cleared: Array = raw.get("completed_stages",[]) if raw.get("completed_stages",[]) is Array else []
		for i in range(unlocked-1):
			if not cleared.has(i): cleared.append(i)
		for item in cleared:
			if (item is float or item is int) and item==int(item) and item>=0 and item<6:
				var id: String = Catalog.LEGACY[int(item)]
				if not result.completed.has(id): result.completed.append(id)
		if raw.get("records") is Dictionary:
			for key in raw.records:
				var parts := str(key).split("_")
				if parts.size()==2 and parts[0].is_valid_int() and int(parts[0]) in range(6) and parts[1] in ["Cadet","Standard","Ace"] and (raw.records[key] is int or raw.records[key] is float):
					var id: String = Catalog.LEGACY[int(parts[0])]
					result.records[id+"_"+parts[1]] = clampi(int(raw.records[key]),0,999999999)
					if raw.records[key]>0 and not result.completed.has(id): result.completed.append(id)
		result.frontier = Catalog.LEGACY[unlocked-1]
		result.finished = result.completed.has("tempest_crown")
		if result.completed.has("cinder_corridor"): result.carrier.parts_secured = true
	var pair: Array = []
	if result.companions is Array:
		for id in result.companions:
			if id in ["latch","glint","pike","ember","bastion"] and not pair.has(id) and pair.size()<2 and (not Catalog.UNLOCKS.has(id) or result.completed.has(Catalog.UNLOCKS[id])): pair.append(id)
	for id in ["latch","glint"]:
		if pair.size()<2 and not pair.has(id): pair.append(id)
	result.companions = pair
	for key in result.records.keys():
		var valid_key := false
		for id in Catalog.IDS:
			for difficulty in ["Cadet","Standard","Ace"]:
				if key==id+"_"+difficulty: valid_key = true
		if not valid_key or not (result.records[key] is int or result.records[key] is float): result.records.erase(key)
		else: result.records[key] = clampi(int(result.records[key]),0,999999999)
	# Settings cross an untrusted persistence boundary. Keep the known schema;
	# arbitrary keys and wrong types must not reach live node setters.
	for key in Catalog.DEFAULTS:
		if typeof(result.settings[key])!=typeof(Catalog.DEFAULTS[key]): result.settings[key] = Catalog.DEFAULTS[key]
	result.settings.ui_scale = clampf(float(result.settings.ui_scale),1,1.5)
	result.carrier.hull = clampf(float(result.carrier.hull),0,100) if result.carrier.hull is float or result.carrier.hull is int else 100.0
	for key in ["drive_overstrained","parts_secured","repaired"]: result.carrier[key] = result.carrier[key]==true
	for key in result.bindings.keys():
		if not (result.bindings[key] is int or result.bindings[key] is float) or result.bindings[key]<1: result.bindings.erase(key)
	for key in result.pad_bindings.keys():
		if not (result.pad_bindings[key] is int or result.pad_bindings[key] is float) or result.pad_bindings[key]<0 or result.pad_bindings[key]>20: result.pad_bindings.erase(key)
	for id in result.companion_condition.keys():
		var condition: Variant = result.companion_condition[id]
		if not condition is Dictionary or not (condition.get("hp") is float or condition.get("hp") is int): result.companion_condition.erase(id)
	for id in result.rivals.keys():
		if not id in ["rook","shrike","slate"] or not result.rivals[id] in ["disabled","withdrawn","recovered","lost","ejected"]: result.rivals.erase(id)
	return result

func load_file() -> bool:
	if not FileAccess.file_exists(path):
		if FileAccess.file_exists(path+".backup"):
			var recovered := decode(JSON.parse_string(FileAccess.get_file_as_string(path+".backup")))
			if recovered.is_empty(): return false
			data = recovered; return true
		data = fresh(); return true
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path))!=OK:
		error = "The save could not be read. Keep it for recovery or explicitly start a new campaign."
		return false
	var decoded := decode(parser.data)
	if decoded.is_empty(): return false
	data = decoded
	return true

func write() -> bool:
	if not error.is_empty(): return false
	var temporary := path+".tmp"
	var file := FileAccess.open(temporary,FileAccess.WRITE)
	if file==null: return false
	file.store_string(JSON.stringify(data,"\t")); file.flush(); file.close()
	var absolute := ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(path):
		if FileAccess.file_exists(path+".backup"): DirAccess.remove_absolute(absolute+".backup")
		if DirAccess.rename_absolute(absolute,absolute+".backup")!=OK: return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary),absolute)==OK

func available(id: String) -> bool:
	var index := Catalog.IDS.find(id)
	return index>=0 and (index==0 or data.finished or data.completed.has(id) or data.legacy_access.has(id) or data.completed.has(Catalog.IDS[index-1]))

func checkpoint(snapshot: Dictionary, replay: bool) -> void:
	if replay: return
	data.checkpoint = snapshot.duplicate(true)
	data.frontier = snapshot.mission
	write()

func settle(id: String, score: int, facts: Dictionary, replay: bool = false) -> void:
	var key := id+"_"+str(data.difficulty)
	data.records[key] = maxi(score,int(data.records.get(key,0)))
	data.best = maxi(score,int(data.best))
	if not replay:
		if not data.completed.has(id): data.completed.append(id)
		if not data.settled.has(id):
			data.settled.append(id)
			data.carrier.merge(facts.get("carrier",{}),true)
			data.rivals.merge(facts.get("rivals",{}),true)
			data.companion_condition.merge(facts.get("companions",{}),true)
			for rescue in facts.get("rescues",[]):
				if not data.rescues.has(rescue): data.rescues.append(rescue)
		var index := Catalog.IDS.find(id)
		data.frontier = Catalog.IDS[mini(index+1,Catalog.IDS.size()-1)]
		data.checkpoint = {}
		if id==Catalog.IDS.back(): data.finished = true
	write()
