extends SceneTree
## Native orbit views; scripted camera tours exercise the actual peaceful scene.
const OUTPUT := "/tmp/foxlike-orbit-capture"
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
	await picture("01-station-arrival")
	hub.cinematic = true
	hub.hud.queue_redraw()
	hub.navigation.position = Vector3(270,125,320)
	hub.navigation.heading = .62
	hub.navigation.pitch = -.08
	hub._update_ship(0)
	hub._update_camera(1,true)
	await picture("02-observatory-orbit")
	# A wide camera exhibits the complete planetary surface and atmosphere.
	hub.camera.position = Vector3(1400,700,1500)
	hub.camera.look_at(hub.PLANET_CENTER+Vector3(0,1600,0),Vector3.UP)
	await picture("03-planetary-panorama")
	hub.navigation.position = Vector3(480,100,600)
	hub.camera_mode = 1
	hub.camera_orbit = 1.1
	hub._update_ship(0)
	hub._update_camera(1,true)
	for frame in range(120): hub.simulate(.05,{})
	await picture("04-drift-visitors")
	# Motion capture runs simulation and navigation together; no view-only animation.
	if "--capture-motion" in OS.get_cmdline_user_args():
		DirAccess.make_dir_recursive_absolute(OUTPUT+"/frames")
		hub.return_to_station()
		hub.cinematic = true
		hub.navigation.position = Vector3(300,95,380)
		hub.navigation.heading = .55
		hub.navigation.pitch = -.06
		hub.camera_mode = 0
		hub.time_scale = 4.0
		for frame in range(160):
			hub.simulate(.05,{"move":Vector3(-.25,0,-.25),"turn":Vector2(.08,0)})
			hub._update_ship(.05)
			hub._update_camera(.05,frame==0)
			hub.hud.queue_redraw()
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(OUTPUT+"/frames/frame-%04d.png" % frame)
	hub.cinematic = false
	hub.paused = true
	hub.panel.show()
	await picture("05-orbit-controls")
	hub.queue_free()
	await process_frame
	await process_frame
	print("ORBIT_RENDER_PASS")
	quit()
func picture(name: String) -> void:
	for i in range(4): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUTPUT+"/"+name+".png")
