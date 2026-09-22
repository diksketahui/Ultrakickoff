extends Control
# Ultrakickoff Godot — glue UI (port dari js/app.js). Fan-made.
# Tab: Dash / Squad / Taktik / Match / Akademi / Inbox / Board

var club: Dictionary = {}
var tactics: Dictionary = {}
var academy: Array = []
var inbox: Array = []

var club_option: OptionButton
var dash_info: Label
var squad_label: Label
var tactic_form: OptionButton
var tactic_line: HSlider
var tactic_press: HSlider
var tactic_tempo: HSlider
var tactic_build: OptionButton
var tactic_passlen: OptionButton
var tactic_passdir: OptionButton
var tactic_info: Label
var live_log: TextEdit
var academy_label: Label
var inbox_label: Label
var board_label: Label
var ref_bribe: CheckBox

func _ready() -> void:
	randomize()
	tactics = UKTactics.default_tactics()
	_build_ui()
	_refresh_clubs()

func _avatar(n: String) -> String:
	var parts: Array = n.split(" ")
	var s: String = ""
	for w in parts:
		if str(w).length() > 0:
			s += str(w).left(1)
	return "[" + s.left(2).to_upper() + "] "

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 8)
	add_child(root)

	var head := Label.new()
	head.text = "ULTRAKICKOFF — Manager Simulasi Liga Indonesia (Godot)"
	head.add_theme_font_size_override("font_size", 20)
	root.add_child(head)

	var tabs := TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(tabs)

	var dash := VBoxContainer.new()
	dash.name = "Dash"
	tabs.add_child(dash)
	club_option = OptionButton.new()
	dash.add_child(club_option)
	var start_btn := Button.new()
	start_btn.text = "Mulai Karir"
	start_btn.pressed.connect(_on_start)
	dash.add_child(start_btn)
	dash_info = Label.new()
	dash_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dash.add_child(dash_info)

	var squad := VBoxContainer.new()
	squad.name = "Squad"
	tabs.add_child(squad)
	squad_label = Label.new()
	squad_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	squad.add_child(squad_label)

	var tak := VBoxContainer.new()
	tak.name = "Taktik"
	tabs.add_child(tak)
	tactic_form = OptionButton.new()
	for f in ["4-4-2", "4-3-3", "3-5-2", "5-4-1", "4-2-3-1"]:
		tactic_form.add_item(f)
	tak.add_child(tactic_form)
	tactic_line = _mk_slider(tak, "Garis", 50)
	tactic_press = _mk_slider(tak, "Press", 50)
	tactic_tempo = _mk_slider(tak, "Tempo", 50)
	tactic_build = OptionButton.new()
	for b in ["tengah", "kiri", "kanan", "campuran"]:
		tactic_build.add_item(b)
	tak.add_child(tactic_build)
	tactic_passlen = OptionButton.new()
	for b in ["pendek", "campuran", "panjang"]:
		tactic_passlen.add_item(b)
		tactic_passlen.selected = 1
	tak.add_child(tactic_passlen)
	tactic_passdir = OptionButton.new()
	for b in ["maju", "kiri", "kanan", "campuran"]:
		tactic_passdir.add_item(b)
	tak.add_child(tactic_passdir)
	var save_btn := Button.new()
	save_btn.text = "Simpan Taktik"
	save_btn.pressed.connect(_on_save_taktik)
	tak.add_child(save_btn)
	tactic_info = Label.new()
	tak.add_child(tactic_info)

	var match_tab := VBoxContainer.new()
	match_tab.name = "Match"
	tabs.add_child(match_tab)
	ref_bribe = CheckBox.new()
	ref_bribe.text = "Sogok wasit (risiko media)"
	match_tab.add_child(ref_bribe)
	var sim_btn := Button.new()
	sim_btn.text = "Simulasi"
	sim_btn.pressed.connect(_on_sim)
	match_tab.add_child(sim_btn)
	live_log = TextEdit.new()
	live_log.editable = false
	live_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	match_tab.add_child(live_log)

	var akad := VBoxContainer.new()
	akad.name = "Akademi"
	tabs.add_child(akad)
	var intake_btn := Button.new()
	intake_btn.text = "Intake Akademi 14-20"
	intake_btn.pressed.connect(_on_intake)
	akad.add_child(intake_btn)
	academy_label = Label.new()
	academy_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	akad.add_child(academy_label)

	var inbox_tab := VBoxContainer.new()
	inbox_tab.name = "Inbox"
	tabs.add_child(inbox_tab)
	var titipan_btn := Button.new()
	titipan_btn.text = "Event Titipan"
	titipan_btn.pressed.connect(_on_titipan)
	inbox_tab.add_child(titipan_btn)
	inbox_label = Label.new()
	inbox_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inbox_tab.add_child(inbox_label)

	var board := VBoxContainer.new()
	board.name = "Board"
	tabs.add_child(board)
	board_label = Label.new()
	board_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	board.add_child(board_label)

func _mk_slider(parent: Control, label_text: String, val: int) -> HSlider:
	var l := Label.new()
	l.text = label_text
	parent.add_child(l)
	var s := HSlider.new()
	s.min_value = 0
	s.max_value = 100
	s.value = val
	parent.add_child(s)
	return s

func _refresh_clubs() -> void:
	club_option.clear()
	var all: Array = UKTeams.all_teams()
	for i in range(all.size()):
		var t: Dictionary = all[i]
		club_option.add_item("%s (%d)" % [str(t["name"]), int(t["ovr"])], i)
	club_option.selected = 0

func _on_start() -> void:
	var all: Array = UKTeams.all_teams()
	club = all[club_option.selected]
	UKManager.set_target(str(club["division"]), 2)
	dash_info.text = "Karir: %s | Target: %s | Conf %d" % [str(club["name"]), UKManager.target, UKManager.confidence]
	_render_squad()
	_render_board()

func _on_save_taktik() -> void:
	tactics["formation"] = str(tactic_form.get_item_text(tactic_form.selected))
	tactics["line"] = int(tactic_line.value)
	tactics["press"] = int(tactic_press.value)
	tactics["tempo"] = int(tactic_tempo.value)
	tactics["build"] = str(tactic_build.get_item_text(tactic_build.selected))
	tactics["passLen"] = str(tactic_passlen.get_item_text(tactic_passlen.selected))
	tactics["passDir"] = str(tactic_passdir.get_item_text(tactic_passdir.selected))
	tactic_info.text = "Taktik: " + UKTactics.describe_tactics(tactics)

func _on_sim() -> void:
	if club.is_empty():
		live_log.text = "Pilih klub dulu di tab Dash."
		return
	var all: Array = UKTeams.all_teams()
	var opp: Dictionary = all[randi() % all.size()]
	if str(opp["id"]) == str(club["id"]):
		opp = all[(club_option.selected + 5) % all.size()]
	var ref: Dictionary = UKManager.ref_event("sogok" if ref_bribe.button_pressed else "bersih")
	var home_team: Dictionary = {"name": str(club["name"]), "ovr": int(club["ovr"]), "staminaAvg": 75.0, "moodAvg": 70.0}
	var away_team: Dictionary = {"name": str(opp["name"]), "ovr": int(opp["ovr"]), "staminaAvg": 72.0, "moodAvg": 68.0}
	var r: Dictionary = UKEngine.sim_match(home_team, away_team, tactics, UKTactics.default_tactics(), {"refBias": str(ref["bias"])})
	var res: String = "draw"
	if int(r["hs"]) > int(r["as"]):
		res = "win"
	elif int(r["hs"]) < int(r["as"]):
		res = "lose"
	var board: String = UKManager.board_tick(res)
	var fans: String = UKManager.fan_tick(res)
	var sponsor_info: String = UKManager.sponsor_tick(res)
	var lines: Array = r["log"]
	live_log.text = "\n".join(lines) + "\nFT %s %d-%d %s\nWasit: %s\nBoard: %s | Fans: %s\nSponsor: %s\nStat: %s" % [
		str(club["name"]), int(r["hs"]), int(r["as"]), str(opp["name"]),
		str(ref["info"]), board, fans, sponsor_info, str(r["stats"]),
	]
	inbox.push_front(UKManager.rumor(str(opp["name"])))
	_render_inbox()
	_render_board()

func _on_intake() -> void:
	academy = UKManager.academy_intake()
	var rows: Array = []
	for p in academy:
		rows.append("%s%s | %dth OVR %d POT %d S%d | %s" % [_avatar(str(p["name"])), str(p["name"]), int(p["age"]), int(p["ovr"]), int(p["pot"]), int(p["stam"]), str(p["type"])])
	academy_label.text = "\n".join(rows)

func _on_titipan() -> void:
	var e: Dictionary = UKManager.titipan_event()
	inbox.push_front("TITIPAN: %s | %s" % [str(e["TITIPAN"]), str(e["efek"])])
	_render_inbox()

func _render_squad() -> void:
	if club.is_empty():
		return
	var rows: Array = []
	for i in range(11):
		var age: int = 19 + randi() % 16
		var ovr: int = maxi(UKConfig.RATING_MIN, int(club["ovr"]) - 8 + randi() % 12)
		ovr = UKManager.age_decline(age, ovr)
		rows.append("%sP%d %dth OVR %d S80 M70 puas %d" % [_avatar(str(club["name"])), i + 1, age, ovr, UKManager.satisfaction(60, 50)])
	squad_label.text = "\n".join(rows)

func _render_inbox() -> void:
	inbox_label.text = "\n---\n".join(inbox)

func _render_board() -> void:
	if club.is_empty():
		return
	board_label.text = "Target %s | Conf %d Fans %d Sponsor %d Kas %d\nStadion %s | %s" % [
		UKManager.target, UKManager.confidence, UKManager.fan_mood, UKManager.sponsor, UKManager.cash,
		str(club["stadium"]), UKManager.stadium_income(15000),
	]
