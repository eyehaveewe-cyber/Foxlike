extends SceneTree
## Concrete Phase One regressions, not a human completion certificate.
const Vehicle = preload("res://scripts/duel/duel_vehicle.gd")
const Pilot = preload("res://scripts/duel/duel_pilot.gd")
const Geometry = preload("res://scripts/duel/duel_geometry.gd")
const Weapons = preload("res://scripts/duel/duel_weapons.gd")
var failures: Array[String] = []
var checks := 0
var metrics: Dictionary = {}

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, label: String) -> void:
	checks += 1
	print(("PASS " if value else "FAIL ")+label)
	if not value: failures.append(label)

func run() -> void:
	var positions: Array[Vector3] = []
	for fps in [20,60,120]:
		var vehicle := Vehicle.new()
		vehicle.reset(Vector3(0,5000,0),0.0)
		var max_speed := 0.0
		var max_rate := 0.0
		for i in range(fps*5):
			vehicle.step(1.0/float(fps),{"steer":Vector2(.8,.8),"boost":true},[],10000.0,10000.0)
			max_speed = maxf(max_speed,vehicle.velocity.length())
			max_rate = maxf(max_rate,vehicle.angular_rate)
		check(max_speed<=60.01 and max_rate<=1.122 and absf(vehicle.pitch)<=float(Vehicle.PROFILE.pitch_limit)+.001,"%d FPS simultaneous climb/turn obey total speed, pitch and angular caps" % fps)
		check(vehicle.depleted and vehicle.energy<30.0,"%d FPS exhausted boost remains denied while held" % fps)
		positions.append(vehicle.position)
		metrics[str(fps)] = {"max_speed":max_speed,"max_angular_rate":max_rate,"energy":vehicle.energy}
	check(positions[0].distance_to(positions[2])<.15 and positions[1].distance_to(positions[2])<.15,"20/60/120 FPS shared locomotion produces the same trajectory")
	var a := Vehicle.new()
	var b := Vehicle.new()
	a.reset(Vector3(0,500,0),0)
	b.reset(Vector3(0,500,0),0)
	for i in range(600):
		var request := {"steer":Vector2(sin(float(i)*.03)*.4,cos(float(i)*.04)*.3),"boost":i<500,"brake":i>540,"roll":1.0 if i==10 else 0.0}
		a.step(1.0/60.0,request,[],10000.0,10000.0)
		b.step(1.0/60.0,request.duplicate(),[],10000.0,10000.0)
	check(a.position.distance_to(b.position)<.001 and a.energy==b.energy and a.roll_wait==b.roll_wait,"Player and AI request sources have identical energy, movement and roll outcomes")
	a.reset(Vector3(0,500,0),0,.5)
	b.reset(Vector3(0,500,0),0,.5)
	b.pitch_hold = false
	for i in range(120):
		a.step(1.0/60.0,{},[],10000,10000)
		b.step(1.0/60.0,{},[],10000,10000)
	check(is_equal_approx(a.pitch,.5) and b.pitch<.15,"Pitch-hold and gradual-level experiments produce distinct neutral responses")
	a.reset(Vector3(0,500,0),0)
	a.step(.25,{"boost":true},[],10000,10000)
	var boosted: float = a.speed
	a.speed = 60.0
	a.step(.25,{"brake":true},[],10000,10000)
	metrics["quarter_second_speed"] = {"boost_from_38":boosted,"brake_from_60":a.speed}
	check(boosted>51.0 and boosted<53.0 and a.speed>35.0 and a.speed<37.0,"Measured acceleration and braking retain the audited 0.25-second response")
	var thin := [{"id":"thin","box":AABB(Vector3(-20,0,-.05),Vector3(40,100,.1))}]
	a.reset(Vector3(0,50,10),0)
	a.speed = 60.0
	a.step(.25,{"boost":true},thin,1000,1000)
	check(a.position.z>3.5 and a.denied.begins_with("SOLID") and not a.events.is_empty(),"Swept complete-airframe collision cannot skip a thin wall")
	var sight := Pilot.sensor(Vector3(0,50,30),Vector3.FORWARD,Vector3(0,50,-30),Vector3.RIGHT*10,[],thin,0.0)
	check(not sight.visible and not sight.has("position") and not sight.has("velocity"),"Solid cover removes current hidden position and velocity from observation")
	var visible := Pilot.sensor(Vector3(0,120,30),Vector3.FORWARD,Vector3(0,120,-30),Vector3.RIGHT*10,[],thin,0.0)
	check(visible.visible,"Climbing over the same solid cover restores line of sight")
	var pilot := Pilot.new()
	a.reset(Vector3(0,50,100),0)
	pilot.reset(Vector3(0,80,0))
	pilot.feed({"at":0.0,"visible":true,"position":Vector3(0,60,0),"velocity":Vector3(10,0,0),"threats":[]})
	pilot.update(.3,a,[],320,160)
	check(pilot.memory.is_empty(),"Recognition delay prevents an immediate response to a new contact")
	pilot.update(.2,a,[],320,160)
	check(not pilot.memory.is_empty() and pilot.last_seen==0.0,"Recognition uses the stored observation timestamp")
	var predicted: Vector3 = pilot.predicted_contact()
	pilot.feed({"at":.5,"visible":false,"threats":[]})
	pilot.update(2.0,a,thin,320,160)
	check(pilot.predicted_contact().distance_to(Vector3(7.5,60,0))<.001 and not pilot.visible,"Lost contact extrapolates only 0.75 seconds and never follows hidden truth")
	check(pilot.state=="search" or pilot.state=="extend","Sight loss leaves committed pursuit for a bounded search or extension")
	pilot.reset(Vector3(0,80,0))
	pilot.feed({"at":0.0,"visible":true,"position":Vector3(0,55,0),"velocity":Vector3.ZERO,"threats":[]})
	for i in range(100): pilot.update(.01,a,[],320,160)
	check(pilot.state=="commit","An observed approach becomes an explicit committed high pass")
	var committed_goal: Vector3 = pilot.goal
	pilot.feed({"at":1.0,"visible":true,"position":Vector3(80,20,0),"velocity":Vector3.LEFT*20,"threats":[]})
	for i in range(60): pilot.update(.01,a,[],320,160)
	check(pilot.goal.distance_to(committed_goal)<.001,"Player repositioning cannot retarget the already committed pass")
	for i in range(300): pilot.update(.01,a,[],320,160)
	check(pilot.state=="extend" or pilot.state=="search","A missed committed pass opens an extension rather than endless tail chasing")
	pilot.reset(Vector3(0,50,0))
	pilot.feed({"at":0.0,"visible":true,"position":Vector3(0,50,-200),"velocity":Vector3.ZERO,"threats":[]})
	pilot.update(.5,a,thin,320,160)
	pilot.update(.25,a,thin,320,160)
	check(pilot.route.contains("cover") or pilot.route.contains("clearance") or pilot.state=="blocked","A blocked approach chooses a body-width route around solid cover")
	pilot.reset(Vector3(0,50,0))
	a.reset(Vector3(0,50,100),0)
	a.energy = 12.0
	var threatened := Pilot.sensor(a.position,a.forward(),Vector3(50,50,0),Vector3.ZERO,[{"owner":0,"position":Vector3(0,50,20),"velocity":Vector3(0,0,100)}],[],0.0)
	pilot.feed(threatened)
	pilot.update(.3,a,[],320,160)
	check(pilot.state!="evade","A visible projectile cannot trigger an evasion before recognition")
	pilot.update(.2,a,[],320,160)
	check(pilot.state=="evade" and pilot.reaction.at==0.0 and a.energy==12.0,"Observed-shot evasion retains its evidence and cannot reset the aircraft's energy")
	var weapons := Weapons.new()
	a.reset(Vector3(0,50,500),0)
	weapons.fire(0,a,[])
	var first: Dictionary = weapons.shots[0]
	var velocity: Vector3 = first.velocity
	a.heading = PI
	weapons.step(.5,[],[])
	check(weapons.shots.size()==2 and first.velocity==velocity and first.position.z>350,"A world projectile survives a heading change and a large view-relative Z")
	weapons.reset()
	a.reset(Vector3(0,50,10),0)
	weapons.fire(0,a,[])
	var impacts := weapons.step(.1,[{"id":1,"position":Vector3(0,50,-10),"previous":Vector3(0,50,-10)}],thin)
	check(impacts.size()==2 and int(impacts[0].target)==-1,"Thin solid cover blocks weapon damage before a target behind it")
	weapons.reset()
	a.reset(Vector3(0,50,0),0)
	weapons.fire(0,a,[])
	weapons.step(5.0,[],[])
	check(weapons.shots.is_empty(),"World range and lifetime expire shots without a camera-relative cutoff")
	for height in [76.0,160.0]:
		for fps in [20,120]:
			a.reset(Vector3(0,height-12,-240),0,.45)
			a.speed = 60
			a.energy = 20
			var bounded := true
			var max_boundary_rate := 0.0
			for i in range(fps*9):
				a.step(1.0/float(fps),{},[],300,height)
				bounded = bounded and Vector2(a.position.x,a.position.z).length()<=296.51 and a.position.y>=3.49 and a.position.y<=height-3.49
				max_boundary_rate = maxf(max_boundary_rate,a.angular_rate)
			check(bounded and max_boundary_rate<=1.122 and a.boundary_events>=1 and not a.protected(),"%d-unit arena at%d FPS returns lawfully below the roof without protection" % [height,fps])
	metrics["position_delta_20_120"] = positions[0].distance_to(positions[2])
	await _scene_checks()
	print("DUEL_SMOKE: %d checks; %d failures; metrics %s" % [checks,failures.size(),JSON.stringify(metrics)])
	for failure in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)

func _scene_checks() -> void:
	var main: Node3D = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	main.set_process(false)
	await process_frame
	var practice: Button
	for candidate in main.campaign_ui.find_children("*","Button",true,false):
		if candidate.text=="PRACTICE DUEL": practice = candidate
	check(practice!=null,"Flight deck exposes a normal practice entry beside Continue")
	if practice==null: return
	practice.pressed.emit()
	await process_frame
	await process_frame
	var game: Node3D = current_scene
	game.set_process(false)
	check(game.mode=="briefing" and game.options.visible,"Practice operation opens its normal briefing and reversible settings")
	game.audio.set_muted(true)
	game.run_driver = "automated_regression"
	game._start()
	var position: Vector3 = game.vehicles[0].position
	game.paused = true
	game.simulate(.5,{"boost":true})
	check(game.vehicles[0].position==position and game.elapsed==0.0,"Pause freezes movement, pilot recognition, weapons and resources")
	game.paused = false
	for i in range(1200):
		game.simulate(1.0/120.0,{"steer":Vector2(-.2,.05),"fire":false})
		if i%120==0: await process_frame
	check(game.samples.size()>50 and not game.pilot.transitions.is_empty(),"Real duel records resolved movement and observation-driven decisions")
	game._write_trace("automated_regression")
	var trace: Variant = JSON.parse_string(FileAccess.get_file_as_string(game.trace_path))
	check(trace is Dictionary and trace.profile.id=="arrow-duel-v1" and trace.camera.reduced_motion and trace.samples.size()>50,"Trace retains profile, volume, controls, camera and measured samples")
	game._reset()
	game._start()
	game._damage(1,100.0,"Arranged regression impact")
	check(game.mode=="won" and game.options.visible,"Actual shield depletion produces a restartable win")
	game._reset()
	game._start()
	game._damage(0,100.0,"Arranged committed pass")
	check(game.mode=="lost" and game.return_text.contains("committed pass"),"Loss keeps the confirmed damage source for review")
	game._reset()
	check(game.hp==[100.0,100.0] and game.weapons.shots.is_empty() and game.pilot.memory.is_empty(),"Restart clears damage, projectiles and pilot memory")
	game.queue_free()
	await process_frame
	await process_frame
