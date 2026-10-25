extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(condition: bool, label: String) -> void:
	checks += 1
	print(("PASS " if condition else "FAIL ")+label)
	if not condition: failures += 1
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	await process_frame
	game._begin_stage(3)
	game.mode = game.Mode.FLIGHT
	game._update_wingmen(.05)
	check(game.wingmen[0].node.visible and not game.wingmen[1].node.visible,"Left pass starts while right support remains off screen")
	check(game.wingmen[0].node.position.x<game.player.position.x-50,"First aircraft approaches from the left screen edge")
	game._spawn_enemy("fighter",0,1,0)
	game._update_wingmen(1.5)
	check(game.projectiles.size()>0,"Air support fires real projectiles during its attack window")
	game._update_wingmen(3.6)
	check(not game.wingmen[0].node.visible,"Completed pass withdraws instead of joining the tank formation")
	game._update_wingmen(.5)
	check(game.wingmen[1].node.visible and game.wingmen[1].node.position.x>game.player.position.x+50,"Second aircraft approaches from the right on a staggered timer")
	game.mode = game.Mode.DEAD
	game._update_wingmen(.05)
	check(not game.wingmen[0].node.visible and not game.wingmen[1].node.visible,"Tank support stops when the encounter ends")
	game._begin_stage(3)
	game.mode = game.Mode.FLIGHT
	game._update_wingmen(.05)
	check(game.wingmen[0].node.visible and not game.wingmen[1].node.visible,"Retry resets both pass timers")
	game._begin_stage(0)
	game.mode = game.Mode.FLIGHT
	game._update_wingmen(.05)
	check(game.wingmen[0].node.visible and game.wingmen[1].node.visible and game.wingmen[0].node.rotation==Vector3.ZERO,"Flight missions retain their simultaneous wing formation")
	game.queue_free()
	await process_frame
	print("TANK_SUPPORT_SMOKE: %d checks; %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
