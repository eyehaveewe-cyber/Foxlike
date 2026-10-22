extends SceneTree
## Real simulation capture, with incoming encounters disabled only in this harness.
## godot --path . --script tests/render_maneuvers.gd --fixed-fps 20 -- --test-save --frames-dir=/tmp/foxlike-stunts
const FPS := 20
var game: Node3D
var output := "/tmp/foxlike-stunts"

func _initialize() -> void:
	if not "--test-save" in OS.get_cmdline_user_args():
		quit(2)
		return
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--frames-dir="): output = arg.trim_prefix("--frames-dir=")
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	root.size = Vector2i(960,540)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.audio.set_muted(true)
	game._begin_stage(0)
	game._launch()
	for frame in range(66): game._process(1.0/FPS)
	game.waves = []
	game._clear_actors()
	game.invulnerable = 1000.0
	for move in range(3):
		game.player.position = Vector3(0,0,0)
		game.move_velocity = Vector2.ZERO
		game.energy = 100.0
		game.maneuver_cooldown = 0.0
		var direction: String = ["left","down","right"][move]
		for frame in range(84):
			if frame == 3: Input.action_press("boost")
			if frame == 4: Input.action_press(direction)
			if frame == 7: Input.action_release(direction)
			if frame == 82: Input.action_release("boost")
			game._process(1.0/FPS)
			await process_frame
			await RenderingServer.frame_post_draw
			var capture := root.get_texture().get_image()
			capture.resize(960,540,Image.INTERPOLATE_LANCZOS)
			if capture.save_png(output.path_join("frame_%04d.png" % (move*84+frame))) != OK:
				quit(1)
				return
	print("MANEUVER_CAPTURE_PASS: 252 real gameplay frames, three boost-direction maneuvers")
	game.audio.stop_music()
	game.queue_free()
	await process_frame
	await process_frame
	quit()
