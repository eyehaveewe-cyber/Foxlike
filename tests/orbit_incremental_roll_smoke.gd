extends SceneTree
const Navigation = preload("res://scripts/orbit/orbit_navigation.gd")
var checks := 0
var failures: Array[String] = []
func _initialize() -> void: call_deferred("run")
func check(value: bool, name: String) -> void:
	checks += 1
	print(("PASS " if value else "FAIL ") + name)
	if not value: failures.append(name)
func key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
func run() -> void:
	var hub: Node3D = load("res://scenes/orbit_hub.tscn").instantiate()
	root.add_child(hub)
	hub.set_process(false)
	await process_frame
	hub.audio.volume_db = -80
	hub.asteroids.set_enabled(false)
	var start: Vector3 = hub.navigation.position
	var forward: Vector3 = -hub.navigation.basis().z
	key(KEY_Q,true)
	await process_frame
	var request: Dictionary = hub.input_request(1.0/60.0)
	check(request.roll == 1.0 and request.move.y == 0.0,"Physical Q requests left roll without vertical thrust")
	hub.simulate(.5,request)
	hub._update_ship(.5)
	hub._update_camera(.5,true)
	check(is_equal_approx(hub.navigation.roll,PI/4.0),"Held Q advances the ship through 45 degrees in half a second")
	check(hub.navigation.position.is_equal_approx(start) and hub.navigation.velocity==Vector3.ZERO,"Rolling at rest does not translate or accelerate the ship")
	check((-hub.navigation.basis().z).is_equal_approx(forward),"Rolling preserves nose direction")
	check(hub.ship.basis.is_equal_approx(hub.navigation.basis()) and hub.ship.basis.y.x < -.6,"The real ship is visibly banked left")
	check(hub.camera.global_basis.y.dot(Vector3.UP)>.95,"The chase camera remains upright during a roll")
	key(KEY_Q,false)
	await process_frame
	hub.simulate(.5,hub.input_request(1.0/60.0))
	check(is_equal_approx(hub.navigation.roll,PI/4.0),"Releasing Q holds the current angle")
	key(KEY_E,true)
	await process_frame
	hub.simulate(.5,hub.input_request(1.0/60.0))
	check(absf(hub.navigation.roll)<.001,"Holding E reverses the rotation incrementally")
	key(KEY_Q,true)
	await process_frame
	check(hub.input_request(.016).roll==0.0,"Simultaneous Q and E cancel")
	key(KEY_Q,false)
	key(KEY_E,false)
	key(KEY_Z,true)
	await process_frame
	check(hub.input_request(.016).move.y==-1.0 and hub.input_request(.016).roll==0.0,"Z retains downward thruster control")
	key(KEY_Z,false)
	key(KEY_X,true)
	await process_frame
	check(hub.input_request(.016).move.y==1.0 and hub.input_request(.016).roll==0.0,"X retains upward thruster control")
	key(KEY_X,false)
	await process_frame
	var coast := Navigation.new()
	coast.position = Vector3(10000,5000,5000)
	coast.velocity = Vector3(90,10,-20)
	coast.engines_on = false
	var velocity: Vector3 = coast.velocity
	coast.advance(1.0,{"roll":1.0},null,[])
	check(coast.velocity==velocity and coast.position.distance_to(Vector3(10090,5010,4980))<.05,"Engine-off roll preserves the world-space inertial coast")
	check((coast.basis()*Vector3.RIGHT).is_equal_approx(Vector3.UP),"A rolled ship's lateral thruster uses its local orientation")
	var samples: Array[float] = []
	for fps in [20,60,144]:
		var nav := Navigation.new()
		for i in range(fps*5/2): nav.advance(1.0/float(fps),{"roll":1.0},null,[])
		samples.append(nav.roll)
	check(absf(angle_difference(samples[0],samples[2]))<.002,"Roll amount agrees at 20, 60 and 144 FPS")
	hub.paused = true
	var held: float = hub.navigation.roll
	hub.simulate(1.0,{"roll":1.0})
	check(hub.navigation.roll==held,"Pause freezes roll input")
	hub.paused = false
	hub.navigation.roll = .9
	hub.face_waypoint()
	check(is_equal_approx(hub.navigation.roll,.9),"Facing a waypoint preserves the chosen roll")
	hub.return_to_station()
	check(is_zero_approx(hub.navigation.roll),"Returning to the station resets roll")
	hub.audio.stop()
	hub.audio.stream = null
	hub.queue_free()
	await process_frame
	await process_frame
	await create_timer(.1).timeout
	print("ORBIT_ROLL_SMOKE: %d checks; %d failures" % [checks,failures.size()])
	for failure in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)
