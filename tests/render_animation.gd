extends SceneTree
## Reproducible, silent animation showcase from the real flight simulation.
## Run with a real renderer and --fixed-fps 20. Invulnerability is enabled only
## in this capture harness; no capture controls are exposed in the normal game.
## Example: godot --path . --script tests/render_animation.gd --fixed-fps 20 \
##   -- --test-save --frames-dir=/tmp/foxlike-animation-frames

const CAPTURE_FPS: int = 20
const FRAME_COUNT: int = 160
var game: Node3D
var frames_dir: String = "/tmp/foxlike-animation-frames"


func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--frames-dir="):
			frames_dir = argument.trim_prefix("--frames-dir=")
	call_deferred("run")


func run() -> void:
	DirAccess.make_dir_recursive_absolute(frames_dir)
	root.size = Vector2i(960, 540)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.audio.set_muted(true)
	game._begin_stage(1)
	game._launch()
	game.invulnerable = 1000.0
	for step: int in range(66):
		game._process(1.0 / CAPTURE_FPS)
	game._clear_actors()
	game._spawn_boss()
	for step: int in range(120):
		game._process(1.0 / CAPTURE_FPS)
	game.player.position = Vector3(-3.0, 1.0, 0.0)
	game.move_velocity = Vector2.ZERO
	game.hud.say("GLINT", "Those weapon arms are tracking us. Keep moving!", 5.5)
	# Let the UI's normal fade-in finish before recording.
	for step: int in range(9):
		await process_frame
		game._process(1.0 / CAPTURE_FPS)
	for frame: int in range(FRAME_COUNT):
		var time: float = float(frame) / CAPTURE_FPS
		_set_action("right", (time >= 0.25 and time < 0.55) or (time >= 3.40 and time < 3.75))
		_set_action("left", (time >= 0.85 and time < 1.20) or (time >= 4.1 and time < 4.45))
		_set_action("up", time >= 5.7 and time < 5.9)
		_set_action("down", time >= 6.35 and time < 6.55)
		_set_action("boost", time >= 2.3 and time < 3.25)
		_set_action("brake", time >= 6.7 and time < 7.2)
		_set_action("fire", time < 1.55 or (time >= 3.3 and time < 5.8))
		if frame == 33:
			game._roll(1.0)
		if frame == 100:
			game._roll(-1.0)
		game._process(1.0 / CAPTURE_FPS)
		await process_frame
		await RenderingServer.frame_post_draw
		var capture: Image = root.get_texture().get_image()
		capture.resize(960, 540, Image.INTERPOLATE_LANCZOS)
		var result: Error = capture.save_png(frames_dir.path_join("frame_%04d.png" % frame))
		if result != OK:
			push_error("Could not save animation frame: " + str(result))
			quit(1)
			return
	for action: String in ["right", "left", "up", "down", "boost", "brake", "fire"]:
		Input.action_release(action)
	print("ANIMATION_CAPTURE_PASS: ", FRAME_COUNT, " real simulation frames at ", CAPTURE_FPS, " fps; bank, roll, boost, brake, fire, and articulated RIME.")
	game.audio.stop_music()
	game.queue_free()
	game = null
	await process_frame
	await process_frame
	quit()


func _set_action(action: String, held: bool) -> void:
	if held:
		Input.action_press(action)
	else:
		Input.action_release(action)
