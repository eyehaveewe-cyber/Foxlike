extends SceneTree
## Exercise shipped OGG streams, fixed-voice transitions and real mission events.
const Sound = preload("res://scripts/flight_audio.gd")
const MAIN = preload("res://scenes/main.tscn")
const TEST_SAVE := "user://foxlike_test_save.json"
var assertions := 0
var failures: Array[String] = []

func _initialize() -> void:
	if not "--test-save" in OS.get_cmdline_user_args():
		push_error("Run with -- --test-save; refusing to touch a player save.")
		quit(2)
		return
	call_deferred("_run")

func check(value: bool, label: String) -> void:
	assertions += 1
	if not value: failures.append(label)

func _run() -> void:
	var sound := Sound.new()
	root.add_child(sound)
	await process_frame
	sound.set_process(false)
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/audio/mbean/campaign/manifest.json"))
	check(sound._tracks.size() == 12, "All twelve campaign streams are loaded")
	var paths := {}
	for cue: Dictionary in manifest.cues:
		var index: int = int(cue.stage) * 2 + int(cue.boss)
		var track: AudioStreamOggVorbis = sound._tracks[index]
		check(track != null and track.loop and is_zero_approx(track.loop_offset), str(cue.id) + " imported and looping from zero")
		check(absf(track.get_length() - float(cue.seconds)) < 0.01, str(cue.id) + " score and Godot stream durations agree")
		check(track.resource_path.ends_with(str(cue.id) + ".ogg"), str(cue.id) + " has the correct mission/boss destination")
		paths[track.resource_path] = true
		sound.start_music(int(cue.stage), bool(cue.boss))
		sound.set_process(false)
		if sound._fade_elapsed >= 0.0: sound._process(Sound.CROSSFADE_SECONDS)
		check(sound._current_track == index and sound._music.playing, str(cue.id) + " starts in the actual AudioStreamPlayer")
		# play() queues its start for the audio thread. Wait for actual decoding
		# before seeking, including the first stream after driver initialization.
		var deadline: int = Time.get_ticks_msec() + 1000
		while sound._music.get_playback_position() <= 0.0 and Time.get_ticks_msec() < deadline:
			await create_timer(0.02).timeout
		check(sound._music.get_playback_position() > 0.0, str(cue.id) + " native decoder advances before seek")
		# Seek into the last packet and let the native Vorbis decoder wrap it.
		var loops_before: int = sound._music.get_stream_playback().get_loop_count()
		sound._music.seek(track.get_length() - 0.07)
		deadline = Time.get_ticks_msec() + 1000
		while sound._music.playing and sound._music.get_stream_playback().get_loop_count() <= loops_before and Time.get_ticks_msec() < deadline:
			await create_timer(0.02).timeout
		check(sound._music.playing and sound._music.get_stream_playback().get_loop_count() > loops_before and sound._music.get_playback_position() < 1.0, str(cue.id) + " native decoder wraps its loop boundary")
	check(paths.size() == 12, "No missions or bosses share an audio file")
	var player: AudioStreamPlayer = sound._music
	var position: float = player.get_playback_position()
	sound.start_music(5, true)
	check(sound._music == player and sound._music.get_playback_position() >= position, "Repeated request preserves the current playback position")
	sound.start_music(0, false)
	sound.set_process(false)
	check(sound._fading_music == player and sound._fading_music.playing, "Mission change preserves the outgoing voice during crossfade")
	sound._process(Sound.CROSSFADE_SECONDS * 0.5)
	check(is_equal_approx(sound._music_gain, 0.5) and is_equal_approx(sound._fading_gain, 0.5), "Crossfade reaches bounded equal midpoint gains")
	sound.set_muted(true)
	check(sound._music.volume_db <= -80.0 and sound._fading_music.volume_db <= -80.0, "Mute applies to both crossfade voices immediately")
	sound.set_muted(false)
	sound.set_volume(0.25)
	check(absf(sound._music.volume_db - (-4.0 + linear_to_db(0.25 * 0.5))) < 0.001, "Volume changes preserve the crossfade envelope")
	sound.set_volume(0.0)
	check(sound._music.volume_db <= -80.0 and sound._fading_music.volume_db <= -80.0, "Zero volume silences both voices")
	sound.set_volume(0.8)
	sound.start_music(3, true)
	sound.set_process(false)
	sound._process(Sound.CROSSFADE_SECONDS * 0.5)
	check(sound._current_track == 7 and sound._music_gain + sound._fading_gain <= 1.0, "Interrupted transition reaches the newest cue without gain buildup")
	var voices := 0
	for child: Node in sound.get_children():
		if child is AudioStreamPlayer and child.playing: voices += 1
	check(voices == 2, "Rapid changes use exactly two playing music voices")
	sound._process(Sound.CROSSFADE_SECONDS)
	check(not sound._fading_music.playing and sound._fading_music.stream == null and not sound.is_processing(), "Finished crossfade releases the outgoing stream and frame work")
	sound.start_music(100, true)
	check(sound._current_track == 11, "High stage input clamps safely")
	sound.start_music(-5, false)
	check(sound._current_track == 0, "Low stage input clamps safely")
	sound.stop_music()
	check(not sound._music.playing and not sound._fading_music.playing and sound._current_track == -1, "Stop cancels both playback and an in-progress crossfade")
	sound.start_music(2, true)
	check(sound._current_track == 5 and sound._music.playing and is_equal_approx(sound._music_gain, 1.0), "Restart after stop begins at full configured gain")
	player = sound._music
	sound.start_music(3, false)
	sound.start_music(4, false)
	check(sound._fading_music == player and is_equal_approx(sound._fading_gain, 1.0), "Immediate repeated changes preserve the audible tail")
	sound.stop_music()
	sound.queue_free()
	await process_frame
	await _mission_events()
	print("MUSIC_SMOKE: %d assertions; %d failures" % [assertions, failures.size()])
	for failure: String in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)

func _mission_events() -> void:
	var had_save := FileAccess.file_exists(TEST_SAVE)
	var prior_save := FileAccess.get_file_as_string(TEST_SAVE) if had_save else ""
	var fixture := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	fixture.store_string(JSON.stringify({"unlocked": 6, "muted": true, "difficulty": "Standard"}))
	fixture.close()
	var game := MAIN.instantiate()
	root.add_child(game)
	game.set_process(false)
	await process_frame
	check(game.audio._current_track == 0, "Flight deck starts Viridia's theme")
	for stage: int in range(6):
		game._begin_stage(stage)
		check(game.audio._current_track == stage * 2, "Mission %d briefing starts its authored flight cue" % stage)
		game._launch()
		check(game.audio._current_track == stage * 2, "Mission %d launch preserves its flight cue" % stage)
		game._spawn_boss()
		check(game.audio._current_track == stage * 2 + 1, "Mission %d real boss event switches to its own cue" % stage)
		game.invulnerable = 0.0
		game._hurt(1000.0)
		game._on_action("retry")
		check(game.mode == game.Mode.BRIEFING and game.audio._current_track == stage * 2, "Mission %d defeat/retry restores its flight cue" % stage)
	game._show_menu()
	check(game.audio._current_track == 0, "Return to flight deck restores Viridia's theme")
	game.audio.stop_music()
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	if had_save:
		var restore := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
		restore.store_string(prior_save)
		restore.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
