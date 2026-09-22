class_name UKEngine
extends RefCounted

static func team_strength(team: Dictionary, tactics: Dictionary, is_home: bool) -> Dictionary:
	var m: Dictionary = UKTactics.tactics_modifier(tactics)
	var s: float = float(team.get("ovr", 70)) + float(m["att"]) * 10.0
	if is_home:
		s += 2.0
	s += (float(team.get("staminaAvg", 72.0)) - 70.0) * 0.05
	s += (float(team.get("moodAvg", 68.0)) - 70.0) * 0.03
	return {"s": s, "m": m}

static func sim_minute(att: Dictionary, dfn: Dictionary, t_a: Dictionary, t_b: Dictionary, ctx: Dictionary) -> String:
	var a: Dictionary = team_strength(att, t_a, true)
	var b: Dictionary = team_strength(dfn, t_b, false)
	var p_a: float = clampf(0.028 + (float(a["s"]) - 70.0) * 0.0012, 0.004, 0.09) * float(a["m"]["xg"])
	var p_b: float = clampf(0.024 + (float(b["s"]) - 70.0) * 0.0012, 0.004, 0.08) * float(b["m"]["xg"])
	if str(ctx.get("refBias", "")) == "home":
		p_a *= 1.15
	if str(ctx.get("refBias", "")) == "away":
		p_b *= 1.15
	if str(ctx.get("parkBus", "")) == "home":
		p_a *= 0.85
	if str(ctx.get("parkBus", "")) == "away":
		p_b *= 0.85
	var r: float = randf()
	if r < p_a:
		return "home"
	if r < p_a + p_b:
		return "away"
	return ""

static func sim_match(home: Dictionary, away: Dictionary, t_h: Dictionary, t_a: Dictionary, opts: Dictionary = {}) -> Dictionary:
	var hs: int = 0
	var as_: int = 0
	var log: Array = []
	var ch_h: int = 0
	var ch_a: int = 0
	for m in range(1, 91):
		var g: String = sim_minute(home, away, t_h, t_a, {
			"home": true,
			"refBias": opts.get("refBias", ""),
			"parkBus": opts.get("parkBus", ""),
		})
		if randf() < 0.09:
			ch_h += 1
		if randf() < 0.08:
			ch_a += 1
		if g == "home":
			hs += 1
			log.append("%d' GOL %s" % [m, str(home.get("name", "Home"))])
		elif g == "away":
			as_ += 1
			log.append("%d' GOL %s" % [m, str(away.get("name", "Away"))])
		if m == 45 or m == 90:
			log.append("%d' skor %d-%d" % [m, hs, as_])
	return {
		"hs": hs, "as": as_, "log": log,
		"stats": {
			"chancesH": ch_h, "chancesA": ch_a,
			"tacticH": UKTactics.describe_tactics(t_h),
			"tacticA": UKTactics.describe_tactics(t_a),
		},
	}
