class_name MatchPitch
extends Control
# Preview jalannya laga: bola + 22 pemain bergerak live selama simulasi progresif.

var ball: Vector2 = Vector2(0.5, 0.5)
var target: Vector2 = Vector2(0.5, 0.5)
var clock: float = 0.0
var flash: float = 0.0
var home_base: Array = []
var away_base: Array = []
var home_color: Color = Color(0.25, 0.62, 1.0)
var away_color: Color = Color(0.95, 0.3, 0.3)
var line_color: Color = Color(1, 1, 1, 0.8)
var grass_a: Color = Color(0.11, 0.44, 0.21)
var grass_b: Color = Color(0.09, 0.38, 0.18)

func _ready() -> void:
	custom_minimum_size = Vector2(0, 300)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	home_base = FormationPitch.formation_points("4-4-2")
	away_base = []
	for p in home_base:
		away_base.append(Vector2(p.x, 1.0 - p.y))

func setup() -> void:
	ball = Vector2(0.5, 0.5)
	target = Vector2(0.5, 0.5)
	flash = 0.0
	queue_redraw()

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
	else:
		target = Vector2(randf_range(0.25, 0.75), randf_range(0.3, 0.7))

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	clock += delta
	var k: float = minf(1.0, delta * 2.2)
	ball = ball.lerp(target, k)
	if flash > 0.0:
		flash -= delta
	queue_redraw()

func _jitter(base: Vector2, seed: float, amp: float) -> Vector2:
	return Vector2(base.x + sin(clock * 1.7 + seed) * amp, base.y + cos(clock * 1.3 + seed * 1.7) * amp)

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
			var hp := _jitter(home_base[i], float(i) * 1.3, 0.02)
			var ap := _jitter(away_base[i], float(i) * 2.1 + 5.0, 0.02)
			draw_circle(Vector2(w * ap.x, h * ap.y), 6.0, away_color)
			draw_circle(Vector2(w * hp.x, h * hp.y), 6.0, home_color)
	var bp := Vector2(w * ball.x, h * ball.y)
	if flash > 0.0:
		var r: float = 10.0 + 8.0 * absf(sin(clock * 10.0))
		draw_arc(bp, r, 0.0, TAU, 24, Color(1, 0.9, 0.3, 0.9), 2.5)
	draw_circle(bp + Vector2(1, 1.5), 5.0, Color(0, 0, 0, 0.4))
	draw_circle(bp, 5.0, Color(1, 1, 1))
	draw_arc(bp, 5.0, 0.0, TAU, 16, Color(0, 0, 0, 0.7), 1.5)
