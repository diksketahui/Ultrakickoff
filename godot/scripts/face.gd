class_name FaceAvatar
extends Control
# Wajah pemain versi palsu: digambar prosedural dari hash nama.
# Tanpa file gambar, tanpa unduhan, bebas lisensi penuh.

var player_name: String = "?":
	set(v):
		player_name = v
		queue_redraw()
var face_size: float = 34.0:
	set(v):
		face_size = v
		custom_minimum_size = Vector2(v, v)
		queue_redraw()

const SKINS: Array = [Color(0.99, 0.85, 0.70), Color(0.93, 0.74, 0.55), Color(0.78, 0.57, 0.40), Color(0.55, 0.38, 0.26)]
const HAIRS: Array = [Color(0.08, 0.08, 0.10), Color(0.25, 0.14, 0.07), Color(0.55, 0.38, 0.20), Color(0.75, 0.75, 0.78), Color(0.45, 0.22, 0.10)]
const SHIRTS: Array = [Color(0.20, 0.45, 0.85), Color(0.80, 0.20, 0.20), Color(0.15, 0.60, 0.30), Color(0.90, 0.65, 0.15), Color(0.55, 0.25, 0.65)]

func _ready() -> void:
	custom_minimum_size = Vector2(face_size, face_size)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

static func hash_of(label: String) -> int:
	var h: int = 7
	for c in label:
		h = (h * 31 + c.unicode_at(0)) % 1000003
	return h

static func skin_of(label: String) -> Color:
	return SKINS[hash_of(label) % SKINS.size()]

static func hair_of(label: String) -> Color:
	return HAIRS[(hash_of(label) / 7) % HAIRS.size()]

static func shirt_of(label: String) -> Color:
	return SHIRTS[(hash_of(label) / 13) % SHIRTS.size()]

static func style_of(label: String) -> int:
	return (hash_of(label) / 29) % 4

func _hash() -> int:
	return hash_of(player_name)

func _draw() -> void:
	var r: float = minf(size.x, size.y) * 0.5
	if r < 4.0:
		return
	var ctr := size * 0.5
	var h: int = _hash()
	var skin: Color = skin_of(player_name)
	var hair: Color = hair_of(player_name)
	var shirt: Color = shirt_of(player_name)
	var style: int = style_of(player_name)
	# badan
	draw_circle(ctr + Vector2(0, r * 0.95), r * 0.62, shirt)
	# kepala
	draw_circle(ctr + Vector2(0, -r * 0.12), r * 0.52, skin)
	# rambut sesuai gaya
	if style == 0:
		draw_arc(ctr + Vector2(0, -r * 0.12), r * 0.52, PI, TAU, 16, hair, r * 0.34)
	elif style == 1:
		draw_rect(Rect2(ctr.x - r * 0.52, ctr.y - r * 0.72, r * 1.04, r * 0.34), hair)
		draw_circle(ctr + Vector2(0, -r * 0.60), r * 0.16, hair)
	elif style == 2:
		draw_arc(ctr + Vector2(0, -r * 0.12), r * 0.52, PI * 0.9, TAU * 1.02, 16, hair, r * 0.26)
		draw_circle(ctr + Vector2(-r * 0.4, -r * 0.5), r * 0.12, hair)
		draw_circle(ctr + Vector2(r * 0.4, -r * 0.5), r * 0.12, hair)
	else:
		draw_arc(ctr + Vector2(0, -r * 0.12), r * 0.54, PI, TAU, 16, hair, r * 0.2)
	# mata
	draw_circle(ctr + Vector2(-r * 0.18, -r * 0.12), r * 0.06, Color(0.1, 0.1, 0.12))
	draw_circle(ctr + Vector2(r * 0.18, -r * 0.12), r * 0.06, Color(0.1, 0.1, 0.12))
	# senyum
	draw_arc(ctr + Vector2(0, r * 0.08), r * 0.22, 0.35, PI - 0.35, 12, Color(0.35, 0.2, 0.15), 2.0)
	# bingkai
	draw_arc(ctr, r - 1.0, 0.0, TAU, 32, Color(1, 1, 1, 0.35), 2.0)
