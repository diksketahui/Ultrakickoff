class_name FormationPitch
extends Control
# Visual lapangan + titik pemain. Titik BISA DIGESER manual (sentuh/drag);
# posisi kustom tersimpan dan dipakai ulang sampai formasi diganti / reset.
signal positions_changed

var formation: String = "4-4-2"
var custom: Array = []
var editable: bool = true
var drag_idx: int = -1
var home_color: Color = Color(0.25, 0.62, 1.0)
var gk_color: Color = Color(1.0, 0.78, 0.2)
var line_color: Color = Color(1, 1, 1, 0.85)
var grass_a: Color = Color(0.11, 0.44, 0.21)
var grass_b: Color = Color(0.09, 0.38, 0.18)
var hint_color: Color = Color(1, 1, 1, 0.55)

func _ready() -> void:
	custom_minimum_size = Vector2(0, 430)

func set_formation(f: String) -> void:
	formation = f
	custom.clear()
	drag_idx = -1
	queue_redraw()

func reset_positions() -> void:
	custom.clear()
	drag_idx = -1
	queue_redraw()
	positions_changed.emit()

func current_points() -> Array:
	if custom.size() == 11:
		return custom.duplicate()
	return formation_points(formation)

static func formations() -> Array:
	return ["4-4-2", "4-3-3", "3-5-2", "5-4-1", "4-2-3-1"]

static func formation_points(f: String) -> Array:
	if f == "4-3-3":
		return [Vector2(0.5, 0.94), Vector2(0.15, 0.74), Vector2(0.38, 0.76), Vector2(0.62, 0.76), Vector2(0.85, 0.74), Vector2(0.3, 0.55), Vector2(0.5, 0.58), Vector2(0.7, 0.55), Vector2(0.2, 0.32), Vector2(0.5, 0.26), Vector2(0.8, 0.32)]
	if f == "3-5-2":
		return [Vector2(0.5, 0.94), Vector2(0.25, 0.76), Vector2(0.5, 0.78), Vector2(0.75, 0.76), Vector2(0.1, 0.55), Vector2(0.32, 0.58), Vector2(0.5, 0.52), Vector2(0.68, 0.58), Vector2(0.9, 0.55), Vector2(0.35, 0.3), Vector2(0.65, 0.3)]
	if f == "5-4-1":
		return [Vector2(0.5, 0.94), Vector2(0.08, 0.7), Vector2(0.3, 0.74), Vector2(0.5, 0.76), Vector2(0.7, 0.74), Vector2(0.92, 0.7), Vector2(0.15, 0.52), Vector2(0.38, 0.54), Vector2(0.62, 0.54), Vector2(0.85, 0.52), Vector2(0.5, 0.28)]
	if f == "4-2-3-1":
		return [Vector2(0.5, 0.94), Vector2(0.15, 0.74), Vector2(0.38, 0.76), Vector2(0.62, 0.76), Vector2(0.85, 0.74), Vector2(0.35, 0.62), Vector2(0.65, 0.62), Vector2(0.2, 0.42), Vector2(0.5, 0.4), Vector2(0.8, 0.42), Vector2(0.5, 0.26)]
	return [Vector2(0.5, 0.94), Vector2(0.15, 0.74), Vector2(0.38, 0.76), Vector2(0.62, 0.76), Vector2(0.85, 0.74), Vector2(0.15, 0.52), Vector2(0.38, 0.54), Vector2(0.62, 0.54), Vector2(0.85, 0.52), Vector2(0.35, 0.3), Vector2(0.65, 0.3)]

func _gui_input(event: InputEvent) -> void:
	if not editable or size.x < 10.0 or size.y < 10.0:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_grab(mb.position)
			else:
				_release()
	elif event is InputEventMouseMotion and drag_idx >= 0:
		_drag_to((event as InputEventMouseMotion).position)
	elif event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			_grab(st.position)
		else:
			_release()
	elif event is InputEventScreenDrag:
		_drag_to((event as InputEventScreenDrag).position)

func _to_px(p: Vector2) -> Vector2:
	return Vector2(size.x * p.x, size.y * p.y)

func _grab(pos: Vector2) -> void:
	var pts: Array = current_points()
	var best: int = -1
	var best_d: float = 34.0
	for i in range(pts.size()):
		var d: float = pos.distance_to(_to_px(pts[i]))
		if d < best_d:
			best_d = d
			best = i
	drag_idx = best

func _drag_to(pos: Vector2) -> void:
	if drag_idx < 0:
		return
	if custom.size() != 11:
		custom = current_points()
	custom[drag_idx] = Vector2(clampf(pos.x / size.x, 0.04, 0.96), clampf(pos.y / size.y, 0.04, 0.96))
	queue_redraw()

func _release() -> void:
	if drag_idx >= 0:
		drag_idx = -1
		positions_changed.emit()

func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	if w < 10.0 or h < 10.0:
		return
	var stripes: int = 8
	for i in range(stripes):
		var c: Color = grass_a if i % 2 == 0 else grass_b
		draw_rect(Rect2(0, h * float(i) / float(stripes), w, h / float(stripes) + 1.0), c)
	draw_rect(Rect2(0, 0, w, h), line_color, false, 3.0)
	draw_line(Vector2(0, h * 0.5), Vector2(w, h * 0.5), line_color, 2.0)
	draw_arc(Vector2(w * 0.5, h * 0.5), w * 0.14, 0.0, TAU, 32, line_color, 2.0)
	draw_circle(Vector2(w * 0.5, h * 0.5), 4.0, line_color)
	draw_rect(Rect2(w * 0.28, 0, w * 0.44, h * 0.13), line_color, false, 2.0)
	draw_rect(Rect2(w * 0.28, h * 0.87, w * 0.44, h * 0.13), line_color, false, 2.0)
	draw_rect(Rect2(w * 0.4, 0, w * 0.2, h * 0.05), line_color, false, 2.0)
	draw_rect(Rect2(w * 0.4, h * 0.95, w * 0.2, h * 0.05), line_color, false, 2.0)
	var pts: Array = current_points()
	for i in range(pts.size()):
		var pos := _to_px(pts[i])
		var col: Color = gk_color if i == 0 else home_color
		if i == drag_idx:
			draw_arc(pos, 17.0, 0.0, TAU, 24, Color(1, 1, 1, 0.9), 2.0)
		draw_circle(pos + Vector2(1.5, 2.0), 11.0, Color(0, 0, 0, 0.35))
		draw_circle(pos, 11.0, col)
		draw_arc(pos, 11.0, 0.0, TAU, 24, Color(0, 0, 0, 0.6), 2.0)
		draw_circle(pos, 3.0, Color(1, 1, 1, 0.9))
	if editable:
		draw_string(ThemeDB.fallback_font, Vector2(8, h - 8), "Geser titik untuk atur posisi manual", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, hint_color)
