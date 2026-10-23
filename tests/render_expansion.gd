extends SceneTree
## Native visual scenarios run the real controller. Unlocked menu and encounter
## placement are capture fixtures; these images do not imply campaign victories.
const TEST_SAVE := "user://foxlike_test_save.json"
var game: Node3D
var output := "/tmp/foxlike-expansion"
var original_save := ""
var had_save := false
var failures: Array[String] = []
var capture_motion := false
var motion_frames: Dictionary = {}

func _initialize() -> void:
	if not "--test-save" in OS.get_cmdline_user_args():
		push_error("Render expansion requires --test-save")
		quit(2)
		return
	call_deferred("run")

func run() -> void:
	capture_motion = "--capture-motion" in OS.get_cmdline_user_args()
	root.size = Vector2i(1280,720)
	DirAccess.make_dir_recursive_absolute(output)
	had_save = FileAccess.file_exists(TEST_SAVE)
	if had_save: original_save = FileAccess.get_file_as_string(TEST_SAVE)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.audio.set_muted(true)
	game.mouse_active = false
	await process_frame
	game.save_data = {"unlocked":6,"best":0,"muted":true,"difficulty":"Standard","records":{},"companions":["pike","ember"],"formation":0,"completed_stages":[0,1,2,3,4,5]}
	game._configure_wingmen()
	game._show_menu()
	await step(0.6)
	await picture("01-six-mission-menu")

	await launch(3)
	game._spawn_ground_barrier(0.0,42.0,4.5)
	game.ground_barriers[0].node.position.z = -55.0
	game.hud.say("JACKAL","Jet packs armed. Hold Shift to clear the striped barrier.",4.0)
	await picture("02-tank-ground")
	Input.action_press("boost")
	await step(1.05,"tank-hover")
	await picture("03-tank-hover-barrier")
	await step(0.8,"tank-hover")
	Input.action_release("boost")
	await step(1.5,"tank-hover")
	await picture("04-tank-landed")

	await launch(4)
	game._spawn_arena_wave({"kind":"fighter","count":3,"angle":2.0})
	for i in range(game.enemies.size()):
		game.enemies[i].arena_pos = Vector3(-28.0+float(i)*25.0,15.0+float(i)*7.0,22.0-float(i)*20.0)
		game.enemies[i].fire = 0.0
	await step(0.45)
	await picture("05-carrier-defense")
	game.arena.position = Vector3(85,15,100)
	game.arena.heading = atan2(85.0,100.0)
	game._sync_arena_view()
	await step(0.15)
	await picture("05b-carrier-three-quarter")
	game.arena.position = Vector3(0,12,-182)
	game.arena.heading = 0.0
	game._sync_arena_view()
	await step(0.9,"arena-turn")
	if not game.arena.turning: failures.append("Boundary scenario did not enter its turnaround")
	await picture("06-arena-turnaround")
	await step(2.1,"arena-turn")
	await picture("07-arena-return")

	for mission in [3,4,5]:
		await launch(mission)
		game._spawn_boss()
		# Advance combat normally so the boss moves, aims and emits its attack.
		await step(5.0)
		if mission==4:
			# Keep the orbiting hunter in the forward view for this encounter portrait.
			game.arena.position = Vector3(0,15,170)
			game.arena.heading = 0.0
			game._sync_arena_view()
			await step(0.2)
		await picture("08-boss-%d" % (mission+1))
		if mission==5:
			Input.action_press("fire")
			await step(0.45)
			Input.action_release("fire")
			await picture("09-tempest-combat")

	Input.action_release("boost")
	Input.action_release("fire")
	game.audio.stop_music()
	game.queue_free()
	await process_frame
	await process_frame
	if had_save:
		var restore := FileAccess.open(TEST_SAVE,FileAccess.WRITE)
		restore.store_string(original_save)
		restore.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	if failures.is_empty():
		print("EXPANSION_RENDER_PASS: six-mission menu, tank hover, carrier defense, turnaround and three new boss scenarios")
		quit()
	else:
		for failure in failures: push_error(failure)
		quit(1)

func launch(mission: int) -> void:
	game._begin_stage(mission)
	game._launch()
	await step(3.3)
	game.waves = []
	game._clear_actors()
	game.invulnerable = 1000.0
	game.mouse_active = false
	await step(0.15)

func step(seconds: float, motion: String = "") -> void:
	for i in range(int(ceil(seconds/0.05))):
		game._process(0.05)
		if capture_motion and not motion.is_empty():
			await process_frame
			await RenderingServer.frame_post_draw
			var folder := output.path_join(motion)
			DirAccess.make_dir_recursive_absolute(folder)
			var frame: int = int(motion_frames.get(motion,0))
			root.get_texture().get_image().save_png(folder.path_join("frame-%03d.png" % frame))
			motion_frames[motion] = frame+1
		elif i % 3 == 0:
			await process_frame

func picture(filename: String) -> void:
	for i in range(3): await process_frame
	await RenderingServer.frame_post_draw
	if root.get_texture().get_image().save_png(output.path_join(filename+".png")) != OK:
		failures.append("Failed capture: "+filename)
