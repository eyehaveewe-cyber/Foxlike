extends SceneTree
## Native visual evidence. No campaign victories are implied by this unlocked fixture.
var game: Node3D
var output := "/tmp/foxlike-squadron"
func _initialize() -> void:
	if not "--test-save" in OS.get_cmdline_user_args():
		quit(2)
		return
	call_deferred("run")

func run() -> void:
	root.size = Vector2i(1280,720)
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://tests/compact_campaign.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.audio.set_muted(true)
	game.save_data = {"unlocked":1,"best":0,"muted":true,"difficulty":"Standard","records":{},"companions":["latch","glint"],"formation":0,"completed_stages":[]}
	game._configure_wingmen()
	game._show_menu()
	await picture("01-roster-locked")
	game.save_data.unlocked = 3
	game.save_data.completed_stages = [0,1,2]
	game.save_data.companions = ["pike","ember"]
	game._configure_wingmen()
	game._show_menu()
	await picture("02-roster-unlocked")
	game._begin_stage(1)
	game._launch()
	for frame in range(66): game._process(0.05)
	game.waves = []
	game._clear_actors()
	game.invulnerable = 1000.0
	game.player.position = Vector3.ZERO
	game._empower_squadron()
	for formation in range(3):
		game.save_data.formation = formation
		for frame in range(24): game._process(0.05)
		game.hud.say("FORMATION",game.Squadron.FORMATIONS[formation],3.0)
		await picture("03-formation-%d" % formation)
	var enemy: Dictionary = game._spawn_enemy("bomber",0,1,0)
	enemy.node.position = Vector3(0,2,-65)
	enemy.hp = 100.0
	game.wingmen[0].cooldown = 0.0
	game.wingmen[1].cooldown = 0.0
	for frame in range(6): game._process(0.05)
	await picture("04-specialist-weapons")
	game.audio.stop_music()
	game.queue_free()
	await process_frame
	await process_frame
	print("SQUADRON_RENDER_PASS: locked/unlocked main screen, three formations, upgraded specialist weapons")
	quit()

func picture(filename: String) -> void:
	for frame in range(9): await process_frame
	await RenderingServer.frame_post_draw
	var screenshot := root.get_texture().get_image()
	if screenshot.save_png(output.path_join(filename+".png"))!=OK:
		quit(1)
