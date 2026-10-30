extends SceneTree
const Session = preload("res://scripts/campaign/operation_session.gd")
const Save = preload("res://scripts/campaign/campaign_save.gd")
var failures: Array[String] = []
var checks := 0
func _initialize() -> void: call_deferred("run")
func check(value: bool, message: String) -> void:
	checks += 1
	print("PASS " if value else "FAIL ",message)
	if not value: failures.append(message)
func route(id: String, stage: int) -> void:
	var game := Session.new(); game.begin(id,Save.new().fresh()); game.stage = stage; game._enter()
	if id=="viridia_blockade":
		game.stage = 1; game._enter(); game.damage_component("Crossing cannon",1000); game._update_objective(.01,{})
		check(game.stage==2 and game.core_hp>0 and game.facts.crossing_open,"Crossing opens before Warden is defeated")
	var cargo = game.actors[game.required_cargo]
	# Isolate route clearance from combat; every movement still uses the real
	# controller and complete-airframe collision against the authored solids.
	for actor in game.actors.values():
		if actor!=cargo: actor.phase = "withdrawn"
	var initial: Vector3 = cargo.vehicle.position
	var collisions := 0
	for frame in range(180*60):
		cargo.vehicle.step(1.0/60,game._intent(cargo,1.0/60),game.cover,game.definition.radius,game.definition.height)
		for event in cargo.vehicle.events:
			if str(event).begins_with("collision:"): collisions += 1
		if cargo.phase=="secured": break
	check(cargo.phase=="secured" and collisions==0,"%s/%d physically arrives without collisions (%s, waypoint %d, collisions %d)"%[id,stage,str(cargo.vehicle.position),cargo.waypoint,collisions])
	check(cargo.vehicle.position.distance_to(initial)>30,"Transport traverses its route rather than completing from a timer")
func run() -> void:
	route("viridia_blockade",2)
	route("viridia_last_ferry",1)
	route("anchorage_defense",1)
	route("anchorage_defense",4)
	route("cinder_corridor",3)
	print("OPERATION_ROUTES: %d checks; %d failures"%[checks,failures.size()])
	quit(0 if failures.is_empty() else 1)
