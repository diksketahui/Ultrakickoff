class_name UKSfx
extends Node
# SFX 100% bebas komersial: disintesis via kode saat runtime, tanpa file audio,
# tanpa unduhan, tanpa ketergantungan lisensi pihak ketiga.

const RATE: int = 22050

var players: Dictionary = {}
var crowd: AudioStreamPlayer

func _ready() -> void:
	_add("click", _tone(880.0, 0.07, 6.0), -14.0)
	_add("kick", _thump(), -10.0)
	_add("whistle", _whistle(), -9.0)
	_add("cheer", _cheer(), -7.0)
	_add("boo", _tone(160.0, 0.5, 2.0), -12.0)
	crowd = AudioStreamPlayer.new()
	crowd.stream = _crowd_loop()
	crowd.volume_db = -26.0
	add_child(crowd)

func play(nm: String) -> void:
	if players.has(nm):
		(players[nm] as AudioStreamPlayer).play()

func crowd_start() -> void:
	if not crowd.playing:
		crowd.play()

func crowd_stop() -> void:
	crowd.stop()

func _add(nm: String, stream: AudioStreamWAV, vol: float) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = vol
	add_child(p)
	players[nm] = p

func _new_stream(frames: int) -> AudioStreamWAV:
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_8_BITS
	s.mix_rate = RATE
	s.stereo = false
	s.loop_mode = AudioStreamWAV.LOOP_DISABLED
	var d := PackedByteArray()
	d.resize(frames)
	s.data = d
	return s

func _put(s: AudioStreamWAV, i: int, v: float) -> void:
	s.data[i] = clampi(128 + int(110.0 * v), 1, 254) as int

func _tone(freq: float, dur: float, decay: float) -> AudioStreamWAV:
	var n: int = int(RATE * dur)
	var s := _new_stream(n)
	for i in range(n):
		var t: float = float(i) / float(RATE)
		_put(s, i, sin(TAU * freq * t) * exp(-decay * t))
	return s

func _thump() -> AudioStreamWAV:
	var n: int = int(RATE * 0.2)
	var s := _new_stream(n)
	for i in range(n):
		var t: float = float(i) / float(RATE)
		var v: float = sin(TAU * 110.0 * t) * exp(-22.0 * t) + 0.4 * sin(TAU * 55.0 * t) * exp(-15.0 * t)
		_put(s, i, v)
	return s

func _whistle() -> AudioStreamWAV:
	var n: int = int(RATE * 0.8)
	var s := _new_stream(n)
	for i in range(n):
		var t: float = float(i) / float(RATE)
		var f: float = 2150.0 if t < 0.35 else 2600.0
		var vib: float = 1.0 + 0.02 * sin(TAU * 30.0 * t)
		var env: float = minf(1.0, t / 0.03) * minf(1.0, (0.8 - t) / 0.1)
		_put(s, i, sin(TAU * f * vib * t) * 0.8 * env)
	return s

func _cheer() -> AudioStreamWAV:
	var n: int = int(RATE * 1.6)
	var s := _new_stream(n)
	var lp: float = 0.0
	for i in range(n):
		var t: float = float(i) / float(RATE)
		var noise: float = randf() * 2.0 - 1.0
		lp = 0.94 * lp + 0.06 * noise
		var env: float = minf(1.0, t / 0.12) * exp(-1.1 * t)
		_put(s, i, (lp * 3.0 + 0.25 * sin(TAU * 320.0 * t)) * env)
	return s

func _crowd_loop() -> AudioStreamWAV:
	var n: int = RATE * 3
	var s := _new_stream(n)
	var lp: float = 0.0
	for i in range(n):
		var noise: float = randf() * 2.0 - 1.0
		lp = 0.97 * lp + 0.03 * noise
		_put(s, i, lp * 2.2)
	s.loop_mode = AudioStreamWAV.LOOP_FORWARD
	s.loop_begin = 0
	s.loop_end = n
	return s
