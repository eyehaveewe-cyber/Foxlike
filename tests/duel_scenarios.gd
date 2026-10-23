extends SceneTree
## Arranged encounter observations only. These do not satisfy human play gates.
var game: Node3D
func _initialize() -> void: call_deferred("run")
func run() -> void:
	game = load("res://scenes/duel.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	await process_frame
	game.audio.set_muted(true)
	for volume in [0,1]:
		game.volume_index = volume
		game._reset()
		game.run_driver = "automated_brake_circle"
		game._start()
		for i in range(7200):
			game.simulate(1.0/60.0,{"steer":Vector2(.35,0),"brake":true,"fire":false})
			if game.mode!="flight": break
			if i%120==0: await process_frame
		game._write_trace("brake_circle_"+game.mode)
		var shots := 0
		var impacts := 0
		for event in game.trace_events:
			if event.kind=="projectile_hit": impacts+=1
			if event.kind=="weapon_fired": shots+=1
		var transitions: Array = []
		for item in game.pilot.transitions: transitions.append(item.to)
		print("DUEL_SCENARIO: ",JSON.stringify({"volume":volume,"elapsed":game.elapsed,"mode":game.mode,"health":game.hp,"transitions":transitions,"shots":shots,"impacts":impacts,"position":game.vehicles[1].position,"trace":game.trace_path}))
	game.queue_free()
	await process_frame
	await process_frame
	quit()
