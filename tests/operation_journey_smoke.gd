extends SceneTree
## Arranged event/settlement fixture, complementary to physical route tests.
const Session = preload("res://scripts/campaign/operation_session.gd")
const Save = preload("res://scripts/campaign/campaign_save.gd")
const Catalog = preload("res://scripts/campaign/operation_catalog.gd")
var checks := 0
var failures: Array[String] = []
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); printerr("JOURNEY_FAILURE: ",label)
func clear_defense(game: RefCounted) -> void:
	for wave in range(8):
		game._admit()
		for actor in game.living_hostiles():
			if actor.id!=game.required_cargo: actor.grace = 0; game.hurt(actor.id,10000,"Arranged event fixture")
		if game.pending.is_empty(): break
func resolve(game: RefCounted) -> void:
	clear_defense(game)
	match str(game.state().kind):
		"boss":
			if game.definition.id=="terminus_falling_yard":
				for part in ["Runaway drive","Coupling","Jammed stabilizer"]: game.damage_component(part,1000)
			elif game.boss_kind==5: game.stage_time = 21; game.damage_core(10000)
			elif game.definition.id=="viridia_blockade": game.damage_component("Crossing cannon",1000)
			else:
				for part in game.components: game.damage_component(part,1000)
				game.stage_time = 7; game.damage_core(10000)
		"control":
			for part in game.components: game.damage_component(part,1000)
		"escort":
			game.actors[game.required_cargo].phase = "secured"
			if game.core_hp>0:
				for part in game.components: game.damage_component(part,1000)
				game.damage_core(10000)
		"intercept": game.damage_actor_part(game.required_cargo,"Drive",1000)
		"interact":
			game.player().vehicle.position = game.Actor.point(game.state().point)
			if game.state().id=="codes": game.player().vehicle.position = game.actors.intercept_craft.vehicle.position
			game._update_objective(2.1,{"interact":true}); return
		"recovery":
			if not game.required_cargo.is_empty(): game.actors[game.required_cargo].phase = "secured"
			game.player().vehicle.position = Vector3(0,74,-66)
		"return","ending": game.player().vehicle.position = Vector3(110,95,80); game.quiet_time = 7
		"escape": game.player().vehicle.position = Vector3(150,65,120)
		"departure": game.stage_time = 7; game.carrier_position.z = -121
	game._update_objective(.01,{})
func run() -> void:
	var save := Save.new(); save.path = "user://foxlike_journey_test.json"
	for id in Catalog.IDS:
		check(save.available(id),"Sequential progression admits "+id)
		var game := Session.new(); game.begin(id,save.data)
		for event in range(20):
			if game.mode!="flight": break
			var previous: int = game.stage
			resolve(game)
			check(game.mode=="won" or game.stage==previous+1,"Objective advances exactly once / "+id+" / "+str(previous))
			if game.mode=="flight":
				var clone := Session.new()
				check(clone.restore(JSON.parse_string(JSON.stringify(game.checkpoint))),"Cold-serializable checkpoint at "+id+" / "+str(game.stage))
		check(game.mode=="won","Operation reaches its declared settlement / "+id)
		save.settle(id,game.score,game.facts)
		var cold := Save.new(); cold.path = save.path
		check(cold.load_file() and cold.data.completed.has(id),"Durable result reload / "+id)
		var before := cold.data.duplicate(true)
		cold.settle(id,game.score,game.facts)
		check(cold.data==before,"Repeated result remains idempotent / "+id)
	check(save.data.finished and save.data.frontier=="tempest_crown","Full sequential campaign retains the confirmed ending")
	for suffix in ["",".backup",".tmp"]: DirAccess.remove_absolute(ProjectSettings.globalize_path(save.path+suffix))
	print("OPERATION_JOURNEY_SMOKE: %d checks; %d failures"%[checks,failures.size()])
	quit(0 if failures.is_empty() else 1)
