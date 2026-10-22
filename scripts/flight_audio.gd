class_name FoxFlightAudio
extends Node
## Original pre-rendered synthesis keeps playback work off the game thread.

const MUSIC_PATHS: Array[String] = [
	"res://assets/audio/viridia.ogg", "res://assets/audio/viridia_boss.ogg",
	"res://assets/audio/aurora.ogg", "res://assets/audio/aurora_boss.ogg",
	"res://assets/audio/terminus.ogg", "res://assets/audio/terminus_boss.ogg",
]
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
	for path: String in MUSIC_PATHS:
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
	var track_index: int = clampi(stage, 0, 2) * 2 + int(boss)
	if track_index == _current_track and _music.playing:
		return
	_current_track = track_index
	_music.stream = _tracks[track_index]
	_music.play()


func stop_music() -> void:
	if is_instance_valid(_music):
		_music.stop()
	_current_track = -1


func _exit_tree() -> void:
	if is_instance_valid(_music):
		_music.stop()
		_music.stream = null
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
		_music.volume_db = -10.0 + gain
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
