extends SceneTree
## Native views of the actual grid, reused chart, sectors, and a continuous moon trip.
const OUTPUT := "/tmp/foxlike-exploration-capture"
var hub: Node3D
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1280,720)
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	hub = load("res://scenes/orbit_hub.tscn").instantiate()
	root.add_child(hub)
	hub.set_process(false)
	await process_frame
	hub.audio.volume_db = -80
	hub.toggle_selector()
	await picture("01-planet-grid")
	hub.selector.toggle_view()
	for i in range(50): await process_frame
	await picture("02-pbr-system-chart")
	hub.selector.toggle_view()
	hub.select_world("viridia")
	hub.asteroids.set_enabled(false)
	hub.navigation.travel_drive = true
	var record := "--capture-transfer" in OS.get_cmdline_user_args()
	if record: DirAccess.make_dir_recursive_absolute(OUTPUT+"/frames")
	for frame in range(320):
		hub.face_waypoint()
		hub.simulate(.05,{"move":Vector3.FORWARD})
		hub._update_ship(.05)
		hub._update_camera(.05,frame==0)
		hub.hud.queue_redraw()
		if record:
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(OUTPUT+"/frames/frame-%04d.png" % frame)
	await picture("03-moon-arrival")
	for id in ["pelagos","jovian","chronos","aurora","vesper"]:
		hub.select_world(id)
		hub.cinematic = true
		hub.navigation.position = Vector3(270,125,320)
		hub.navigation.heading = .62
		hub.navigation.pitch = -.08
		hub._update_ship(0)
		hub._update_camera(1,true)
		await picture("world-"+id)
	hub.select_world("aurora")
	var moon: Dictionary = hub.sector.bodies[1]
	var outward: Vector3 = (moon.position-hub.sector.bodies[0].position).normalized()
	hub.navigation.position = moon.position+outward*(float(moon.radius)+1500.0)
	hub.face_waypoint()
	hub.simulate(.05,{})
	hub.sector.update_lod(hub.navigation.position)
	hub.cinematic = false
	hub._update_ship(0)
	hub._update_camera(1,true)
	await picture("04-moon-closeup")
	hub.toggle_selector()
	root.size = Vector2i(800,600)
	await picture("05-grid-small-window")
	hub.queue_free()
	await process_frame
	await process_frame
	print("ORBIT_EXPLORATION_RENDER_PASS")
	quit()
func picture(name: String) -> void:
	hub.hud.queue_redraw()
	for i in range(5): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUTPUT+"/"+name+".png")
