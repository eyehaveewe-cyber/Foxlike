extends SceneTree
## Arranged command inputs exercise the actual operation authority and world shots.
const Session = preload("res://scripts/campaign/operation_session.gd")
const Save = preload("res://scripts/campaign/campaign_save.gd")
const Target = preload("res://scripts/campaign/operation_target.gd")
var checks := 0
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures.append(message)

func fixture(pair: Array = ["pike"]) -> RefCounted:
	var progress := Save.new().fresh(); progress.companions = pair
	var game := Session.new(); game.begin("viridia_blockade",progress)
	for id in game.actors.keys():
		if id!="comet" and not id in pair: game.actors.erase(id)
	game.pending.clear(); game.cover.clear(); game.pickups.clear(); game.events.clear()
	game.player().vehicle.reset(Vector3(200,120,180),0)
	for wing in game.allies(): wing.vehicle.reset(Vector3(100,80,160),0)
	# Keep the combat state open while isolated command/projectile cases run.
	stationary(game.spawn("fixture_observer",1,"bomber",Vector3(-200,140,-220),100),Vector3(-200,140,-220))
	return game

func stationary(actor: RefCounted, point: Vector3) -> void:
	actor.vehicle.reset(point,0)
	actor.vehicle.profile.cruise = 0.0; actor.vehicle.profile.brake = 0.0; actor.vehicle.profile.boost = 0.0
	actor.vehicle.speed = 0; actor.vehicle.velocity = Vector3.ZERO
	actor.goal = point+Vector3.FORWARD*100
	actor.task = "hold"

func run() -> void:
	var game := fixture()
	var enemy = game.spawn("test_courier",1,"bomber",Vector3(100,80,80),100)
	stationary(enemy,enemy.vehicle.position)
	enemy.task = "transport"; enemy.path.assign([Vector3(100,80,-100)])
	enemy.parts = {"Drive":{"hp":45.0,"offset":[0,0,6]}}
	game.required_cargo = enemy.id
	game.components = {"Antenna":{"hp":65.0,"disabled":false,"point":[120,90,70]}}
	game.core_hp = 100; game.boss_position = Vector3(140,90,70)
	var drive = game.resolve_target("test_courier:Drive")
	check(drive!=null and drive.kind==Target.Kind.PART and drive.uid==Target.PART_BASE+enemy.uid*Target.PART_STRIDE,"Courier Drive resolves its actual subsystem ID")
	check(drive.point==Vector3(100,80,86) and drive.label=="COURIER / Drive","Courier mark uses the transformed subsystem position and readable name")
	check(game.resolve_target(enemy.id).uid==enemy.uid,"Aircraft marks retain the same world hit ID")
	check(game.resolve_target("Antenna").uid==Target.COMPONENT_BASE and game.resolve_target("CORE").uid==Target.CORE_UID,"Capital and core marks resolve world hit IDs")
	for invalid in ["missing","comet","pike","test_courier:missing","test_courier:Drive:extra"]:
		check(game.resolve_target(invalid)==null and not game.assign("attack",invalid),"Invalid or friendly mark denied / "+invalid)
	for id in [enemy.id,"test_courier:Drive","Antenna","CORE"]:
		check(game.target_ids().has(id) and game.assign("attack",id) and game.actors.pike.target==id,"Target picker and attack order agree / "+id)
	check(game.squadron_report().contains("PIKE 95 / ATTACK / CORE"),"Persistent report shows selected task and readable target")
	game.assign("attack","test_courier:Drive")
	game.cover = [{"id":"test-ice","box":AABB(Vector3(80,60,110),Vector3(40,40,5))}]
	var blocked := true; var routed := false
	for i in range(20):
		game.elapsed += .05
		var intent: Dictionary = game._intent(game.actors.pike,.05)
		blocked = blocked and not intent.fire
		routed = routed or Vector2(intent.steer).length()>.01
	check(blocked and routed and game.actors.pike.target=="test_courier:Drive","Occluded attack retains its mark, routes around cover and never fires through ice")
	check(game.activate_abilities("test_courier:Drive")==0 and game.actors.pike.cooldown==0 and game.weapons.shots.is_empty(),"Blocked specialist launch denies without cooldown or projectile")
	game.selected = "test_courier:Drive"; game.player().vehicle.reset(Vector3(100,80,160),0)
	game.missile()
	check(game.missiles==6 and game.missile_wait==0,"Blocked player missile keeps ammunition and cooldown")
	game.cover.clear(); game.player().vehicle.reset(Vector3(200,120,180),0)
	game.components.clear(); game.core_hp = 0
	check(game.activate_abilities("test_courier:Drive")==1 and game.actors.pike.cooldown>0 and game.weapons.shots[0].target_uid==drive.uid,"Pike starts cooldown only with a real missile aimed at the marked Drive")
	for frame in range(100): game.advance(1.0/120,{"brake":true})
	check(enemy.parts.Drive.hp==0 and enemy.hp==100 and enemy.phase=="disabled" and game.mode=="flight","Actual homing impact disables required Drive without destroying courier information")
	game._intent(game.actors.pike,.01)
	check(game.actors.pike.task=="regroup" and game.actors.pike.target.is_empty(),"Disabled mark clears attack and announces regroup")
	check(game.events.any(func(e):return e.type=="assignment" and "unavailable" in e.text),"Lost target has explicit assignment feedback")

	# The gun's offset sits in front of the body. Use actual shared projectile hits.
	var walker_game := fixture()
	var walker = walker_game.spawn("test_walker",1,"walker",Vector3(100,77,80),100)
	stationary(walker,walker.vehicle.position)
	walker.parts = {"Gun":{"hp":30.0,"offset":[0,3,-5]},"Left leg":{"hp":30.0,"offset":[-3,-2,0]}}
	stationary(walker_game.actors.pike,Vector3(100,80,0)); walker_game.actors.pike.vehicle.heading = PI
	for part in ["Gun","Left leg"]:
		check(walker_game.assign("attack","test_walker:"+part),"Walker part accepts companion assignment / "+part)
	check(walker_game.activate_abilities("test_walker:Gun")==1,"Forward walker gun accepts actual specialist launch")
	for frame in range(100):
		walker_game.advance(1.0/120,{"brake":true})
		if walker.parts.Gun.hp==0: break
	check(walker.parts.Gun.hp==0 and walker.parts["Left leg"].hp==30 and walker.hp==100,"Actual missile disables only the marked walker gun / gun %.0f leg %.0f hull %.0f"%[walker.parts.Gun.hp,walker.parts["Left leg"].hp,walker.hp])
	check(walker_game.resolve_target("test_walker:Gun")==null and not walker_game.target_ids().has("test_walker:Gun"),"Disabled walker gun leaves live target picker")
	for mark_id in ["Antenna","CORE"]:
		var capital := fixture()
		capital.components = {"Antenna":{"hp":65.0,"disabled":false,"point":[100,80,80]}}
		capital.core_hp = 120; capital.boss_position = Vector3(100,80,50)
		if mark_id=="CORE": capital.components.Antenna.disabled = true; capital.components.Antenna.hp = 0
		check(capital.activate_abilities(mark_id)==1 and capital.weapons.shots[0].target_uid==capital.resolve_target(mark_id).uid,"Specialist missile uses capital mark ID / "+mark_id)
		for frame in range(120): capital.advance(1.0/120,{"brake":true})
		check(capital.components.Antenna.hp<65 if mark_id=="Antenna" else capital.core_hp<120,"Actual specialist impact damages capital mark / "+mark_id)

	var escort := fixture(["latch","glint"])
	var cargo = escort.spawn("lead_ferry",0,"bomber",Vector3(-100,65,120),100)
	escort.required_cargo = cargo.id
	check(escort.assign("protect") and escort.allies().all(func(a):return a.target=="lead_ferry"),"Protect order anchors to live required friendly transport")
	check(escort.squadron_report().contains("PROTECT / LEAD FERRY"),"Protect report retains the objective name")
	var latch = escort.actors.latch
	latch.phase = "withdrawn"; escort.actors.glint.task = "withdraw"
	check(not escort.assign("cover") and latch.task=="protect" and escort.actors.glint.task=="withdraw","Absent and withdrawing companions cannot acknowledge or change tasks")
	check(escort.activate_abilities("missing")==0,"Unavailable pair cannot consume abilities")
	var solo := fixture([])
	check(not solo.assign("regroup") and solo.activate_abilities("CORE")==0,"Solo sortie denies companion commands honestly")

	var guard := fixture(["latch"])
	guard.player().vehicle.reset(Vector3(100,80,180),0)
	guard.actors.latch.vehicle.reset(Vector3(100,80,168),0)
	guard.weapons.launch(999,1,Vector3(100,80,100),Vector3.BACK,12,120,2)
	var initial_point: Vector3 = guard.actors.latch.vehicle.position
	check(guard.activate_abilities("")==1 and guard.actors.latch.task=="guard" and guard.actors.latch.vehicle.position==initial_point,"Reachable guard starts a physical route without teleporting")
	for frame in range(90): guard.advance(1.0/120,{"brake":true})
	check(guard.player().hp==100 and guard.actors.latch.hp<110,"Guard body intercepts actual approaching bolt while player stays unharmed")
	check(guard.actors.latch.vehicle.position.distance_to(initial_point)>4,"Guard intercept uses shared flight locomotion")
	var denied_guard := fixture(["latch"])
	denied_guard.player().vehicle.reset(Vector3(100,80,180),0)
	denied_guard.actors.latch.vehicle.reset(Vector3(-100,80,180),0)
	denied_guard.weapons.launch(999,1,Vector3(100,80,165),Vector3.BACK,12,180,2)
	check(denied_guard.activate_abilities("")==0 and denied_guard.actors.latch.cooldown==0,"Unreachable imminent guard intercept denies without cooldown")
	denied_guard.weapons.reset(); denied_guard.actors.latch.vehicle.reset(Vector3(100,80,176),0)
	denied_guard.cover = [{"id":"guard-wall","box":AABB(Vector3(80,60,170),Vector3(40,40,5))}]
	check(denied_guard.activate_abilities("")==0 and denied_guard.actors.latch.cooldown==0,"Solid cover denies guard route before cooldown")

	var rivals := fixture([]); rivals.definition.id = "tempest_stormbreak"
	for id in ["rook","shrike","slate"]: rivals.spawn(id,1,"interceptor",Vector3(-100,110,-100),100)
	rivals.actors.shrike.vehicle.reset(Vector3(0,110,-100),0)
	rivals.actors.slate.vehicle.reset(Vector3(80,100,-50),0)
	rivals._coordinate_rivals()
	check(rivals.actors.shrike.task=="rival_attack" and rivals.actors.slate.task=="rival_cover" and rivals.actors.slate.target=="shrike","Healthy rivals receive explicit attack and cover assignments")
	var orders: int = rivals.events.size(); rivals._coordinate_rivals()
	check(rivals.events.size()==orders,"Unchanged rival assignments do not repeat radio orders")
	rivals._intent(rivals.actors.slate,.01)
	var cover_goal: Vector3 = rivals.actors.slate.goal
	check(absf(cover_goal.x-rivals.actors.shrike.vehicle.position.x)>=40 and cover_goal.z>rivals.actors.shrike.vehicle.position.z,"Slate cover station stays beside and behind Shrike's dive lane")
	rivals.player().vehicle.position = Vector3(-200,40,100)
	rivals._intent(rivals.actors.slate,.01)
	check(rivals.actors.slate.goal==cover_goal,"Cover station follows teammate state without hidden player relocation")
	rivals.actors.rook.hp = 40; rivals._coordinate_rivals()
	check(rivals.actors.slate.target=="rook","Partner damage interrupts cover assignment in favor of vulnerable aircraft")
	var restored := Session.new()
	check(restored.restore(rivals.snapshot()) and restored.actors.slate.target=="rook","Rival coordination targets survive checkpoint reconstruction")
	rivals.actors.slate.task = "withdraw"; rivals._coordinate_rivals()
	check(rivals.actors.shrike.task=="regroup" and rivals.actors.slate.task=="withdraw","Coverer's withdrawal clears attack setup without recalling withdrawn actor")
	rivals.actors.slate.hp = 0; rivals.actors.slate.phase = "disabled"; rivals._coordinate_rivals()
	check(rivals.actors.slate.phase=="disabled" and rivals.actors.shrike.target.is_empty(),"Disabled coverer is never respawned or retained as partner")

	var snapshot: Dictionary = fixture().snapshot()
	for actor in snapshot.actors: actor.erase("task_until")
	var legacy := Session.new()
	check(legacy.restore(snapshot) and legacy.allies()[0].task_until==0,"Existing checkpoints without guard deadline remain compatible")
	for malformed in ["deadline","parts","uid"]:
		var bad: Dictionary = snapshot.duplicate(true)
		match malformed:
			"deadline": bad.actors[0].task_until = "later"
			"parts":
				for i in range(Target.PART_STRIDE+1): bad.actors[0].parts[str(i)] = {"hp":1,"offset":[0,0,0]}
			"uid": bad.next_uid = Target.COMPONENT_BASE+1
		var before := legacy.snapshot()
		check(not legacy.restore(bad) and legacy.snapshot()==before,"Malformed target state rejected atomically / "+malformed)

	var scene: Node3D = load("res://scenes/expanded_campaign.tscn").instantiate()
	root.add_child(scene); await process_frame
	scene._launch("aurora_courier"); scene.set_process(false)
	scene.session.stage = 2; scene.session._enter()
	var courier_mark: String = scene.session.required_cargo+":Drive"
	scene.session.assign("attack",courier_mark)
	scene._process(0)
	check(scene.squadron_caption.visible and scene.squadron_caption.text.contains("ATTACK / COURIER / Drive"),"Live flight HUD displays persistent component assignment")
	scene.queue_free(); await process_frame; await create_timer(.15).timeout
	print("COMMAND_SMOKE: %d checks; %d failures"%[checks,failures.size()])
	for failure in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)
