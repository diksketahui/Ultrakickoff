class_name UKTactics
extends RefCounted

static func default_tactics() -> Dictionary:
	return {
		"formation": "4-4-2",
		"line": 50, "width": 50, "press": 50, "tempo": 50,
		"build": "tengah", "passLen": "campuran", "passDir": "maju",
		"players": {},
	}

static func player_tactic(t: Dictionary, player_id: String) -> Dictionary:
	if not t["players"].has(player_id):
		t["players"][player_id] = {
			"run": "support", "vertical": 50, "drift": 50,
			"passDir": "maju", "role": "default", "marking": "zona", "press": 50,
		}
	return t["players"][player_id]

static func set_formation(t: Dictionary, f: String) -> Dictionary:
	t["formation"] = f
	return t

static func tactics_modifier(t: Dictionary) -> Dictionary:
	var m: Dictionary = {
		"att": (float(t["line"]) - 50.0) * 0.004 + (float(t["tempo"]) - 50.0) * 0.003,
		"def": (50.0 - float(t["line"])) * 0.004 + (float(t["press"]) - 50.0) * 0.002,
		"xg": 1.0 + (float(t["tempo"]) - 50.0) * 0.002,
	}
	if t["build"] == "kiri" or t["build"] == "kanan":
		m["att"] = float(m["att"]) + 0.01
	if t["passLen"] == "panjang":
		m["xg"] = float(m["xg"]) + 0.03
	if t["passLen"] == "pendek":
		m["xg"] = float(m["xg"]) - 0.02
	return m

static func describe_tactics(t: Dictionary) -> String:
	return "%s | garis %d | %s | %s/%s" % [t["formation"], int(t["line"]), t["build"], t["passLen"], t["passDir"]]
