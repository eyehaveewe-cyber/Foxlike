extends SceneTree
## Native camera recording paired with an explicitly arranged driver trace.
## This is visual QA, never a claim of human Standard completion.
var game: Node3D
const OUTPUT := "/tmp/foxlike-duel-capture"
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1280,720)
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	DirAccess.make_dir_recursive_absolute(OUTPUT+"/frames")
	game = load("res://scenes/duel.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.audio.set_muted(true)
	await process_frame
	await picture("01-duel-briefing")
	game._bot_player = true
	game.run_driver = "arranged_capture"
	game._start()
	for frame in range(320):
		for substep in range(6):
			game.simulate(1.0/120.0,{})
			game.effects._process(1.0/120.0)
		game._update_rigs(.05)
		game._sync_shots()
		game._update_camera(.05)
		game.overlay.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		if "--capture-motion" in OS.get_cmdline_user_args(): root.get_texture().get_image().save_png(OUTPUT+"/frames/frame-%04d.png" % frame)
		if frame in [20,80,160,240,319]: await picture("02-duel-%03d" % frame)
	game._write_trace("arranged_native_capture")
	DirAccess.copy_absolute(ProjectSettings.globalize_path(game.trace_path),OUTPUT+"/duel-trace.json")
	game._reset()
	game.vehicles[0].reset(Vector3(0,24,60),0)
	game.vehicles[1].reset(Vector3(0,24,-60),PI)
	game.player_contact = {"position":Vector3(0,60,-60),"seen":0.0,"visible":false}
	game.last_player_seen = 0.0
	game._bot_player = false
	game.run_driver = "arranged_cover_fixture"
	game._start()
	for frame in range(20):
		for substep in range(6): game.simulate(1.0/120.0,{"brake":true})
	game._update_rigs(.05)
	game._sync_shots()
	game._update_camera(1.0,true)
	game.overlay.queue_redraw()
	await picture("03-cover-contact-lost")
	game.debug_view = true
	game.overlay.queue_redraw()
	await picture("04-optional-measurements")
	game._reset()
	for setting in game.options.find_children("*","OptionButton",true,false):
		if setting.get_item_text(0).begins_with("600"):
			setting.select(0)
			setting.item_selected.emit(0)
	await picture("05-low-volume-comparison")
	game.queue_free()
	await process_frame
	await process_frame
	print("DUEL_RENDER_PASS: arranged native duel + cover scenario; human gates remain open")
	quit()
func picture(name: String) -> void:
	for frame in range(3): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUTPUT+"/"+name+".png")
