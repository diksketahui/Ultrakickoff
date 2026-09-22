extends Control
# Ultrakickoff Godot — Football Manager ala FM: dashboard, squad, taktik visual,
# match progresif menit-per-menit, akademi, inbox/media dialog, board.
# Fan-made, non-afiliasi.

const FIRST_NAMES: Array = ["Raka", "Dimas", "Fajar", "Bagas", "Yoga", "Ilham", "Rizky", "Andika", "Putra", "Galih", "Bima", "Eko", "Farhan", "Hendra", "Irfan", "Joko", "Kurnia", "Lukman", "Nanda", "Panji", "Qori", "Rendra", "Samsul", "Teguh", "Utama", "Vicky", "Wahyu", "Yusuf", "Zaki", "Agus"]
const LAST_NAMES: Array = ["Pratama", "Saputra", "Wijaya", "Kusuma", "Santoso", "Nugroho", "Setiawan", "Hidayat", "Ramadhan", "Firmansyah", "Maulana", "Siregar", "Nasution", "Simbolon", "Halim", "Gunawan", "Pambudi", "Laksmana", "Maharaja", "Samudra"]
const SQUAD_POS: Array = ["GK", "DF", "DF", "DF", "DF", "MF", "MF", "MF", "MF", "FW", "FW", "FW", "GK", "DF", "DF", "MF", "MF", "FW"]
const CHANCE_LINES: Array = ["Peluang! Tendangan dari luar kotak melambung tipis.", "Umpan silang berbahaya, sundulan melebar.", "Tendangan bebas melengkung, kiper menepis!", "Serangan balik cepat, tembakan diblok bek.", "Sepak pojok, kemelut di depan gawang!", "Through ball cerdik, striker terjebak offside.", "Tembakan keras dari jarak dekat, mistar!", "Aksi individu menawan, tembakan lemah ke kiper."]
const CARD_LINES: Array = ["Kartu kuning: tekel keras di tengah lapangan.", "Kartu kuning: protes berlebihan ke wasit.", "Kartu kuning: diving di kotak penalti lawan."]

var club: Dictionary = {}
var tactics: Dictionary = {}
var squad: Array = []
var academy: Array = []
var inbox: Array = []
var table: Array = []
var season_played: int = 0
var season_w: int = 0
var season_d: int = 0
var season_l: int = 0
var last_result: String = "-"
var next_opp: Dictionary = {}
var inbox_seq: int = 0
var ask_action: String = ""
var ask_index: int = -1

# match progresif
var match_active: bool = false
var match_paused: bool = false
var match_minute: int = 0
var match_hs: int = 0
var match_as: int = 0
var match_home: Dictionary = {}
var match_away: Dictionary = {}
var match_opp: Dictionary = {}
var match_ref_bias: String = ""
var match_lines: Array = []
var match_timer: Timer

var tabs: TabContainer
var status_bar: Label
var club_option: OptionButton
var dash_cards: Label
var dash_last: Label
var dash_next: Label
var table_grid: GridContainer
var squad_grid: GridContainer
var squad_info: Label
var tactic_form: OptionButton
var tactic_line: HSlider
var tactic_press: HSlider
var tactic_tempo: HSlider
var tactic_build: OptionButton
var tactic_passlen: OptionButton
var tactic_passdir: OptionButton
var tactic_info: Label
var pitch: FormationPitch
var score_label: Label
var minute_label: Label
var stat_label: Label
var live_log: TextEdit
var ref_bribe: CheckBox
var kickoff_btn: Button
var pause_btn: Button
var speed_option: OptionButton
var prospect_list: ItemList
var academy_info: Label
var msg_list: ItemList
var press_tone: OptionButton
var conf_bar: ProgressBar
var fans_bar: ProgressBar
var sponsor_bar: ProgressBar
var board_info: Label
var info_box: AcceptDialog
var ask_box: ConfirmationDialog

func _ready() -> void:
	randomize()
	tactics = UKTactics.default_tactics()
	_build_ui()
	_refresh_clubs()
	_push_inbox("Selamat datang di Ultrakickoff", "Pilih klub di Dashboard lalu tekan Mulai Karir. Atur taktik di tab Taktik, mainkan laga di tab Match. Pantau Board, Fans, dan Sponsor.", "info", {})

func _avatar(n: String) -> String:
	var s: String = ""
	for w in str(n).split(" "):
		if str(w).length() > 0:
			s += str(w).left(1)
	return "[" + s.left(2).to_upper() + "]"

func _mk_tab(tab_name: String) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.name = tab_name
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 8)
	scroll.add_child(box)
	return box

func _mk_slider(parent: Control, label_text: String, val: int) -> HSlider:
	var l := Label.new()
	l.text = label_text
	parent.add_child(l)
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 100.0
	s.step = 1.0
	s.value = float(val)
	parent.add_child(s)
	return s

func _mk_bar(parent: Control, label_text: String) -> ProgressBar:
	var l := Label.new()
	l.text = label_text
	parent.add_child(l)
	var b := ProgressBar.new()
	b.min_value = 0.0
	b.max_value = 100.0
	b.value = 60.0
	b.show_percentage = true
	b.custom_minimum_size = Vector2(0, 22)
	parent.add_child(b)
	return b

func _section(parent: Control, title: String) -> Label:
	var l := Label.new()
	l.text = title
	l.add_theme_font_size_override("font_size", 17)
	parent.add_child(l)
	return l

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 6)
	add_child(root)
	var head := Label.new()
	head.text = "ULTRAKICKOFF — Football Manager Liga Indonesia"
	head.add_theme_font_size_override("font_size", 20)
	root.add_child(head)
	status_bar = Label.new()
	status_bar.text = "Belum ada karir. Pilih klub di Dashboard."
	root.add_child(status_bar)
	tabs = TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(tabs)
	_build_dash()
	_build_squad()
	_build_taktik()
	_build_match()
	_build_academy()
	_build_inbox()
	_build_board()
	info_box = AcceptDialog.new()
	info_box.ok_button_text = "Tutup"
	add_child(info_box)
	ask_box = ConfirmationDialog.new()
	ask_box.ok_button_text = "Terima"
	ask_box.cancel_button_text = "Tolak"
	ask_box.confirmed.connect(_on_ask_confirmed)
	ask_box.canceled.connect(_on_ask_canceled)
	add_child(ask_box)
	match_timer = Timer.new()
	match_timer.one_shot = false
	match_timer.wait_time = 0.15
	add_child(match_timer)
	match_timer.timeout.connect(_on_match_tick)

# ---------------- DASHBOARD ----------------
func _build_dash() -> void:
	var d := _mk_tab("Dashboard")
	_section(d, "Karir Baru")
	club_option = OptionButton.new()
	d.add_child(club_option)
	var start_btn := Button.new()
	start_btn.text = "Mulai Karir"
	start_btn.pressed.connect(_on_start)
	d.add_child(start_btn)
	_section(d, "Ruang Ganti")
	dash_cards = Label.new()
	dash_cards.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.add_child(dash_cards)
	dash_last = Label.new()
	dash_last.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.add_child(dash_last)
	dash_next = Label.new()
	dash_next.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.add_child(dash_next)
	var play_btn := Button.new()
	play_btn.text = "Ke Tab Match ▶"
	play_btn.pressed.connect(_on_goto_match)
	d.add_child(play_btn)
	_section(d, "Klasemen Mini")
	table_grid = GridContainer.new()
	table_grid.columns = 6
	d.add_child(table_grid)

func _on_goto_match() -> void:
	tabs.current_tab = 3

# ---------------- SQUAD ----------------
func _build_squad() -> void:
	var s := _mk_tab("Squad")
	_section(s, "Skuad Utama (18 pemain)")
	squad_info = Label.new()
	squad_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	s.add_child(squad_info)
	squad_grid = GridContainer.new()
	squad_grid.columns = 6
	s.add_child(squad_grid)

# ---------------- TAKTIK ----------------
func _build_taktik() -> void:
	var t := _mk_tab("Taktik")
	_section(t, "Formasi + Visual Lapangan")
	tactic_form = OptionButton.new()
	for f in FormationPitch.formations():
		tactic_form.add_item(f)
	tactic_form.item_selected.connect(_on_formation)
	t.add_child(tactic_form)
	pitch = FormationPitch.new()
	pitch.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.add_child(pitch)
	tactic_line = _mk_slider(t, "Garis Pertahanan", 50)
	tactic_press = _mk_slider(t, "Pressing", 50)
	tactic_tempo = _mk_slider(t, "Tempo", 50)
	var bl := Label.new()
	bl.text = "Build-up"
	t.add_child(bl)
	tactic_build = OptionButton.new()
	for b in ["tengah", "kiri", "kanan", "campuran"]:
		tactic_build.add_item(b)
	t.add_child(tactic_build)
	var pl := Label.new()
	pl.text = "Panjang Umpan"
	t.add_child(pl)
	tactic_passlen = OptionButton.new()
	for b in ["pendek", "campuran", "panjang"]:
		tactic_passlen.add_item(b)
	tactic_passlen.selected = 1
	t.add_child(tactic_passlen)
	var pd := Label.new()
	pd.text = "Arah Umpan"
	t.add_child(pd)
	tactic_passdir = OptionButton.new()
	for b in ["maju", "kiri", "kanan", "campuran"]:
		tactic_passdir.add_item(b)
	t.add_child(tactic_passdir)
	var save_btn := Button.new()
	save_btn.text = "Simpan Taktik"
	save_btn.pressed.connect(_on_save_taktik)
	t.add_child(save_btn)
	tactic_info = Label.new()
	tactic_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t.add_child(tactic_info)

func _on_formation(idx: int) -> void:
	tactics["formation"] = str(tactic_form.get_item_text(idx))
	pitch.set_formation(str(tactics["formation"]))
	_render_tactic_info()

# ---------------- MATCH ----------------
func _build_match() -> void:
	var m := _mk_tab("Match")
	_section(m, "Laga Progresif (menit per menit)")
	score_label = Label.new()
	score_label.text = "Laga belum dimulai"
	score_label.add_theme_font_size_override("font_size", 22)
	score_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	m.add_child(score_label)
	minute_label = Label.new()
	minute_label.text = "Menit 0'"
	m.add_child(minute_label)
	stat_label = Label.new()
	stat_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	m.add_child(stat_label)
	ref_bribe = CheckBox.new()
	ref_bribe.text = "Sogok wasit (risiko media & board!)"
	m.add_child(ref_bribe)
	kickoff_btn = Button.new()
	kickoff_btn.text = "Kick-off!"
	kickoff_btn.pressed.connect(_on_kickoff)
	m.add_child(kickoff_btn)
	pause_btn = Button.new()
	pause_btn.text = "Jeda / Lanjut"
	pause_btn.disabled = true
	pause_btn.pressed.connect(_on_pause)
	m.add_child(pause_btn)
	var sl := Label.new()
	sl.text = "Kecepatan simulasi"
	m.add_child(sl)
	speed_option = OptionButton.new()
	speed_option.add_item("1x Santai")
	speed_option.add_item("2x Cepat")
	speed_option.add_item("3x Kilat")
	speed_option.item_selected.connect(_on_speed)
	m.add_child(speed_option)
	var fast_btn := Button.new()
	fast_btn.text = "Simulasikan Sisa Laga ⏩"
	fast_btn.pressed.connect(_on_fast_forward)
	m.add_child(fast_btn)
	live_log = TextEdit.new()
	live_log.editable = false
	live_log.custom_minimum_size = Vector2(0, 320)
	live_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	m.add_child(live_log)

func _on_speed(idx: int) -> void:
	if idx == 0:
		match_timer.wait_time = 0.3
	elif idx == 1:
		match_timer.wait_time = 0.12
	else:
		match_timer.wait_time = 0.05
	if match_active and not match_paused:
		match_timer.start()

# ---------------- AKADEMI ----------------
func _build_academy() -> void:
	var a := _mk_tab("Akademi")
	_section(a, "Akademi Usia 14-20")
	var intake_btn := Button.new()
	intake_btn.text = "Intake Akademi"
	intake_btn.pressed.connect(_on_intake)
	a.add_child(intake_btn)
	academy_info = Label.new()
	academy_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	a.add_child(academy_info)
	prospect_list = ItemList.new()
	prospect_list.custom_minimum_size = Vector2(0, 220)
	a.add_child(prospect_list)
	var promote_btn := Button.new()
	promote_btn.text = "Promosikan ke Skuad Utama ⬆"
	promote_btn.pressed.connect(_on_promote)
	a.add_child(promote_btn)

# ---------------- INBOX / MEDIA ----------------
func _build_inbox() -> void:
	var ib := _mk_tab("Inbox")
	_section(ib, "Pesan Masuk, Media & Bang R")
	msg_list = ItemList.new()
	msg_list.custom_minimum_size = Vector2(0, 220)
	ib.add_child(msg_list)
	var open_btn := Button.new()
	open_btn.text = "Buka Pesan Terpilih ✉"
	open_btn.pressed.connect(_on_open_message)
	ib.add_child(open_btn)
	_section(ib, "Konferensi Pers")
	var tl := Label.new()
	tl.text = "Gaya bicara"
	ib.add_child(tl)
	press_tone = OptionButton.new()
	press_tone.add_item("sombong")
	press_tone.add_item("rendah hati")
	press_tone.add_item("aman")
	press_tone.selected = 2
	ib.add_child(press_tone)
	var press_btn := Button.new()
	press_btn.text = "Jawab Media 🎙"
	press_btn.pressed.connect(_on_press)
	ib.add_child(press_btn)
	var titipan_btn := Button.new()
	titipan_btn.text = "Event Titipan (keputusan sulit!) ⚖"
	titipan_btn.pressed.connect(_on_titipan)
	ib.add_child(titipan_btn)

# ---------------- BOARD ----------------
func _build_board() -> void:
	var b := _mk_tab("Board")
	_section(b, "Dewan, Sponsor & Fans")
	conf_bar = _mk_bar(b, "Kepercayaan Board")
	fans_bar = _mk_bar(b, "Mood Fans")
	sponsor_bar = _mk_bar(b, "Sponsor")
	board_info = Label.new()
	board_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.add_child(board_info)
	var income_btn := Button.new()
	income_btn.text = "Cairkan Pemasukan Stadion 🏟"
	income_btn.pressed.connect(_on_income)
	b.add_child(income_btn)
	var funds_btn := Button.new()
	funds_btn.text = "Minta Dana ke Board 💰"
	funds_btn.pressed.connect(_on_funds)
	b.add_child(funds_btn)

# ---------------- KARIR ----------------
func _refresh_clubs() -> void:
	club_option.clear()
	var all: Array = UKTeams.all_teams()
	for i in range(all.size()):
		var t: Dictionary = all[i]
		club_option.add_item("%s (%d)" % [str(t["name"]), int(t["ovr"])], i)
	club_option.selected = 0

func _player_name() -> String:
	return str(FIRST_NAMES[randi() % FIRST_NAMES.size()]) + " " + str(LAST_NAMES[randi() % LAST_NAMES.size()])

func _gen_squad(base_ovr: int) -> void:
	squad.clear()
	for i in range(SQUAD_POS.size()):
		var age: int = 18 + randi() % 18
		var ovr: int = clampi(base_ovr - 10 + randi() % 15, UKConfig.RATING_MIN, UKConfig.RATING_MAX)
		ovr = UKManager.age_decline(age, ovr)
		squad.append({"name": _player_name(), "pos": str(SQUAD_POS[i]), "age": age, "ovr": ovr, "stam": 78 + randi() % 20, "morale": 62 + randi() % 25})

func _squad_avg() -> Dictionary:
	if squad.is_empty():
		return {"ovr": 70.0, "stam": 75.0, "morale": 68.0}
	var so: float = 0.0
	var st: float = 0.0
	var mo: float = 0.0
	for p in squad:
		so += float(p["ovr"])
		st += float(p["stam"])
		mo += float(p["morale"])
	var n: float = float(squad.size())
	return {"ovr": so / n, "stam": st / n, "morale": mo / n}

func _build_table() -> void:
	table.clear()
	table.append({"id": str(club["id"]), "name": str(club["name"]), "played": 0, "w": 0, "d": 0, "l": 0, "gf": 0, "ga": 0, "pts": 0, "mine": true})
	var pool: Array = UKTeams.all_teams()
	var added: int = 0
	var k: int = club_option.selected + 1
	while added < 5:
		var cand: Dictionary = pool[k % pool.size()]
		if str(cand["id"]) != str(club["id"]):
			table.append({"id": str(cand["id"]), "name": str(cand["name"]), "played": 0, "w": 0, "d": 0, "l": 0, "gf": 0, "ga": 0, "pts": 0, "mine": false})
			added += 1
		k += 1
	_pick_next_fixture()

func _pick_next_fixture() -> void:
	var rivals: Array = []
	for t in table:
		if not bool(t["mine"]):
			rivals.append(t)
	if rivals.is_empty():
		next_opp = {}
	else:
		next_opp = rivals[randi() % rivals.size()]

func _on_start() -> void:
	var all: Array = UKTeams.all_teams()
	club = all[club_option.selected]
	UKManager.confidence = 60
	UKManager.fan_mood = 65
	UKManager.sponsor = 100
	UKManager.cash = 50
	UKManager.scandal = 0
	UKManager.set_target(str(club["division"]), 2)
	season_played = 0
	season_w = 0
	season_d = 0
	season_l = 0
	last_result = "-"
	_gen_squad(int(club["ovr"]))
	_build_table()
	match_active = false
	match_timer.stop()
	pause_btn.disabled = true
	_push_inbox("Kontrak: " + str(club["name"]), "Board menetapkan target " + UKManager.target + ". Stadion: " + str(club["stadium"]) + ". Buktikan di 6 pekan mini-liga ini!", "board", {})
	_render_all()
	_show_info("Karir dimulai", "Selamat, Coach! Kamu menukangi " + str(club["name"]) + ".\nTarget board: " + UKManager.target + "\nSkuad: " + str(squad.size()) + " pemain.")
	_update_status()

func _update_status() -> void:
	if club.is_empty():
		status_bar.text = "Belum ada karir. Pilih klub di Dashboard."
	else:
		status_bar.text = "%s | Pekan %d | %d pts (%dM %dS %dK) | Conf %d Fans %d Kas %d" % [str(club["name"]), season_played + 1, season_w * 3 + season_d, season_w, season_d, season_l, UKManager.confidence, UKManager.fan_mood, UKManager.cash]

# ---------------- RENDER ----------------
func _render_all() -> void:
	_render_dashboard()
	_render_squad()
	_render_tactic_info()
	_render_academy_list()
	_render_inbox_list()
	_render_board()
	_update_status()

func _sorted_table() -> Array:
	var arr: Array = table.duplicate()
	arr.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a["pts"]) != int(b["pts"]):
			return int(a["pts"]) > int(b["pts"])
		var gda: int = int(a["gf"]) - int(a["ga"])
		var gdb: int = int(b["gf"]) - int(b["ga"])
		if gda != gdb:
			return gda > gdb
		return int(a["gf"]) > int(b["gf"]))
	return arr

func _render_dashboard() -> void:
	if club.is_empty():
		dash_cards.text = "Pilih klub lalu tekan Mulai Karir."
		dash_last.text = ""
		dash_next.text = ""
		for c in table_grid.get_children():
			c.queue_free()
		return
	var avg: Dictionary = _squad_avg()
	dash_cards.text = "🏟 %s (%s)\n⭐ OVR %d | Skuad OVR %.1f | Target: %s\n📊 %d pts dari %d laga (M%d S%d K%d)" % [str(club["name"]), str(club["stadium"]), int(club["ovr"]), float(avg["ovr"]), UKManager.target, season_w * 3 + season_d, season_played, season_w, season_d, season_l]
	dash_last.text = "Laga terakhir: " + last_result
	if next_opp.is_empty():
		dash_next.text = "Laga berikut: -"
	else:
		dash_next.text = "Laga berikut: vs " + str(next_opp["name"])
	for c in table_grid.get_children():
		c.queue_free()
	for h in ["#", "Tim", "M", "SG", "Poin", "★"]:
		var hl := Label.new()
		hl.text = h
		table_grid.add_child(hl)
	var pos: int = 1
	for t in _sorted_table():
		var gd: int = int(t["gf"]) - int(t["ga"])
		var gd_txt: String = ("+" if gd >= 0 else "") + str(gd)
		var mark: String = "◀ KAMU" if bool(t["mine"]) else ""
		for cell in [str(pos), str(t["name"]), str(t["played"]), gd_txt, str(t["pts"]), mark]:
			var cl := Label.new()
			cl.text = cell
			table_grid.add_child(cl)
		pos += 1

func _render_squad() -> void:
	for c in squad_grid.get_children():
		c.queue_free()
	if squad.is_empty():
		squad_info.text = "Skuad kosong. Mulai karir dulu."
		return
	var avg: Dictionary = _squad_avg()
	squad_info.text = "Rata-rata OVR %.1f | Stamina %.0f | Moril %.0f" % [float(avg["ovr"]), float(avg["stam"]), float(avg["morale"])]
	for h in ["Pemain", "Pos", "Umur", "OVR", "Sta", "Mor"]:
		var hl := Label.new()
		hl.text = h
		squad_grid.add_child(hl)
	for p in squad:
		for cell in [str(p["name"]), str(p["pos"]), str(p["age"]), str(p["ovr"]), str(p["stam"]), str(p["morale"])]:
			var cl := Label.new()
			cl.text = cell
			squad_grid.add_child(cl)

func _render_tactic_info() -> void:
	tactic_info.text = "Taktik: " + UKTactics.describe_tactics(tactics)

func _on_save_taktik() -> void:
	tactics["formation"] = str(tactic_form.get_item_text(tactic_form.selected))
	tactics["line"] = int(tactic_line.value)
	tactics["press"] = int(tactic_press.value)
	tactics["tempo"] = int(tactic_tempo.value)
	tactics["build"] = str(tactic_build.get_item_text(tactic_build.selected))
	tactics["passLen"] = str(tactic_passlen.get_item_text(tactic_passlen.selected))
	tactics["passDir"] = str(tactic_passdir.get_item_text(tactic_passdir.selected))
	pitch.set_formation(str(tactics["formation"]))
	_render_tactic_info()
	_show_info("Taktik tersimpan", UKTactics.describe_tactics(tactics))

# ---------------- MATCH PROGRESIF ----------------
func _opp_ovr(name: String) -> int:
	for t in UKTeams.all_teams():
		if str(t["name"]) == name:
			return int(t["ovr"])
	return 72

func _on_kickoff() -> void:
	if club.is_empty():
		_show_info("Belum ada karir", "Pilih klub dan tekan Mulai Karir di Dashboard.")
		return
	if match_active:
		_show_info("Laga berjalan", "Selesaikan atau fast-forward laga yang sedang berjalan.")
		return
	if next_opp.is_empty():
		_pick_next_fixture()
	match_opp = next_opp
	var avg: Dictionary = _squad_avg()
	match_home = {"name": str(club["name"]), "ovr": float(avg["ovr"]), "staminaAvg": float(avg["stam"]), "moodAvg": float(avg["morale"])}
	match_away = {"name": str(match_opp["name"]), "ovr": float(_opp_ovr(str(match_opp["name"]))), "staminaAvg": 72.0, "moodAvg": 68.0}
	var ref: Dictionary = UKManager.ref_event("sogok" if ref_bribe.button_pressed else "bersih")
	match_ref_bias = str(ref["bias"])
	match_minute = 0
	match_hs = 0
	match_as = 0
	match_lines = ["KO! " + str(match_home["name"]) + " vs " + str(match_away["name"]), "Wasit: " + str(ref["info"])]
	match_active = true
	match_paused = false
	pause_btn.disabled = false
	pause_btn.text = "Jeda ⏸"
	match_timer.start()
	_refresh_match_ui()

func _on_pause() -> void:
	if not match_active:
		return
	match_paused = not match_paused
	if match_paused:
		match_timer.stop()
		pause_btn.text = "Lanjut ▶"
	else:
		match_timer.start()
		pause_btn.text = "Jeda ⏸"

func _on_match_tick() -> void:
	if not match_active or match_paused:
		return
	_advance_minute()
	_refresh_match_ui()
	if match_minute >= 90:
		_finish_match()

func _advance_minute() -> void:
	match_minute += 1
	var g: String = UKEngine.sim_minute(match_home, match_away, tactics, UKTactics.default_tactics(), {"home": true, "refBias": match_ref_bias, "parkBus": ""})
	if g == "home":
		match_hs += 1
		match_lines.append("%d' ⚽ GOOOL! %s (%d-%d)" % [match_minute, str(match_home["name"]), match_hs, match_as])
	elif g == "away":
		match_as += 1
		match_lines.append("%d' ⚽ Gol %s (%d-%d)" % [match_minute, str(match_away["name"]), match_hs, match_as])
	else:
		var r: float = randf()
		if r < 0.10:
			match_lines.append("%d' %s" % [match_minute, str(CHANCE_LINES[randi() % CHANCE_LINES.size()])])
		elif r < 0.125:
			match_lines.append("%d' %s" % [match_minute, str(CARD_LINES[randi() % CARD_LINES.size()])])
	if match_minute == 45:
		match_lines.append("---- HT: %s %d-%d %s ----" % [str(match_home["name"]), match_hs, match_as, str(match_away["name"])])
	if match_lines.size() > 200:
		match_lines = match_lines.slice(match_lines.size() - 200)

func _refresh_match_ui() -> void:
	if match_home.is_empty():
		score_label.text = "Laga belum dimulai"
		minute_label.text = "Menit 0'"
		return
	score_label.text = "%s  %d - %d  %s" % [str(match_home["name"]), match_hs, match_as, str(match_away["name"])]
	var tag: String = "LIVE 🔴" if match_active else "FT"
	minute_label.text = "%s Menit %d'" % [tag, match_minute]
	var out: Array = []
	for l in match_lines:
		out.append(str(l))
	live_log.text = "\n".join(out)
	stat_label.text = "Taktik: " + UKTactics.describe_tactics(tactics)

func _on_fast_forward() -> void:
	if not match_active:
		return
	while match_minute < 90:
		_advance_minute()
	_refresh_match_ui()
	_finish_match()

func _table_add_result(name: String, gf: int, ga: int) -> void:
	for t in table:
		if str(t["name"]) == name:
			t["played"] = int(t["played"]) + 1
			t["gf"] = int(t["gf"]) + gf
			t["ga"] = int(t["ga"]) + ga
			if gf > ga:
				t["w"] = int(t["w"]) + 1
				t["pts"] = int(t["pts"]) + 3
			elif gf == ga:
				t["d"] = int(t["d"]) + 1
				t["pts"] = int(t["pts"]) + 1
			else:
				t["l"] = int(t["l"]) + 1
			return

func _sim_other_fixtures() -> void:
	var rivals: Array = []
	for t in table:
		if str(t["name"]) != str(match_home["name"]) and str(t["name"]) != str(match_away["name"]):
			rivals.append(t)
	var i: int = 0
	while i + 1 < rivals.size():
		var a: int = randi() % 4
		var b: int = randi() % 4
		_table_add_result(str(rivals[i]["name"]), a, b)
		_table_add_result(str(rivals[i + 1]["name"]), b, a)
		i += 2

func _finish_match() -> void:
	match_active = false
	match_timer.stop()
	pause_btn.disabled = true
	match_lines.append("==== FT: %s %d-%d %s ====" % [str(match_home["name"]), match_hs, match_as, str(match_away["name"])])
	var res: String = "draw"
	if match_hs > match_as:
		res = "win"
	elif match_hs < match_as:
		res = "lose"
	season_played += 1
	if res == "win":
		season_w += 1
	elif res == "draw":
		season_d += 1
	else:
		season_l += 1
	last_result = "%s %d-%d %s (%s)" % [str(match_home["name"]), match_hs, match_as, str(match_away["name"]), res.to_upper()]
	_table_add_result(str(match_home["name"]), match_hs, match_as)
	_table_add_result(str(match_away["name"]), match_as, match_hs)
	_sim_other_fixtures()
	for p in squad:
		p["stam"] = clampi(int(p["stam"]) - 3 + randi() % 5, 40, 99)
		if res == "win":
			p["morale"] = clampi(int(p["morale"]) + 3, 0, 99)
		elif res == "lose":
			p["morale"] = clampi(int(p["morale"]) - 4, 0, 99)
	var board_msg: String = UKManager.board_tick(res)
	var fans_msg: String = UKManager.fan_tick(res)
	var sponsor_msg: String = UKManager.sponsor_tick(res)
	_push_inbox("Hasil: " + last_result, "Board: " + board_msg + "\nFans: " + fans_msg + "\n" + sponsor_msg, "result", {})
	_push_inbox(UKManager.rumor(str(match_away["name"])), "Kabar transfer dari Bang R.", "rumor", {})
	_pick_next_fixture()
	_refresh_match_ui()
	_render_all()
	_show_info("Laga selesai", "%s\n\nBoard: %s\nFans: %s\n%s" % [last_result, board_msg, fans_msg, sponsor_msg])

# ---------------- INBOX / MEDIA ----------------
func _push_inbox(title: String, body: String, kind: String, data: Dictionary) -> void:
	inbox_seq += 1
	inbox.push_front({"id": inbox_seq, "title": title, "body": body, "kind": kind, "data": data})
	_render_inbox_list()

func _render_inbox_list() -> void:
	msg_list.clear()
	for m in inbox:
		var tag: String = "💬"
		if str(m["kind"]) == "titipan":
			tag = "⚖"
		elif str(m["kind"]) == "result":
			tag = "📋"
		elif str(m["kind"]) == "board":
			tag = "🏛"
		elif str(m["kind"]) == "rumor":
			tag = "🔥"
		msg_list.add_item("%s %s" % [tag, str(m["title"])])

func _show_info(title: String, text: String) -> void:
	info_box.title = title
	info_box.dialog_text = text
	info_box.popup_centered()

func _ask(title: String, text: String, action: String, idx: int, ok_text: String, cancel_text: String) -> void:
	ask_action = action
	ask_index = idx
	ask_box.title = title
	ask_box.dialog_text = text
	ask_box.ok_button_text = ok_text
	ask_box.cancel_button_text = cancel_text
	ask_box.popup_centered()

func _on_open_message() -> void:
	var sel: PackedInt32Array = msg_list.get_selected_items()
	if sel.is_empty():
		_show_info("Inbox", "Pilih pesan dulu.")
		return
	var m: Dictionary = inbox[sel[0]]
	if str(m["kind"]) == "titipan":
		_ask("Keputusan Titipan", str(m["title"]) + "\n\n" + str(m["body"]) + "\n\nTerima = kas +8, fans -5. Tolak = confidence -6, ruang ganti +5.", "titipan", sel[0], "Terima", "Tolak")
	else:
		_show_info(str(m["title"]), str(m["body"]))

func _on_ask_confirmed() -> void:
	if ask_action == "titipan" and ask_index >= 0 and ask_index < inbox.size():
		UKManager.cash += 8
		UKManager.fan_mood = clampi(UKManager.fan_mood - 5, 0, 100)
		inbox[ask_index]["title"] = "[DITERIMA] " + str(inbox[ask_index]["title"])
		_render_inbox_list()
		_render_board()
		_update_status()
		_show_info("Titipan diterima", "Kas +8. Fans -5 jika pemain tampil jelek.")
	ask_action = ""
	ask_index = -1

func _on_ask_canceled() -> void:
	if ask_action == "titipan" and ask_index >= 0 and ask_index < inbox.size():
		UKManager.confidence = clampi(UKManager.confidence - 6, 0, 100)
		inbox[ask_index]["title"] = "[DITOLAK] " + str(inbox[ask_index]["title"])
		_render_inbox_list()
		_render_board()
		_update_status()
		_show_info("Titipan ditolak", "Confidence -6. Ruang ganti +5.")
	ask_action = ""
	ask_index = -1

func _on_titipan() -> void:
	if club.is_empty():
		_show_info("Belum ada karir", "Mulai karir dulu.")
		return
	var e: Dictionary = UKManager.titipan_event()
	_push_inbox("TITIPAN: " + str(e["TITIPAN"]), str(e["efek"]), "titipan", {})
	_show_info("Titipan masuk", "Pesan titipan masuk ke Inbox. Buka dan putuskan: Terima atau Tolak.")

func _on_press() -> void:
	if club.is_empty():
		_show_info("Belum ada karir", "Mulai karir dulu.")
		return
	var tone: String = str(press_tone.get_item_text(press_tone.selected))
	var questions: Array = ["Target musim ini, Coach?", "Kabar ruang ganti memanas, benar?", "Kenapa striker utama mandul gol?", "Fans menuntut trofi. Komentar?"]
	var q: String = str(questions[randi() % questions.size()])
	var effect: String = UKManager.press("sombong" if tone == "sombong" else ("rendah" if tone == "rendah hati" else "aman"))
	_push_inbox("Pers: " + q, "Gaya: " + tone + ". Respon: " + effect, "press", {})
	_render_board()
	_update_status()
	_show_info("🎙 Konferensi Pers", "Wartawan: \"" + q + "\"\n\nGaya: " + tone + "\nHasil: " + effect)

# ---------------- AKADEMI ----------------
func _on_intake() -> void:
	academy = UKManager.academy_intake()
	_render_academy_list()

func _render_academy_list() -> void:
	prospect_list.clear()
	if academy.is_empty():
		academy_info.text = "Belum ada intake. Tekan Intake Akademi."
		return
	var best: int = 0
	for p in academy:
		best = maxi(best, int(p["pot"]))
	academy_info.text = "Intake %d pemain. POT tertinggi %d. Pilih lalu promosikan (maks 25 skuad)." % [academy.size(), best]
	for p in academy:
		prospect_list.add_item("%s | %dth OVR %d POT %d | %s" % [str(p["name"]), int(p["age"]), int(p["ovr"]), int(p["pot"]), str(p["type"])])

func _on_promote() -> void:
	var sel: PackedInt32Array = prospect_list.get_selected_items()
	if sel.is_empty():
		_show_info("Akademi", "Pilih pemain dulu.")
		return
	if squad.size() >= 25:
		_show_info("Akademi", "Skuad penuh (25).")
		return
	var p: Dictionary = academy[sel[0]]
	squad.append({"name": str(p["name"]), "pos": "MF", "age": int(p["age"]), "ovr": int(p["ovr"]), "stam": int(p["stam"]), "morale": 70})
	academy.remove_at(sel[0])
	_push_inbox("Promosi: " + str(p["name"]), "Wonderkid OVR " + str(p["ovr"]) + " POT " + str(p["pot"]) + " naik ke tim utama.", "info", {})
	_render_academy_list()
	_render_squad()
	_update_status()

# ---------------- BOARD ----------------
func _render_board() -> void:
	if club.is_empty():
		board_info.text = "Mulai karir dulu."
		return
	conf_bar.value = float(UKManager.confidence)
	fans_bar.value = float(UKManager.fan_mood)
	sponsor_bar.value = float(mini(UKManager.sponsor, 100))
	board_info.text = "Target: %s\nKas: %d | Sponsor: %d\nStadion %s" % [UKManager.target, UKManager.cash, UKManager.sponsor, str(club["stadium"])]

func _on_income() -> void:
	if club.is_empty():
		return
	var msg: String = UKManager.stadium_income(15000)
	_render_board()
	_update_status()
	_show_info("🏟 Pemasukan stadion", msg)

func _on_funds() -> void:
	if club.is_empty():
		return
	if UKManager.confidence >= 50:
		UKManager.cash += 10
		_push_inbox("Board menyetujui dana +10", "Proposal meyakinkan. Kas bertambah.", "board", {})
		_show_info("💰 Dana disetujui", "Board menggelontorkan kas +10.")
	else:
		UKManager.confidence = clampi(UKManager.confidence - 3, 0, 100)
		_push_inbox("Board menolak dana", "Kepercayaan rendah. Proposal ditolak.", "board", {})
		_show_info("💰 Dana ditolak", "Board tidak percaya padamu. Confidence -3.")
	_render_board()
	_update_status()
