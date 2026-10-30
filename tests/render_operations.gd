extends SceneTree
## Arranged actual-engine inspection views; no campaign playthrough is claimed.
func _initialize() -> void: call_deferred("run")
func capture(name: String) -> void:
	await process_frame; await RenderingServer.frame_post_draw
	if root.get_texture().get_image().save_png("res://docs/previews/expanded-"+name+".png")!=OK: quit(1)
func run() -> void:
	root.size = Vector2i(1280,720)
	var game: Node3D = load("res://scenes/main.tscn").instantiate()
	root.add_child(game); game.set_process(false); await process_frame
	game.save.data = game.save.fresh()
	game.audio.set_muted(true)
	game.save.data.settings.ui_scale = 1.5; game._resize_ui(); game._menu()
	await capture("large-ui")
	game._settings_menu(); await capture("large-settings")
	game.save.data.settings.ui_scale = 1.0; game._resize_ui()
	var stages := [1,3,1,2,1,1,4,1,2,1]
	for i in range(game.Catalog.IDS.size()):
		game._launch(game.Catalog.IDS[i]); game.set_process(false)
		game.session.stage = stages[i]; game.session._enter()
		game.session.stage_time = 21 if i==9 else 2
		game.session._update_hazards(0)
		game._sync_actors(0)
		var focus: Vector3 = game.session.boss_position if game.session.core_hp>0 else Vector3(0,75,-100)
		if i==5: focus = Vector3(0,6,-280)
		game.camera.position = focus+Vector3(105,75,150); game.camera.look_at(focus)
		game.caption.text = game.session.definition.title+"\n"+game.session.state().text+"\nARRANGED ENGINE INSPECTION / "+game.session.state().id
		await capture("operation-%02d"%[i+1])
	game.queue_free(); await process_frame; await process_frame
	print("RENDER_OPERATIONS: 12 actual-engine inspection views saved")
	quit()
