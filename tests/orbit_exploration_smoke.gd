extends SceneTree
const Catalog = preload("res://scripts/orbit/pbr_catalog.gd")
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
	hub = load("res://scenes/orbit_hub.tscn").instantiate()
	root.add_child(hub)
	current_scene = hub
	hub.set_process(false)
	await process_frame
	hub.audio.volume_db = -80
	var catalog := Catalog.planets()
	var count := 0
	for body in catalog: count += int(body.moons)
	check(catalog.size()==12 and count==93,"Imported PBR catalog retains all twelve worlds and 93 moons")
	check(hub.selector.cards.size()==12,"Every world has a selectable grid card")
	hub.toggle_selector()
	check(hub.selector.visible and hub.paused,"Planet grid pauses flight and takes input focus")
	var held_clock: float = hub.clock
	hub.simulate(1.0,{"move":Vector3.FORWARD})
	check(hub.clock==held_clock,"An open selector cannot advance hidden ship or orbit state")
	var moon_ids: Dictionary = {}
	for body in catalog:
		hub.selector.cards[body.id].pressed.emit()
		check(hub.sector.body.id==body.id and not hub.selector.visible and not hub.paused,"Grid enters "+body.name+" and resumes flight")
		check(hub.sector.bodies.size()==int(body.moons)+1,"Every "+body.name+" moon is a physical 3D body")
		check((hub.sector.ring!=null)==bool(body.ringed),body.name+" retains the catalogued ring state")
		var safe: bool = hub.sector.clearance(hub.navigation.position)>100.0
		for i in range(1,hub.sector.bodies.size()):
			var moon: Dictionary = hub.sector.bodies[i]
			safe = safe and moon.position.length()+float(moon.radius)<Navigation.RADIUS
			safe = safe and moon.position.distance_to(hub.sector.bodies[0].position)>float(moon.radius)+float(hub.sector.bodies[0].radius)
			moon_ids[moon.id] = true
		check(safe,body.name+" berth and all moon orbits fit outside the planet and inside the expanded space")
	check(moon_ids.size()==93,"Moon identifiers remain unique across all sectors")
	hub.select_world("viridia")
	var before: Node3D = hub.sector.planet
	check(not hub.select_world("missing_world") and hub.sector.planet==before,"Unknown planet IDs leave the current orbit intact")
	hub.toggle_selector()
	hub.selector.toggle_view()
	await process_frame
	check(hub.selector.chart.bodies.size()==12 and hub.selector.chart.mode=="explore","PBR's original route chart exposes the same full catalog without campaign locks")
	hub.selector.chart.body_selected.emit("chronos")
	check(hub.sector.body.id=="chronos" and not hub.selector.visible,"Selecting a world on the reused chart also enters its orbit")
	check(not hub.selector.chart.is_processing(),"Closed route charts stop processing")
	hub.select_world("viridia")
	hub.asteroids.set_enabled(false)
	var start: Vector3 = hub.navigation.position
	hub.navigation.travel_drive = true
	var max_speed := 0.0
	var min_clearance := INF
	var travel_seconds := 0.0
	for i in range(2400):
		hub.face_waypoint()
		hub.simulate(1.0/60.0,{"move":Vector3.FORWARD})
		travel_seconds += 1.0/60.0
		max_speed = maxf(max_speed,hub.navigation.velocity.length())
		min_clearance = minf(min_clearance,hub.sector.clearance(hub.navigation.position))
		if hub.navigation.position.distance_to(hub.waypoint_info().position)-float(hub.waypoint_info().radius)<300.0: break
	var distance: float = hub.navigation.position.distance_to(hub.waypoint_info().position)-float(hub.waypoint_info().radius)
	check(distance<300.0 and hub.navigation.position.distance_to(start)>2500.0,"Continuous normal-input flight crosses the old room boundary and reaches Viridia's first moon")
	check(max_speed>500.0 and max_speed<=Navigation.TRAVEL_SPEED+.1,"Travel drive crosses inter-moon space at its bounded higher speed")
	check(min_clearance>24.0,"Planet and moon collision sweeps preserve approach clearance throughout travel")
	print("MOON_TRANSFER_METRICS ",{"seconds":travel_seconds,"max_speed":max_speed,"arrival_clearance":distance})
	# Continue intentionally into the body at engine-off speed to test swept collision.
	hub.face_waypoint()
	hub.navigation.engines_on = false
	hub.navigation.velocity = -hub.navigation.basis().z*1500.0
	for i in range(60): hub.simulate(1.0/60.0,{})
	check(hub.sector.clearance(hub.navigation.position)>=24.5 and hub.navigation.velocity==Vector3.ZERO,"A full-speed unpowered moon approach cannot tunnel through its physical sphere")
	# Move the observer, not the authoritative bodies, to verify distant detail.
	var positions: Array[Vector3] = []
	for body in hub.sector.bodies: positions.append(body.position)
	hub.sector.update_lod(Vector3(800000,500000,600000))
	var all_far := true
	for body in hub.sector.bodies: all_far = all_far and body.lod==2
	check(all_far and not hub.sector.clouds.visible,"Distant world surfaces use coarse meshes/shading and cull their cloud shell")
	var first_moon: Dictionary = hub.sector.bodies[1]
	hub.sector.update_lod(first_moon.position+Vector3(0,0,float(first_moon.radius)+100.0))
	check(first_moon.lod==0,"Approaching a moon restores its detailed sphere")
	var unchanged := true
	for i in range(positions.size()): unchanged = unchanged and hub.sector.bodies[i].position==positions[i]
	check(unchanged,"LOD changes never move physical moon or planet positions")
	# New asteroid visitors must follow the player into the expanded room.
	hub.navigation.position = Vector3(12000,8000,15000)
	hub.navigation.engines_on = true
	hub.navigation.velocity = Vector3.ZERO
	hub.asteroids.set_enabled(true)
	check(hub.admit_visitor(),"An asteroid can be admitted near a ship far from the station")
	var visitor: Dictionary = hub.asteroids.visitors.back()
	check(visitor.position.distance_to(hub.navigation.position)>150 and visitor.position.distance_to(hub.navigation.position)<1500,"New visitors are local to the pilot rather than stranded at the original berth")
	# A held lance must be detached before a planet swap frees its old field.
	visitor.age = 8.0
	hub.navigation.heading = 0.0
	hub.navigation.pitch = 0.0
	visitor.position = hub.navigation.position+Vector3(0,0,-450)
	visitor.node.position = visitor.position
	hub.lance.trigger(hub.navigation,hub.asteroids,hub.station)
	check(not hub.lance.held.is_empty(),"Expanded-room asteroids still support lance acquisition")
	hub.select_world("pelagos")
	check(hub.lance.held.is_empty() and hub.navigation.velocity==Vector3.ZERO and not hub.navigation.travel_drive,"Planet swaps release tethers and reset speed at the safe berth")
	# All waypoint entries can be selected, including the recovery station.
	var seen: Dictionary = {}
	for i in range(hub.sector.bodies.size()):
		seen[hub.waypoint_info().name] = true
		hub.next_waypoint()
	check(seen.size()==hub.sector.bodies.size(),"Waypoint cycling covers every selected moon and the return station")
	# Cruise coast is frame-rate independent in free space with engines disabled.
	var endpoints: Array[Vector3] = []
	for fps in [20,60,144]:
		var nav := Navigation.new()
		nav.position = Vector3(10000,20000,30000)
		nav.velocity = Vector3(1400,0,0)
		nav.engines_on = false
		for i in range(fps*5): nav.advance(1.0/float(fps),{},null,[])
		endpoints.append(nav.position)
	check(endpoints[0].distance_to(endpoints[2])<1.0,"Engine-off travel momentum agrees at 20 and 144 FPS")
	hub.queue_free()
	await process_frame
	await process_frame
	print("ORBIT_EXPLORATION_SMOKE: %d checks; %d failures" % [checks,failures.size()])
	for failure in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)
