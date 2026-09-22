class_name UKSfx
extends Node
# SFX khas sepak bola, disintesis via kode (bebas komersial penuh):
# peluit 1x/HT/FT, tendangan kulit, gol, peluang gagal, crowd stadion,
# tepuk tangan, groan kebobolan, tick UI lembut.

const RATE: int = 22050

var players: Dictionary = {}
var crowd: AudioStreamPlayer

func _ready() -> void:
	_add("click", _blip(), -20.0)
	_add("kick", _boot(), -12.0)
	_add("whistle", _peep(0.55, 2250.0), -11.0)
	_add("ht", _peeps([0.35, 0.5], 2250.0), -11.0)
	_add("ft", _peeps([0.3, 0.3, 0.8], 2250.0), -10.0)
	_add("cheer", _roar(2.2, true), -9.0)
	_add("ooh", _roar(0.7, false), -12.0)
	_add("boo", _groan(), -13.0)
	_add("applause", _claps(), -12.0)
	crowd = AudioStreamPlayer.new()
	crowd.stream = _crowd_loop()
	crowd.volume_db = -30.0
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
	s.data[i] = clampi(128 + int(100.0 * v), 1, 254)

# Tick UI: blip sinus sangat pendek + lembut.
func _blip() -> AudioStreamWAV:
	var n: int = int(RATE * 0.06)
	var s := _new_stream(n)
	for i in range(n):
		var t: float = float(i) / float(RATE)
		_put(s, i, sin(TAU * 660.0 * t) * exp(-40.0 * t) * 0.6)
	return s

# Tendangan bola: dentum rendah + desis kulit, tanpa bunyi arcade.
func _boot() -> AudioStreamWAV:
	var n: int = int(RATE * 0.16)
	var s := _new_stream(n)
	var lp: float = 0.0
	for i in range(n):
		var t: float = float(i) / float(RATE)
		var noise: float = randf() * 2.0 - 1.0
		lp = 0.85 * lp + 0.15 * noise
		var v: float = sin(TAU * 82.0 * t) * exp(-26.0 * t) + lp * 0.7 * exp(-30.0 * t)
		_put(s, i, v * 0.8)
	return s

# Peluit tunggal.
func _peep(dur: float, freq: float) -> AudioStreamWAV:
	var n: int = int(RATE * dur)
	var s := _new_stream(n)
	for i in range(n):
		var t: float = float(i) / float(RATE)
		var vib: float = 1.0 + 0.015 * sin(TAU * 28.0 * t)
		var env: float = minf(1.0, t / 0.02) * minf(1.0, (dur - t) / 0.06)
		_put(s, i, sin(TAU * freq * vib * t) * 0.55 * env)
	return s

# Rangkaian peluit (HT/FT).
func _peeps(durs: Array, freq: float) -> AudioStreamWAV:
	var gap: float = 0.12
	var total: float = gap * float(durs.size() - 1)
	for d in durs:
		total += float(d)
	var n: int = int(RATE * total)
	var s := _new_stream(n)
	var pos: int = 0
	for d in durs:
		var dd: float = float(d)
		var m: int = int(RATE * dd)
		for i in range(m):
			var t: float = float(i) / float(RATE)
			var vib: float = 1.0 + 0.015 * sin(TAU * 28.0 * t)
			var env: float = minf(1.0, t / 0.02) * minf(1.0, (dd - t) / 0.05)
			_put(s, pos + i, sin(TAU * freq * vib * t) * 0.55 * env)
		pos += m + int(RATE * gap)
	return s

# Raungan gol / "ooh" peluang: noise menyerupai crowd, bukan nada synth.
func _roar(dur: float, big: bool) -> AudioStreamWAV:
	var n: int = int(RATE * dur)
	var s := _new_stream(n)
	var lp: float = 0.0
	var lp2: float = 0.0
	for i in range(n):
		var t: float = float(i) / float(RATE)
		var noise: float = randf() * 2.0 - 1.0
		lp = 0.93 * lp + 0.07 * noise
		lp2 = 0.985 * lp2 + 0.015 * noise
		var env: float = minf(1.0, t / 0.15) * exp(-(1.0 if big else 2.6) * t)
		_put(s, i, (lp * 2.4 + lp2 * 2.0) * env * (1.0 if big else 0.7))
	return s

# Groan kebobolan: dengung crowd menurun.
func _groan() -> AudioStreamWAV:
	var n: int = int(RATE * 0.9)
	var s := _new_stream(n)
	var lp: float = 0.0
	for i in range(n):
		var t: float = float(i) / float(RATE)
		var noise: float = randf() * 2.0 - 1.0
		lp = 0.95 * lp + 0.05 * noise
		var env: float = minf(1.0, t / 0.08) * exp(-2.2 * t)
		_put(s, i, (lp * 2.6 + 0.12 * sin(TAU * (220.0 - 90.0 * t) * t)) * env)
	return s

# Tepuk tangan: letupan-letupan jarang.
func _claps() -> AudioStreamWAV:
	var n: int = int(RATE * 1.4)
	var s := _new_stream(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in range(n):
		var t: float = float(i) / float(RATE)
		var v: float = 0.0
		if rng.randf() < 0.028:
			v = (rng.randf() * 2.0 - 1.0) * exp(-90.0 * (t - float(int(t * 90.0)) / 90.0))
		_put(s, i, v * 0.8 * exp(-0.7 * t))
	return s

# Crowd stadion: dengung halus berloop.
func _crowd_loop() -> AudioStreamWAV:
	var n: int = RATE * 4
	var s := _new_stream(n)
	var lp: float = 0.0
	for i in range(n):
		var noise: float = randf() * 2.0 - 1.0
		lp = 0.975 * lp + 0.025 * noise
		_put(s, i, lp * 1.6)
	s.loop_mode = AudioStreamWAV.LOOP_FORWARD
	s.loop_begin = 0
	s.loop_end = n
	return s
