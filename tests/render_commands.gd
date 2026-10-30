extends SceneTree
## Actual flight HUD with arranged component assignments, at two display sizes.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game: Node3D = load("res://scenes/main.tscn").instantiate()
	root.add_child(game); game.set_process(false); await process_frame
	game.save.data = game.save.fresh(); game.audio.set_muted(true)
	game._launch("aurora_courier"); game.set_process(false)
	for actor in game.session.living_hostiles(): game.session.actors.erase(actor.id)
	game.session.stage = 2; game.session._enter()
	var index := 0
	for actor in game.session.living_hostiles():
		if actor.id==game.session.required_cargo: continue
		actor.vehicle.reset(Vector3(-160+index*55,115,-150),PI); index += 1
	game.session.selected = game.session.required_cargo+":Drive"
	game.session.assign("attack",game.session.selected)
	for size in [Vector2i(1280,720),Vector2i(640,360)]:
		root.size = size
		for scale_ui in [1.0,1.5]:
			game.save.data.settings.ui_scale = scale_ui; game._resize_ui()
			game._process(0)
			await process_frame; await RenderingServer.frame_post_draw
			var name := "commands-%d-%d.png"%[size.x,roundi(scale_ui*100)]
			if root.get_texture().get_image().save_png("res://build/"+name)!=OK: quit(1); return
	game.queue_free(); await process_frame; await create_timer(.15).timeout
	print("RENDER_COMMANDS: 4 arranged flight HUD views saved")
	quit()
