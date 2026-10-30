extends SceneTree
var game: Node
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	game = load("res://tests/compact_campaign.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.audio.set_muted(true)
	for i in range(120): game._process(1.0/60)
	await capture("01-title")
	for stage in range(3):
		game._begin_stage(stage)
		game._launch()
		for i in range(3*60+15): game._process(1.0/60)
		game.shield = 100
		game.invulnerable = 1000
		for i in range(10*60): game._process(1.0/60)
		game.player.position = Vector3(-4,1,0)
		for i in range(60): game._process(1.0/60)
		await capture("02-flight-%d"%stage)
		game._clear_actors()
		game._spawn_boss()
		for i in range(9*60): game._process(1.0/60)
		game.hud.say("GLINT","Target those weapon systems. We've got your back.",6)
		await capture("03-boss-%d"%stage)
	game.audio.stop_music()
	game.queue_free()
	await process_frame
	await process_frame
	await create_timer(.3).timeout
	quit()
func capture(label:String) -> void:
	await process_frame
	await create_timer(.35).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/previews/%s.png"%label)
	print("CAPTURE ",label)
