class_name FoxFlightAudio
extends Node
## Authored MBean1 campaign loops, rendered offline to keep synthesis off the game thread.

const MUSIC_PATHS: Array[String] = [
	"res://assets/audio/mbean/campaign/viridia-flight.ogg", "res://assets/audio/mbean/campaign/viridia-boss.ogg",
	"res://assets/audio/mbean/campaign/aurora-flight.ogg", "res://assets/audio/mbean/campaign/aurora-boss.ogg",
	"res://assets/audio/mbean/campaign/terminus-flight.ogg", "res://assets/audio/mbean/campaign/terminus-boss.ogg",
	"res://assets/audio/mbean/campaign/cinder-flight.ogg", "res://assets/audio/mbean/campaign/cinder-boss.ogg",
	"res://assets/audio/mbean/campaign/anchorage-flight.ogg", "res://assets/audio/mbean/campaign/anchorage-boss.ogg",
	"res://assets/audio/mbean/campaign/tempest-flight.ogg", "res://assets/audio/mbean/campaign/tempest-boss.ogg",
]
const CROSSFADE_SECONDS: float = 0.65
const OPERATION_PATHS: Array[String] = [
	"res://assets/audio/mbean/campaign/viridia_last_ferry.ogg",
	"res://assets/audio/mbean/campaign/aurora_courier.ogg",
	"res://assets/audio/mbean/campaign/terminus_falling_yard.ogg",
	"res://assets/audio/mbean/campaign/tempest_stormbreak.ogg",
]
const OPERATION_TRACKS := {"viridia_blockade":0,"viridia_last_ferry":12,"aurora_relay":2,"aurora_courier":13,"terminus_siege":4,"cinder_corridor":6,"anchorage_defense":8,"terminus_falling_yard":14,"tempest_stormbreak":15,"tempest_crown":10}
# Sparse authored cues measure quieter than the dense legacy excerpts.
const MUSIC_GAIN_DB: float = -4.0
const EFFECT_NAMES: Array[String] = [
	"laser", "hit", "explosion", "roll", "boost", "lock", "missile",
	"pickup", "warning", "victory", "ui", "death",
]
const EFFECT_GAINS := {"laser": -13.0, "hit": -7.0, "explosion": -4.0,
	"roll": -5.0, "boost": -4.0, "lock": -7.0, "missile": -5.0,
	"pickup": -5.0, "warning": -8.0, "victory": -3.0, "ui": -8.0, "death": -4.0}
const VOICE_COUNT: int = 12

var muted: bool = false
var volume: float = 0.8
var _music: AudioStreamPlayer
var _fading_music: AudioStreamPlayer
var _music_gain: float = 1.0
var _fading_gain: float = 0.0
var _fade_start_gain: float = 0.0
var _fade_elapsed: float = -1.0
var _voices: Array[AudioStreamPlayer] = []
var _tracks: Array[AudioStreamOggVorbis] = []
var _effects: Dictionary = {}
var _voice_cursor: int = 0
var _current_track: int = -1
var _laser_gate: float = 0.0


func _ready() -> void:
	_music = AudioStreamPlayer.new()
	_music.name = "Soundtrack"
	add_child(_music)
	_fading_music = AudioStreamPlayer.new()
	_fading_music.name = "SoundtrackTail"
	add_child(_fading_music)
	set_process(false)
	for path: String in MUSIC_PATHS+OPERATION_PATHS:
		var track := load(path) as AudioStreamOggVorbis
		if track != null:
			track.loop = true
			track.loop_offset = 0.0
		_tracks.append(track)
	for effect: String in EFFECT_NAMES:
		_effects[effect] = load("res://assets/audio/%s.wav" % effect)
	for i: int in range(VOICE_COUNT):
		var voice := AudioStreamPlayer.new()
		voice.name = "Effect%02d" % i
		add_child(voice)
		_voices.append(voice)
	_apply_mix()


func start_music(stage: int, boss: bool = false) -> void:
	if not is_node_ready():
		await ready
	var track_index: int = clampi(stage, 0, int(MUSIC_PATHS.size() / 2.0) - 1) * 2 + int(boss)
	_start_track(track_index)

func start_operation_music(id: String, boss: bool = false) -> void:
	if not is_node_ready(): await ready
	var index: int = int(OPERATION_TRACKS.get(id,0))
	if boss:
		var regions := {"terminus_falling_yard":5,"viridia_last_ferry":1,"aurora_courier":3,"tempest_stormbreak":11}
		index = int(regions.get(id,index+1))
	_start_track(index)

func _start_track(track_index: int) -> void:
	if track_index == _current_track and _music.playing:
		return
	# Two fixed voices bound overlap even if a retry/menu interrupts a transition.
	var outgoing_gain: float = _music_gain
	if _fading_music.playing and _fading_gain > _music_gain:
		# Keep the louder tail if another request arrives before the new cue rises.
		_music.stop()
		_music.stream = null
		outgoing_gain = _fading_gain
	else:
		_fading_music.stop()
		_fading_music.stream = null
		if _music.playing:
			var spare := _fading_music
			_fading_music = _music
			_music = spare
	if _fading_music.playing:
		_fading_gain = outgoing_gain
		_fade_start_gain = outgoing_gain
		_music_gain = 0.0
		_fade_elapsed = 0.0
		set_process(true)
	else:
		_fading_gain = 0.0
		_music_gain = 1.0
		_fade_elapsed = -1.0
		set_process(false)
	_current_track = track_index
	_music.stream = _tracks[track_index]
	_apply_mix()
	_music.play()


func _process(delta: float) -> void:
	_fade_elapsed += delta
	var progress: float = clampf(_fade_elapsed / CROSSFADE_SECONDS, 0.0, 1.0)
	# Linear amplitude ramps keep the sum bounded, including rapid transitions.
	_music_gain = progress
	_fading_gain = _fade_start_gain * (1.0 - progress)
	if progress >= 1.0:
		_fading_music.stop()
		_fading_music.stream = null
		_fading_gain = 0.0
		_fade_elapsed = -1.0
		set_process(false)
	_apply_mix()


func stop_music() -> void:
	if is_instance_valid(_music):
		_music.stop()
	if is_instance_valid(_fading_music):
		_fading_music.stop()
		_fading_music.stream = null
	_music_gain = 1.0
	_fading_gain = 0.0
	_fade_elapsed = -1.0
	set_process(false)
	_current_track = -1


func _exit_tree() -> void:
	stop_music()
	if is_instance_valid(_music): _music.stream = null
	for voice: AudioStreamPlayer in _voices:
		voice.stop()
		voice.stream = null
	_tracks.clear()
	_effects.clear()


func set_muted(value: bool) -> void:
	muted = value
	_apply_mix()


func set_volume(linear: float) -> void:
	volume = clampf(linear, 0.0, 1.0)
	_apply_mix()


func _apply_mix() -> void:
	var gain: float = -80.0 if muted or volume <= 0.0 else linear_to_db(volume)
	if is_instance_valid(_music):
		_music.volume_db = MUSIC_GAIN_DB + gain + linear_to_db(maxf(_music_gain, 0.0001))
	if is_instance_valid(_fading_music):
		_fading_music.volume_db = MUSIC_GAIN_DB + gain + linear_to_db(maxf(_fading_gain, 0.0001))
	for voice: AudioStreamPlayer in _voices:
		voice.volume_db = float(voice.get_meta("gain", -7.0)) + gain


func sfx(kind: String) -> void:
	if not _effects.has(kind) or _voices.is_empty() or muted:
		return
	# Continuous weapons should never fill all twelve voices in one frame.
	var now: float = Time.get_ticks_msec() / 1000.0
	if kind == "laser":
		if now < _laser_gate:
			return
		_laser_gate = now + 0.06
	var voice: AudioStreamPlayer = _voices[_voice_cursor]
	for candidate: AudioStreamPlayer in _voices:
		if not candidate.playing:
			voice = candidate
			break
	_voice_cursor = (_voice_cursor + 1) % VOICE_COUNT
	voice.stream = _effects[kind]
	var effect_gain: float = float(EFFECT_GAINS.get(kind, -7.0))
	voice.set_meta("gain", effect_gain)
	voice.volume_db = effect_gain + (-80.0 if volume <= 0.0 else linear_to_db(volume))
	voice.pitch_scale = randf_range(0.94, 1.06) if kind in ["laser", "hit", "explosion"] else 1.0
	voice.play()
