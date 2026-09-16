class_name CombatAudioPresenter
extends Node

signal audio_event_played(kind: String)

const MIX_RATE := 22050
const STEP_DISTANCE := 72.0

var _buneko
var _step_distance := 0.0
var _last_buneko_position := Vector2.ZERO
var _players: Dictionary = {}
var _streams: Dictionary = {}

func _ready() -> void:
	_streams = {
		"step": _create_tone(105.0, 0.055, 0.12),
		"swing": _create_tone(280.0, 0.09, 0.10, 0.55),
		"hit": _create_tone(72.0, 0.11, 0.18),
		"landing": _create_tone(92.0, 0.08, 0.15),
	}
	for kind in _streams:
		var player := AudioStreamPlayer.new()
		player.name = "%sAudio" % kind.capitalize()
		player.stream = _streams[kind]
		player.volume_db = -7.0
		add_child(player)
		_players[kind] = player

func _process(_delta: float) -> void:
	if _buneko == null or not is_instance_valid(_buneko):
		return
	var current_position: Vector2 = _buneko.global_position
	if _buneko.is_physics_processing() and _buneko.is_on_floor() and absf(_buneko.velocity.x) > 1.0:
		_step_distance += absf(current_position.x - _last_buneko_position.x)
		if _step_distance >= STEP_DISTANCE:
			_step_distance = fmod(_step_distance, STEP_DISTANCE)
			play_event("step")
	else:
		_step_distance = 0.0
	_last_buneko_position = current_position

func observe_buneko(buneko) -> void:
	_buneko = buneko
	_step_distance = 0.0
	_last_buneko_position = buneko.global_position if buneko != null else Vector2.ZERO
	if buneko != null and buneko.has_signal("landed"):
		buneko.landed.connect(_on_buneko_landed)

func play_swing() -> void:
	play_event("swing")

func play_hit() -> void:
	play_event("hit")

func play_event(kind: String) -> void:
	var player = _players.get(kind)
	if player == null:
		return
	player.stop()
	player.play()
	audio_event_played.emit(kind)

func stop_all() -> void:
	for player in _players.values():
		player.stop()
	_step_distance = 0.0

func _on_buneko_landed(_actor) -> void:
	play_event("landing")

func _create_tone(frequency: float, duration: float, amplitude: float, end_frequency_scale := 1.0) -> AudioStreamWAV:
	var sample_count := maxi(1, int(MIX_RATE * duration))
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var phase := 0.0
	for index in sample_count:
		var progress := float(index) / float(sample_count)
		var current_frequency := lerpf(frequency, frequency * end_frequency_scale, progress)
		phase += TAU * current_frequency / MIX_RATE
		var envelope := pow(1.0 - progress, 2.0)
		var sample := int(clampf(sin(phase) * amplitude * envelope, -1.0, 1.0) * 32767.0)
		data.encode_s16(index * 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	return stream
