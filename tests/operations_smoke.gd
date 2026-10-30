extends SceneTree
const Session = preload("res://scripts/campaign/operation_session.gd")
const Save = preload("res://scripts/campaign/campaign_save.gd")
const Catalog = preload("res://scripts/campaign/operation_catalog.gd")
var checks := 0
var failures: Array[String] = []
func _initialize() -> void: call_deferred("run")
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures.append(message)
func run() -> void:
	var save := Save.new()
	for i in range(6):
		var data := save.decode({"unlocked":i+1,"records":{"%d_Standard"%i:500},"muted":true,"companions":["latch","glint"]})
		check(data.frontier==Catalog.LEGACY[i] and data.records.has(Catalog.LEGACY[i]+"_Standard"),"Legacy index preserves mission identity "+str(i))
		check(save.decode(data)==data,"Migration is idempotent "+str(i))
	check(save.decode({"version":999}).is_empty() and not save.error.is_empty(),"Future saves are protected")
	save.error = ""
	for id in Catalog.IDS:
		print("CHECK_OPERATION ",id)
		var game := Session.new(); game.begin(id,save.fresh())
		check(game.definition.id==id and game.actors.has("comet"),"Operation starts "+id)
		for i in range(120): game.advance(1.0/120,{"brake":true})
		check(game.living_hostiles().size()<=8,"Finite hostile budget "+id)
		var snapshot := game.snapshot()
		var clone := Session.new()
		check(clone.restore(JSON.parse_string(JSON.stringify(snapshot))),"Snapshot restores "+id)
		check(clone.score==game.score and clone.stage==game.stage and clone.actors.size()==game.actors.size(),"Restored state matches "+id)
		check(not game.assign("attack","missing"),"Missing assignment is denied "+id)
		game.fail("Arranged failure")
		check(game.mode=="lost" and game.restore(game.checkpoint) and game.mode=="flight","Checkpoint retry "+id)
	var malformed := Session.new()
	check(not malformed.restore({"version":1,"mission":Catalog.IDS[0],"stage":0}),"Malformed checkpoint is rejected before mutation")
	var valid := Session.new(); valid.begin("anchorage_defense",save.fresh())
	for damage in ["missing-field","duplicate-uid","bad-vector","bad-part","bad-profile","bad-arrivals","bad-tank","motion-extra","missing-carrier","missing-settings","uid-frontier"]:
		var broken := valid.snapshot()
		match damage:
			"missing-field": broken.erase("repair_cargo")
			"duplicate-uid": broken.actors[1].uid = broken.actors[0].uid
			"bad-vector": broken.actors[0].motion.position[0] = "not a number"
			"bad-part": broken.actors[0].parts = {"Drive":{"hp":4,"offset":[1,2]}}
			"bad-profile": broken.actors[0].profile.angular_rate = "fast"
			"bad-arrivals": broken.pending = ["not an arrival"]
			"bad-tank": broken.tank.fuel = "full"
			"motion-extra": broken.actors[0].motion.script = "not a pose input"
			"missing-carrier": broken.facts.carrier.erase("parts_secured")
			"missing-settings": broken.settings.erase("difficulty")
			"uid-frontier": broken.next_uid = 0
		var original := valid.snapshot()
		check(not valid.restore(broken) and valid.snapshot()==original,"Malformed checkpoint rejected atomically / "+damage)
	var crown := Session.new(); crown.begin("tempest_crown",save.fresh()); crown.stage = 1; crown._enter()
	crown.stage_time = 21
	check(crown.core_open() and crown.components.values().all(func(c):return c.hp>0),"Crown permits early core attack before every vane is removed")
	crown.damage_core(10000)
	crown._update_objective(.01,{})
	check(crown.state().kind=="escape" and crown.checkpoint.core_hp==0,"Confirmed Crown defeat creates an escape checkpoint")
	crown.fail("Arranged late crash"); crown.restore(crown.checkpoint)
	check(crown.state().kind=="escape" and crown.core_hp==0,"Late escape retry preserves Crown defeat")
	var carrier := Session.new(); carrier.begin("anchorage_defense",save.fresh()); carrier.stage = 4; carrier._enter()
	var craft = carrier.actors[carrier.required_cargo]
	var hostile = carrier.living_hostiles()[0]; hostile.vehicle.position = Vector3(0,75,-100)
	carrier._update_objective(.1,{})
	check(carrier.recovery_phase=="holding" and carrier.recovery_attempts==1 and carrier.door==0,"Unsafe recovery aborts into a holding route")
	carrier._update_objective(.1,{})
	check(carrier.recovery_attempts==1,"Holding does not duplicate recovery requests")
	var recovery := carrier.checkpoint.duplicate(true)
	carrier.restore(recovery)
	check(carrier.actors.size()==recovery.actors.size(),"Recovery retry restores exactly one craft")
	var courier := Session.new(); courier.begin("aurora_courier",save.fresh()); courier.stage = 2; courier._enter()
	courier.damage_actor_part(courier.required_cargo,"Drive",1000)
	check(courier.mode=="flight" and courier.actors[courier.required_cargo].phase=="disabled","Courier drive hit disables instead of destroying required information")
	var ferry := Session.new(); ferry.begin("viridia_last_ferry",save.fresh()); ferry.stage = 1; ferry._enter()
	var lead = ferry.actors[ferry.required_cargo]; lead.hp = 48; lead.phase = "secured"
	ferry.stage = 3; ferry._enter()
	check(ferry.actors[ferry.required_cargo]==lead and lead.hp==48 and lead.waypoint==0,"Second ferry sector retains the same damaged lead transport")
	var yard := Session.new(); yard.begin("terminus_falling_yard",save.fresh()); yard.stage = 1; yard._enter()
	yard.advance(.2,{"brake":true}); yard.damage_component("Runaway drive",1000)
	var angle: float = yard.vessel_angle; var first_checkpoint := yard.checkpoint.duplicate(true)
	yard.advance(.2,{"brake":true})
	check(yard.vessel_angle==angle and yard.vessel_state==1,"Overspeed drive disable arrests the actual hull roll")
	yard.damage_component("Coupling",1000); yard.damage_component("Jammed stabilizer",1000); yard._update_objective(.01,{})
	check(yard.state().id=="diversion" and yard.facts.vessel_stabilized,"Three confirmed interventions unlock vessel diversion")
	yard.restore(first_checkpoint)
	check(yard.vessel_state==1 and yard.components["Runaway drive"].disabled and yard.vessel_angle==angle,"Stable emergency checkpoint preserves the arrested hull pose")
	var replay_save := Save.new(); replay_save.path = "user://foxlike_settlement_test.json"
	replay_save.settle("tempest_crown",3000,{"carrier":{"hull":67},"rivals":{"rook":"recovered"},"rescues":["lead_ferry"]})
	var finished := replay_save.data.duplicate(true)
	replay_save.settle("viridia_blockade",200,{"carrier":{"hull":1},"rivals":{"rook":"disabled"}},true)
	check(replay_save.data.finished and replay_save.data.frontier==finished.frontier and replay_save.data.carrier==finished.carrier and replay_save.data.rivals==finished.rivals,"Replay cannot replace ending, canonical frontier or settled facts")
	replay_save.settle("tempest_crown",3000,{"carrier":{"hull":1},"rescues":["duplicate"]})
	check(replay_save.data.rescues==finished.rescues and replay_save.data.carrier==finished.carrier,"Repeated settlement cannot duplicate rewards or alter settled outcomes")
	for suffix in ["",".backup",".tmp"]: DirAccess.remove_absolute(ProjectSettings.globalize_path(replay_save.path+suffix))
	var vehicle = preload("res://scripts/duel/duel_vehicle.gd").new()
	vehicle.reset(Vector3(0,80,0),0)
	vehicle.step(.01,{"maneuver":"long_loop"},[],320,160)
	check(vehicle.energy==70 and not vehicle.maneuver.kind.is_empty() and not vehicle.protected(),"Spatial stunt spends energy and grants no roll protection")
	for i in range(320): vehicle.step(1.0/120,{},[],320,160)
	check(vehicle.maneuver.kind.is_empty() and vehicle.position.z< -50,"Spatial long loop moves through its actual world path")
	vehicle.reset(Vector3(0,5,0),0)
	vehicle.step(.01,{"maneuver":"long_loop"},[{"id":"thin-wall","box":AABB(Vector3(-30,0,-10),Vector3(60,60,1))}],320,160)
	check(vehicle.energy>99 and vehicle.maneuver.kind.is_empty() and not vehicle.denied.is_empty(),"Blocked stunt is rejected with feedback before spending energy")
	var ground := Session.new(); ground.begin("cinder_corridor",save.fresh())
	for i in range(240): ground.advance(1.0/120,{"boost":true,"brake":true})
	check(ground.tank.fuel<50 and ground.player().vehicle.position.y>2,"Jet tank hover consumes finite fuel and lifts the real vehicle")
	var supplies := Session.new(); supplies.begin("viridia_blockade",save.fresh())
	supplies.pickups.assign([{"id":"fast-ring","kind":"ring","point":[0,80,0]}]); supplies.player().hp = 50
	supplies.player().vehicle.previous_position = Vector3(-20,80,0); supplies.player().vehicle.position = Vector3(20,80,0)
	supplies._collect_supplies()
	check(supplies.rings==1 and supplies.player().hp==65 and supplies.score==200,"Swept supply crossing repairs and rewards once even with both endpoints outside")
	supplies._collect_supplies(); check(supplies.rings==1 and supplies.score==200,"Consumed supply cannot reward twice")
	supplies.pickups.assign([{"id":"miss","kind":"ammo","point":[0,90,0]}]); supplies.missiles = 6; supplies._collect_supplies()
	check(supplies.missiles==6 and supplies.pickups.size()==1,"Supply near miss outside its envelope does not collect")
	for fps in [20,60,120]:
		var walker: Node3D = preload("res://scripts/campaign/operation_walker.gd").new()
		walker.scale = Vector3.ONE*2; root.add_child(walker)
		walker.resolve_pose(0,true,false,false)
		var plant: Vector3 = walker.legs[0].foot.global_position
		var fixed := true
		for frame in range(1,int(fps*.5)):
			walker.position.z = -4.8*frame/float(fps); walker.rotation.y = .4*frame/float(fps)
			walker.resolve_pose(4.8/fps,true,false,false,1.0/fps)
			fixed = fixed and walker.legs[0].foot.global_position.distance_to(plant)<.001
		check(fixed,"Walker stance foot stays planted during resolved translation and turn at %d FPS"%fps)
		walker.resolve_pose(0,false,true,false,.05)
		check(walker.gun.position.z> -2.3,"Confirmed walker shot drives local recoil")
		walker.reset_pose(); check(walker.gun.position.z== -2.5 and walker.travelled==0,"Walker cancel/reset clears local motion without moving the root")
		walker.queue_free()
	var scene: Node3D = load("res://scenes/expanded_campaign.tscn").instantiate()
	print("CHECK_OPERATION_SCENE")
	root.add_child(scene)
	await process_frame
	check(scene.mode=="menu","Expanded flight deck boots")
	scene._launch("anchorage_defense")
	scene.set_process(false)
	check(scene.mode=="flight" and scene.session.actors.size()>=5,"Expanded carrier operation is playable")
	scene._pause_menu(); check(scene.campaign_ui.visible,"Pause controls available")
	scene.assignment_held = true; scene.assignment_hold = .1; scene.stunt_request = "long_loop"; scene._roll_request = 1
	scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(scene.paused and not scene.assignment_held and scene.assignment_hold==0 and scene.stunt_request.is_empty() and scene._roll_request==0,"Focus pause cancels pending tap, assignment, stunt and roll requests")
	scene.paused = false; scene.mode = "flight"
	Input.joy_connection_changed.emit(0,false)
	check(scene.paused and not scene.input_armed,"Controller-disconnect event pauses and requires neutral rearm")
	scene.save.data.checkpoint = {"version":999}
	scene._launch("anchorage_defense",true)
	check(scene.mode=="briefing" and scene.ui_stack.get_children().any(func(node):return node is Label and node.text.begins_with("Checkpoint could not be restored")),"Invalid checkpoint fallback visibly explains the safe briefing restart")
	scene.queue_free(); await process_frame
	await create_timer(.15).timeout
	print("OPERATIONS_SMOKE: %d checks; %d failures"%[checks,failures.size()])
	for failure in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)
