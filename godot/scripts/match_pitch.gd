class_name MatchPitch
extends Control
# Preview jalannya laga: digerakkan DATA simulasi asli (possession per menit +
# event gol/peluang), bukan animasi acak. Titik = wajah + nama pemain.

var ball: Vector2 = Vector2(0.5, 0.5)
var target: Vector2 = Vector2(0.5, 0.5)
var clock: float = 0.0
var flash: float = 0.0
var shift: float = 0.0
var shift_target: float = 0.0
var home_base: Array = []
var away_base: Array = []
var home_names: Array = []
var away_names: Array = []
var home_color: Color = Color(0.25, 0.62, 1.0)
var away_color: Color = Color(0.95, 0.3, 0.3)
var line_color: Color = Color(1, 1, 1, 0.8)
var grass_a: Color = Color(0.11, 0.44, 0.21)
var grass_b: Color = Color(0.09, 0.38, 0.18)

func _ready() -> void:
	custom_minimum_size = Vector2(0, 330)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	home_base = FormationPitch.formation_points("4-4-2")
	away_base = []
	for p in home_base:
		away_base.append(Vector2(p.x, 1.0 - p.y))

func setup(hnames: Array = [], anames: Array = []) -> void:
	home_names = hnames.duplicate()
	away_names = anames.duplicate()
	ball = Vector2(0.5, 0.5)
	target = Vector2(0.5, 0.5)
	shift = 0.0
	shift_target = 0.0
	flash = 0.0
	queue_redraw()

# Dipanggil tiap menit simulasi: gerakan mengikuti siapa menguasai bola.
func on_minute(poss_home: bool) -> void:
	shift_target = 0.55 if poss_home else -0.55
	if poss_home:
		target = Vector2(randf_range(0.25, 0.75), randf_range(0.2, 0.45))
	else:
		target = Vector2(randf_range(0.25, 0.75), randf_range(0.55, 0.8))

func on_event(kind: String) -> void:
	if kind == "home_goal":
		target = Vector2(0.5 + randf_range(-0.1, 0.1), 0.03)
		flash = 1.5
	elif kind == "away_goal":
		target = Vector2(0.5 + randf_range(-0.1, 0.1), 0.97)
		flash = 1.5
	elif kind == "chance_h":
		target = Vector2(randf_range(0.2, 0.8), randf_range(0.1, 0.35))
	elif kind == "chance_a":
		target = Vector2(randf_range(0.2, 0.8), randf_range(0.65, 0.9))

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	clock += delta
	var k: float = minf(1.0, delta * 2.2)
	ball = ball.lerp(target, k)
	shift = lerpf(shift, shift_target, minf(1.0, delta * 0.8))
	if flash > 0.0:
		flash -= delta
	queue_redraw()

func _short(label: String) -> String:
	var parts: Array = str(label).split(" ")
	if parts.is_empty():
		return str(label)
	return str(parts[parts.size() - 1]).left(8)

func _jitter(base: Vector2, seed: float, amp: float) -> Vector2:
	return Vector2(base.x + sin(clock * 1.7 + seed) * amp, base.y + cos(clock * 1.3 + seed * 1.7) * amp)

func _draw_dot(pos: Vector2, ring: Color, pname: String) -> void:
	draw_circle(pos + Vector2(1, 1.5), 7.0, Color(0, 0, 0, 0.4))
	draw_circle(pos, 7.0, ring)
	if pname != "":
		draw_circle(pos, 4.5, FaceAvatar.skin_of(pname))
		draw_arc(pos, 4.5, PI, TAU, 10, FaceAvatar.hair_of(pname), 2.5)
		draw_string(ThemeDB.fallback_font, pos + Vector2(-22, 18), _short(pname), HORIZONTAL_ALIGNMENT_CENTER, 44, 9, Color(1, 1, 1, 0.92))

func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	if w < 10.0 or h < 10.0:
		return
	var stripes: int = 6
	for i in range(stripes):
		var c: Color = grass_a if i % 2 == 0 else grass_b
		draw_rect(Rect2(0, h * float(i) / float(stripes), w, h / float(stripes) + 1.0), c)
	draw_rect(Rect2(0, 0, w, h), line_color, false, 2.0)
	draw_line(Vector2(0, h * 0.5), Vector2(w, h * 0.5), line_color, 1.5)
	draw_arc(Vector2(w * 0.5, h * 0.5), w * 0.13, 0.0, TAU, 28, line_color, 1.5)
	draw_rect(Rect2(w * 0.3, 0, w * 0.4, h * 0.12), line_color, false, 1.5)
	draw_rect(Rect2(w * 0.3, h * 0.88, w * 0.4, h * 0.12), line_color, false, 1.5)
	if home_base.size() == 11 and away_base.size() == 11:
		for i in range(11):
			var hb: Vector2 = home_base[i]
			var ab: Vector2 = away_base[i]
			var hp := _jitter(Vector2(hb.x, clampf(hb.y - shift * 0.10, 0.05, 0.95)), float(i) * 1.3, 0.015)
			var ap := _jitter(Vector2(ab.x, clampf(ab.y + shift * 0.10, 0.05, 0.95)), float(i) * 2.1 + 5.0, 0.015)
			var hn: String = str(home_names[i]) if i < home_names.size() else ""
			var an: String = str(away_names[i]) if i < away_names.size() else ""
			_draw_dot(Vector2(w * ap.x, h * ap.y), away_color, an)
			_draw_dot(Vector2(w * hp.x, h * hp.y), home_color, hn)
	var bp := Vector2(w * ball.x, h * ball.y)
	if flash > 0.0:
		var r: float = 10.0 + 8.0 * absf(sin(clock * 10.0))
		draw_arc(bp, r, 0.0, TAU, 24, Color(1, 0.9, 0.3, 0.9), 2.5)
	draw_circle(bp + Vector2(1, 1.5), 5.0, Color(0, 0, 0, 0.4))
	draw_circle(bp, 5.0, Color(1, 1, 1))
	draw_arc(bp, 5.0, 0.0, TAU, 16, Color(0, 0, 0, 0.7), 1.5)
