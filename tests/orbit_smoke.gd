extends SceneTree
const Navigation = preload("res://scripts/orbit/orbit_navigation.gd")
var hub: Node3D
var checks := 0
var failures: Array[String] = []
func _initialize() -> void: call_deferred("run")
func check(condition: bool, label: String) -> void:
	checks += 1
	print(("PASS " if condition else "FAIL ")+label)
	if not condition: failures.append(label)
func run() -> void:
	var main: Node3D = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	main.set_process(false)
	await process_frame
	var button: Button
	for node in main.hud.find_children("*","Button",true,false):
		if node.text=="VIRIDIA ORBIT / PEACEFUL HUB": button = node
	check(button!=null,"Latest flight deck exposes the peaceful orbit destination")
	if button==null: quit(1); return
	button.pressed.emit()
	await process_frame
	await process_frame
	hub = current_scene
	hub.set_process(false)
	hub.audio.volume_db = -80
	check(hub.station.solids.size()>20 and hub.station.rings.size()==2,"Observatory has physical hull volumes and two habitat rings")
	var start: Vector3 = hub.navigation.position
	var old_spin: float = hub.planet_material.get_shader_parameter("spin")
	for i in range(600): hub.simulate(.05,{})
	check(hub.navigation.position==start and hub.navigation.velocity==Vector3.ZERO,"Idle ship holds its actual location for thirty seconds")
	check(hub.clock>29.9 and float(hub.planet_material.get_shader_parameter("spin"))>old_spin,"Planetary rotation continues independently while the ship idles")
	check(float(hub.cloud_material.get_shader_parameter("spin"))!=float(hub.planet_material.get_shader_parameter("spin")),"Cloud weather has its own slower independent rotation")
	check(hub.asteroids.created>8,"Quiet orbit admits new asteroid visitors while idling")
	hub.navigation.position = Vector3(0,150,500)
	for i in range(60): hub.simulate(.05,{"move":Vector3.FORWARD})
	check(hub.navigation.position.z<400 and hub.navigation.velocity.length()<=62.01,"Free thrusters move the real ship without exceeding normal speed")
	for i in range(150): hub.simulate(.05,{"brake":true})
	var parked: Vector3 = hub.navigation.position
	check(hub.navigation.velocity==Vector3.ZERO,"Space brake settles to a genuine hover")
	for i in range(100): hub.simulate(.05,{})
	check(hub.navigation.position==parked,"Hover remains still after releasing the brake")
	hub.navigation.assist = false
	for i in range(30): hub.simulate(.05,{"move":Vector3.RIGHT})
	var velocity: Vector3 = hub.navigation.velocity
	var drifting: Vector3 = hub.navigation.position
	for i in range(40): hub.simulate(.05,{})
	check(hub.navigation.velocity.is_equal_approx(velocity) and hub.navigation.position.distance_to(drifting)>50,"Free drift preserves momentum when assist is released")
	var navigator := Navigation.new()
	navigator.position = Vector3(0,300,600)
	for i in range(120): navigator.advance(.05,{"move":Vector3(1,1,1),"boost":true},hub.station,[])
	check(navigator.velocity.length()<=125.01,"Diagonal six-axis boost obeys one total speed cap")
	hub.return_to_station()
	check(hub.navigation.position.is_equal_approx(Vector3(0,12,245)) and hub.navigation.velocity==Vector3.ZERO,"Explicit station return restores the safe idle berth")
	for i in range(300): hub.simulate(.05,{"move":Vector3.FORWARD})
	check(hub.navigation.status.contains("PROXIMITY") and hub.navigation.position.z>15,"Station hull safety stops an approaching ship before the central spine")
	hub.return_to_station()
	var time: float = hub.clock
	hub.paused = true
	hub.simulate(5.0,{"move":Vector3.FORWARD})
	check(hub.clock==time and hub.navigation.velocity==Vector3.ZERO,"Pause freezes simulation and navigation together")
	hub.paused = false
	hub.time_scale = 0.0
	hub.navigation.position = Vector3(0,250,500)
	hub.simulate(1.0,{"move":Vector3.FORWARD})
	check(hub.clock==time and hub.navigation.velocity.length()>0,"Freezing orbital time leaves ship handling available")
	hub.time_scale = 8.0
	hub.simulate(1.0,{"brake":true})
	check(is_equal_approx(hub.clock,time+8.0),"Orbital time control accelerates scenery without changing input time")
	hub.asteroids.set_enabled(true)
	hub.return_to_station()
	var admitted: bool = hub.admit_visitor()
	var arrival: Dictionary = hub.asteroids.visitors.back()
	check(admitted and (Vector3(arrival.position)-hub.navigation.position).dot(-hub.navigation.basis().z)>300.0,"Explicit asteroid admission starts ahead of the viewer with safe separation")
	for i in range(100): hub.asteroids.spawn(Vector3.ZERO)
	check(hub.asteroids.visitors.size()<=24,"Asteroid visitors remain bounded after repeated requests")
	var near_safe := true
	for visitor in hub.asteroids.visitors:
		near_safe = near_safe and Vector2(visitor.position.x,visitor.position.z).length()>=390.0
	check(near_safe,"Asteroid arrivals stay outside the docking and station ring")
	hub.asteroids.set_enabled(false)
	var count: int = hub.asteroids.visitors.size()
	check(not hub.asteroids.spawn(Vector3.ZERO) and not hub.asteroids.visible,"Disabling visitors hides the field and rejects new arrivals")
	hub.asteroids.advance(100.0,Vector3.ZERO)
	check(hub.asteroids.visitors.size()==count,"Disabled asteroid motion and spawn timers remain suspended")
	hub.asteroids.set_enabled(true)
	var visitor: Dictionary = hub.asteroids.visitors.front()
	visitor.age = 0.0
	hub.asteroids.advance(.05,Vector3.ZERO)
	check(float(visitor.material.get_shader_parameter("reveal"))<.02,"A newly admitted asteroid starts transparent and reveals gradually")
	for i in range(180): hub.asteroids.advance(.05,Vector3.ZERO)
	check(float(visitor.material.get_shader_parameter("reveal"))>.99,"Asteroid reveal reaches its opaque physical presence over time")
	var fixture := {"position":Vector3(0,300,450),"radius":12.0,"age":8.0}
	navigator.position = Vector3(0,300,480)
	navigator.velocity = Vector3(0,0,-100)
	navigator.advance(.5,{"move":Vector3.FORWARD,"boost":true},null,[fixture])
	check(navigator.position.z>466 and navigator.velocity==Vector3.ZERO,"Rock proximity arrests travel safely instead of destroying an idle ship")
	hub.return_to_station()
	var held: Vector3 = hub.navigation.position
	for i in range(3):
		hub.camera_mode = i
		hub._update_camera(.05,true)
	check(hub.navigation.position==held and hub.camera.position.is_finite(),"All three viewing modes preserve the ship's held location")
	# Verify normal return navigation without writing campaign progression.
	var back: Button
	for node in hub.panel.find_children("*","Button",true,false):
		if node.text=="RETURN TO FLIGHT DECK": back = node
	back.pressed.emit()
	await process_frame
	await process_frame
	var restored: Node3D = current_scene
	check(restored.mode==restored.Mode.MENU,"Orbit returns cleanly to the current campaign flight deck")
	restored.queue_free()
	await process_frame
	await process_frame
	print("ORBIT_SMOKE: %d checks; %d failures" % [checks,failures.size()])
	for failure in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)
