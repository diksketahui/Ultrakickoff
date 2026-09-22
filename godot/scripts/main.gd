extends Control
# Ultrakickoff Godot FRESH (portrait) — Home, Squad, Taktik drag-manual,
# Match progresif + preview visual + statistik realistis, Akademi, Inbox/Media,
# Board. SFX synth bebas komersial. Fan-made, non-afiliasi.

const FIRST_NAMES: Array = ["Raka", "Dimas", "Fajar", "Bagas", "Yoga", "Ilham", "Rizky", "Andika", "Putra", "Galih", "Bima", "Eko", "Farhan", "Hendra", "Irfan", "Joko", "Kurnia", "Lukman", "Nanda", "Panji", "Qori", "Rendra", "Samsul", "Teguh", "Utama", "Vicky", "Wahyu", "Yusuf", "Zaki", "Agus"]
const LAST_NAMES: Array = ["Pratama", "Saputra", "Wijaya", "Kusuma", "Santoso", "Nugroho", "Setiawan", "Hidayat", "Ramadhan", "Firmansyah", "Maulana", "Siregar", "Nasution", "Simbolon", "Halim", "Gunawan", "Pambudi", "Laksmana", "Maharaja", "Samudra"]
const SQUAD_POS: Array = ["GK", "DF", "DF", "DF", "DF", "MF", "MF", "MF", "MF", "FW", "FW", "FW", "GK", "DF", "DF", "MF", "MF", "FW"]
const CHANCE_LINES: Array = ["Peluang! Tendangan dari luar kotak melambung tipis.", "Umpan silang berbahaya, sundulan melebar.", "Tendangan bebas melengkung, kiper menepis!", "Serangan balik cepat, tembakan diblok bek.", "Sepak pojok, kemelut di depan gawang!", "Through ball cerdik, striker terjebak offside.", "Tembakan keras dari jarak dekat, mistar!", "Aksi individu menawan, tembakan lemah ke kiper."]
const SAVE_LINES: Array = ["Penyelamatan gemilang kiper!", "Kiper terbang menepis bola ke pojok!", "Refleks luar biasa, bola muntah disapu bek."]
const CARD_LINES: Array = ["Kartu kuning: tekel keras di tengah.", "Kartu kuning: protes ke wasit.", "Kartu kuning: diving di kotak lawan."]
const GOLD: Color = Color(0.91, 0.71, 0.30)
const INK: Color = Color(0.91, 0.94, 1.0)
const DIM: Color = Color(0.62, 0.70, 0.85)

var club: Dictionary = {}
var tactics: Dictionary = {}
var squad: Array = []
var academy: Array = []
var inbox: Array = []
var table: Array = []
var results: Array = []
var fixtures: Array = []
var fixture_idx: int = 0
var market: Array = []
var trophies: Array = []
var season_played: int = 0
var season_w: int = 0
var season_d: int = 0
var season_l: int = 0
var season_no: int = 1
var stadium_lv: int = 1
var last_result: String = "-"
var next_opp: Dictionary = {}
var inbox_seq: int = 0
var ask_action: String = ""
var ask_index: int = -1
var ff_active: bool = false

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
var poss_h: int = 0
var poss_a: int = 0
var shots_h: int = 0
var shots_a: int = 0
var match_timer: Timer
var sfx: UKSfx

var tabs: TabContainer
var status_bar: Label
var head_logo: TextureRect
var head_res: Label
var club_option: OptionButton
var dash_logo: TextureRect
var dash_club: Label
var dash_form: Label
var dash_news: Label
var dash_last: Label
var dash_next: Label
var dash_top: Label
var table_grid: GridContainer
var squad_grid: GridContainer
var squad_info: Label
var market_list: ItemList
var sale_list: ItemList
var transfer_info: Label
var trophy_row: HBoxContainer
var trophy_info: Label
var tactic_form: OptionButton
var tactic_line: HSlider
var tactic_press: HSlider
var tactic_tempo: HSlider
var tactic_build: OptionButton
var tactic_passlen: OptionButton
var tactic_passdir: OptionButton
var tactic_info: Label
var tactic_custom: Label
var pitch: FormationPitch
var preview: MatchPitch
var poss_home_rect: ColorRect
var poss_away_rect: ColorRect
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
	_push_inbox("Selamat datang di Ultrakickoff", "Pilih klub di Home lalu tekan Mulai Karir. Susun taktik (geser titik pemain!), mainkan laga menit-per-menit sambil tonton preview lapangannya.", "info", {})

func _on_btn_click() -> void:
	if sfx != null:
		sfx.play("click")

func _btn(parent: Control, text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 48)
	b.pressed.connect(_on_btn_click)
	parent.add_child(b)
	return b

func _card(parent: Control, title: String) -> VBoxContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.23)
	sb.set_corner_radius_all(14)
	sb.content_margin_left = 14.0
	sb.content_margin_right = 14.0
	sb.content_margin_top = 12.0
	sb.content_margin_bottom = 12.0
	sb.border_color = Color(0.91, 0.71, 0.30, 0.35)
	sb.set_border_width_all(1)
	p.add_theme_stylebox_override("panel", sb)
	parent.add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	p.add_child(v)
	var t := Label.new()
	t.text = title
	t.add_theme_font_size_override("font_size", 16)
	t.add_theme_color_override("font_color", GOLD)
	v.add_child(t)
	return v

func _mk_tab(tab_name: String) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.name = tab_name
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 10)
	scroll.add_child(box)
	return box

func _mk_slider(parent: Control, label_text: String, val: int) -> HSlider:
	var l := Label.new()
	l.text = label_text
	l.add_theme_color_override("font_color", DIM)
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
	l.add_theme_color_override("font_color", DIM)
	parent.add_child(l)
	var b := ProgressBar.new()
	b.min_value = 0.0
	b.max_value = 100.0
	b.value = 60.0
	b.show_percentage = true
	b.custom_minimum_size = Vector2(0, 22)
	parent.add_child(b)
	return b

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.043, 0.07, 0.125)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 6)
	add_child(root)
	var head := Label.new()
	head.text = "★ ULTRAKICKOFF"
	head.add_theme_font_size_override("font_size", 24)
	head.add_theme_color_override("font_color", GOLD)
	root.add_child(head)
	var sub := Label.new()
	sub.text = "Football Manager Liga Indonesia • portrait"
	sub.add_theme_color_override("font_color", DIM)
	root.add_child(sub)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	root.add_child(top)
	head_logo = TextureRect.new()
	head_logo.custom_minimum_size = Vector2(40, 40)
	head_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	head_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	top.add_child(head_logo)
	var topv := VBoxContainer.new()
	topv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(topv)
	status_bar = Label.new()
	status_bar.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_bar.add_theme_color_override("font_color", INK)
	topv.add_child(status_bar)
	head_res = Label.new()
	head_res.add_theme_color_override("font_color", GOLD)
	topv.add_child(head_res)
	tabs = TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(tabs)
	_build_home()
	_build_squad()
	_build_transfer()
	_build_taktik()
	_build_match()
	_build_academy()
	_build_inbox()
	_build_board()
	info_box = AcceptDialog.new()
	info_box.ok_button_text = "Tutup"
	add_child(info_box)
	ask_box = ConfirmationDialog.new()
	ask_box.ok_button_text = "Ya"
	ask_box.cancel_button_text = "Tidak"
	ask_box.confirmed.connect(_on_ask_confirmed)
	ask_box.canceled.connect(_on_ask_canceled)
	add_child(ask_box)
	sfx = UKSfx.new()
	add_child(sfx)
	match_timer = Timer.new()
	match_timer.one_shot = false
	match_timer.wait_time = 0.15
	add_child(match_timer)
	match_timer.timeout.connect(_on_match_tick)

# ---------------- HOME ----------------
func _build_home() -> void:
	var d := _mk_tab("🏠 Home")
	var c1 := _card(d, "🎬 Karir Baru")
	club_option = OptionButton.new()
	c1.add_child(club_option)
	var sb := _btn(c1, "Mulai Karir ▶")
	sb.pressed.connect(_on_start)
	var c2 := _card(d, "🏟 Klub Saya")
	dash_logo = TextureRect.new()
	dash_logo.custom_minimum_size = Vector2(72, 72)
	dash_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dash_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	c2.add_child(dash_logo)
	dash_club = Label.new()
	dash_club.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	c2.add_child(dash_club)
	dash_form = Label.new()
	dash_form.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	c2.add_child(dash_form)
	dash_top = Label.new()
	dash_top.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	c2.add_child(dash_top)
	var c3 := _card(d, "📅 Jadwal")
	dash_last = Label.new()
	dash_last.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	c3.add_child(dash_last)
	dash_next = Label.new()
	dash_next.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	c3.add_child(dash_next)
	var pb := _btn(c3, "Ke Tab Match ⚽")
	pb.pressed.connect(_on_goto_match)
	var c4 := _card(d, "📰 Kabar Terkini")
	dash_news = Label.new()
	dash_news.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	c4.add_child(dash_news)
	var c5 := _card(d, "🏆 Klasemen Mini")
	table_grid = GridContainer.new()
	table_grid.columns = 6
	c5.add_child(table_grid)

func _on_goto_match() -> void:
	tabs.current_tab = 4

# ---------------- SQUAD ----------------
func _build_squad() -> void:
	var s := _mk_tab("👥 Squad")
	var c := _card(s, "👥 Skuad Utama")
	squad_info = Label.new()
	squad_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	c.add_child(squad_info)
	squad_grid = GridContainer.new()
	squad_grid.columns = 6
	c.add_child(squad_grid)

# ---------------- TRANSFER (Rupiah) ----------------
func _build_transfer() -> void:
	var tf := _mk_tab("💸 Transfer")
	var c1 := _card(tf, "💸 Bursa Transfer (Rp)")
	transfer_info = Label.new()
	transfer_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	c1.add_child(transfer_info)
	market_list = ItemList.new()
	market_list.custom_minimum_size = Vector2(0, 200)
	c1.add_child(market_list)
	var bb := _btn(c1, "Beli Pemain Terpilih 💰")
	bb.pressed.connect(_on_buy)
	var c2 := _card(tf, "📤 Jual Pemain")
	sale_list = ItemList.new()
	sale_list.custom_minimum_size = Vector2(0, 200)
	c2.add_child(sale_list)
	var sb2 := _btn(c2, "Jual Pemain Terpilih (70%) 💵")
	sb2.pressed.connect(_on_sell)

func _gen_market() -> void:
	market.clear()
	var poses: Array = ["GK", "DF", "MF", "FW"]
	for i in range(8):
		var age: int = 18 + randi() % 15
		var ovr: int = 64 + randi() % 22
		var pot: int = mini(UKConfig.POT_MAX, ovr + randi() % 13)
		var fee: int = UKManager.transfer_fee(ovr, pot, age)
		market.append({"name": _player_name(), "pos": str(poses[randi() % poses.size()]), "age": age, "ovr": ovr, "pot": pot, "fee": fee})
	_render_market()

func _render_market() -> void:
	market_list.clear()
	sale_list.clear()
	if club.is_empty():
		transfer_info.text = "Mulai karir dulu."
		return
	transfer_info.text = "Kas: %s • Belanja bijak, Coach!" % UKManager.rupiah(float(UKManager.cash))
	for p in market:
		market_list.add_item("%s %s | %dth OVR %d POT %d | %s" % [str(p["pos"]), str(p["name"]), int(p["age"]), int(p["ovr"]), int(p["pot"]), UKManager.rupiah(float(p["fee"]))])
	for p in squad:
		var fee: int = int(float(UKManager.transfer_fee(int(p["ovr"]), int(p["ovr"]) + 3, int(p["age"]))) * 0.7)
		sale_list.add_item("%s %s | %dth OVR %d | jual %s" % [str(p["pos"]), str(p["name"]), int(p["age"]), int(p["ovr"]), UKManager.rupiah(float(fee))])

func _on_buy() -> void:
	var sel: PackedInt32Array = market_list.get_selected_items()
	if sel.is_empty():
		_show_info("Transfer", "Pilih pemain dulu.")
		return
	if squad.size() >= 25:
		_show_info("Transfer", "Skuad penuh (25). Jual dulu.")
		return
	var p: Dictionary = market[sel[0]]
	if UKManager.cash < int(p["fee"]):
		_show_info("Transfer", "Kas kurang! Butuh %s." % UKManager.rupiah(float(p["fee"])))
		return
	UKManager.cash -= int(p["fee"])
	squad.append({"name": str(p["name"]), "pos": str(p["pos"]), "age": int(p["age"]), "ovr": int(p["ovr"]), "stam": 80, "morale": 72})
	_push_inbox("✍ HERE WE GO: " + str(p["name"]), "Bang R mengonfirmasi! %s OVR %d bergabung dengan mahar %s." % [str(p["name"]), int(p["ovr"]), UKManager.rupiah(float(p["fee"]))], "rumor", {})
	market.remove_at(sel[0])
	_render_market()
	_render_squad()
	_update_status()
	sfx.play("cheer")
	_show_info("Transfer sukses", "%s resmi berseragam %s!" % [str(p["name"]), str(club["name"])])

func _on_sell() -> void:
	var sel: PackedInt32Array = sale_list.get_selected_items()
	if sel.is_empty():
		_show_info("Transfer", "Pilih pemain skuad dulu.")
		return
	if squad.size() <= 11:
		_show_info("Transfer", "Skuad minimal 11 pemain!")
		return
	var p: Dictionary = squad[sel[0]]
	var fee: int = int(float(UKManager.transfer_fee(int(p["ovr"]), int(p["ovr"]) + 3, int(p["age"]))) * 0.7)
	UKManager.cash += fee
	squad.remove_at(sel[0])
	_push_inbox("💵 Terjual: " + str(p["name"]), "%s dilepas dengan harga %s." % [str(p["name"]), UKManager.rupiah(float(fee))], "info", {})
	_render_market()
	_render_squad()
	_update_status()
	_show_info("Penjualan sukses", "%s terjual %s." % [str(p["name"]), UKManager.rupiah(float(fee))])

# ---------------- TAKTIK ----------------
func _build_taktik() -> void:
	var t := _mk_tab("📋 Taktik")
	var c1 := _card(t, "📋 Formasi (geser titik!)")
	tactic_form = OptionButton.new()
	for f in FormationPitch.formations():
		tactic_form.add_item(f)
	tactic_form.item_selected.connect(_on_formation)
	c1.add_child(tactic_form)
	pitch = FormationPitch.new()
	pitch.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pitch.positions_changed.connect(_on_positions_changed)
	c1.add_child(pitch)
	tactic_custom = Label.new()
	tactic_custom.text = "Posisi: bawaan formasi"
	tactic_custom.add_theme_color_override("font_color", DIM)
	c1.add_child(tactic_custom)
	var rb := _btn(c1, "Reset Posisi ↺")
	rb.pressed.connect(_on_reset_positions)
	var c2 := _card(t, "🎚 Instruksi Tim")
	tactic_line = _mk_slider(c2, "Garis Pertahanan", 50)
	tactic_press = _mk_slider(c2, "Pressing", 50)
	tactic_tempo = _mk_slider(c2, "Tempo", 50)
	var bl := Label.new()
	bl.text = "Build-up"
	bl.add_theme_color_override("font_color", DIM)
	c2.add_child(bl)
	tactic_build = OptionButton.new()
	for b in ["tengah", "kiri", "kanan", "campuran"]:
		tactic_build.add_item(b)
	c2.add_child(tactic_build)
	var pl := Label.new()
	pl.text = "Panjang Umpan"
	pl.add_theme_color_override("font_color", DIM)
	c2.add_child(pl)
	tactic_passlen = OptionButton.new()
	for b in ["pendek", "campuran", "panjang"]:
		tactic_passlen.add_item(b)
	tactic_passlen.selected = 1
	c2.add_child(tactic_passlen)
	var pd := Label.new()
	pd.text = "Arah Umpan"
	pd.add_theme_color_override("font_color", DIM)
	c2.add_child(pd)
	tactic_passdir = OptionButton.new()
	for b in ["maju", "kiri", "kanan", "campuran"]:
		tactic_passdir.add_item(b)
	c2.add_child(tactic_passdir)
	var sv := _btn(c2, "Simpan Taktik 💾")
	sv.pressed.connect(_on_save_taktik)
	tactic_info = Label.new()
	tactic_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	c2.add_child(tactic_info)

func _on_formation(idx: int) -> void:
	tactics["formation"] = str(tactic_form.get_item_text(idx))
	tactics.erase("custom")
	pitch.set_formation(str(tactics["formation"]))
	tactic_custom.text = "Posisi: bawaan formasi"
	_render_tactic_info()

func _on_positions_changed() -> void:
	tactics["custom"] = pitch.current_points()
	tactic_custom.text = "✅ Posisi manual tersimpan (%d titik)" % pitch.current_points().size()
	sfx.play("click")

func _on_reset_positions() -> void:
	pitch.reset_positions()
	tactics.erase("custom")
	tactic_custom.text = "Posisi: bawaan formasi"

# ---------------- MATCH ----------------
func _build_match() -> void:
	var m := _mk_tab("⚽ Match")
	var c1 := _card(m, "📺 Preview Lapangan")
	preview = MatchPitch.new()
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c1.add_child(preview)
	var c2 := _card(m, "🔴 Live Score")
	score_label = Label.new()
	score_label.text = "Laga belum dimulai"
	score_label.add_theme_font_size_override("font_size", 22)
	score_label.add_theme_color_override("font_color", GOLD)
	score_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	c2.add_child(score_label)
	minute_label = Label.new()
	c2.add_child(minute_label)
	var poss_wrap := HBoxContainer.new()
	poss_wrap.add_theme_constant_override("separation", 0)
	poss_wrap.custom_minimum_size = Vector2(0, 14)
	c2.add_child(poss_wrap)
	poss_home_rect = ColorRect.new()
	poss_home_rect.color = Color(0.25, 0.62, 1.0)
	poss_home_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	poss_home_rect.size_flags_stretch_ratio = 1.0
	poss_wrap.add_child(poss_home_rect)
	poss_away_rect = ColorRect.new()
	poss_away_rect.color = Color(0.95, 0.3, 0.3)
	poss_away_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	poss_away_rect.size_flags_stretch_ratio = 1.0
	poss_wrap.add_child(poss_away_rect)
	stat_label = Label.new()
	stat_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stat_label.add_theme_color_override("font_color", DIM)
	c2.add_child(stat_label)
	var c3 := _card(m, "🎛 Kontrol Laga")
	ref_bribe = CheckBox.new()
	ref_bribe.text = "Sogok wasit (risiko media & board!)"
	c3.add_child(ref_bribe)
	kickoff_btn = _btn(c3, "Kick-off! 🟢")
	kickoff_btn.pressed.connect(_on_kickoff)
	pause_btn = _btn(c3, "Jeda ⏸")
	pause_btn.disabled = true
	pause_btn.pressed.connect(_on_pause)
	var sl := Label.new()
	sl.text = "Kecepatan"
	sl.add_theme_color_override("font_color", DIM)
	c3.add_child(sl)
	speed_option = OptionButton.new()
	speed_option.add_item("1x Santai")
	speed_option.add_item("2x Cepat")
	speed_option.add_item("3x Kilat")
	speed_option.selected = 1
	speed_option.item_selected.connect(_on_speed)
	c3.add_child(speed_option)
	var fb := _btn(c3, "Simulasikan Sisa ⏩")
	fb.pressed.connect(_on_fast_forward)
	var c4 := _card(m, "📝 Komentar Langsung")
	live_log = TextEdit.new()
	live_log.editable = false
	live_log.custom_minimum_size = Vector2(0, 300)
	live_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	c4.add_child(live_log)

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
	var a := _mk_tab("🌱 Akademi")
	var c := _card(a, "🌱 Akademi 14-20")
	var ib := _btn(c, "Intake Akademi")
	ib.pressed.connect(_on_intake)
	academy_info = Label.new()
	academy_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	c.add_child(academy_info)
	prospect_list = ItemList.new()
	prospect_list.custom_minimum_size = Vector2(0, 220)
	c.add_child(prospect_list)
	var pr := _btn(c, "Promosikan ⬆")
	pr.pressed.connect(_on_promote)

# ---------------- INBOX ----------------
func _build_inbox() -> void:
	var ib := _mk_tab("✉ Inbox")
	var c1 := _card(ib, "✉ Pesan Masuk")
	msg_list = ItemList.new()
	msg_list.custom_minimum_size = Vector2(0, 220)
	c1.add_child(msg_list)
	var ob := _btn(c1, "Buka Pesan ✉")
	ob.pressed.connect(_on_open_message)
	var c2 := _card(ib, "🎙 Konferensi Pers")
	var tl := Label.new()
	tl.text = "Gaya bicara"
	tl.add_theme_color_override("font_color", DIM)
	c2.add_child(tl)
	press_tone = OptionButton.new()
	press_tone.add_item("sombong")
	press_tone.add_item("rendah hati")
	press_tone.add_item("aman")
	press_tone.selected = 2
	c2.add_child(press_tone)
	var pj := _btn(c2, "Jawab Media 🎙")
	pj.pressed.connect(_on_press)
	var c3 := _card(ib, "⚖ Titipan")
	var te := _btn(c3, "Event Titipan ⚖")
	te.pressed.connect(_on_titipan)

# ---------------- BOARD ----------------
func _build_board() -> void:
	var b := _mk_tab("🏛 Board")
	var c1 := _card(b, "🏛 Dewan & Kepercayaan")
	conf_bar = _mk_bar(c1, "Kepercayaan Board")
	fans_bar = _mk_bar(c1, "Mood Fans")
	sponsor_bar = _mk_bar(c1, "Sponsor")
	board_info = Label.new()
	board_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	c1.add_child(board_info)
	var c2 := _card(b, "💼 Keuangan & Stadion")
	var ic := _btn(c2, "Cairkan Stadion 🏟")
	ic.pressed.connect(_on_income)
	var up := _btn(c2, "Upgrade Stadion 🏗")
	up.pressed.connect(_on_upgrade_stadium)
	var fd := _btn(c2, "Minta Dana 💰")
	fd.pressed.connect(_on_funds)
	var c3 := _card(b, "🏆 Lemari Trofi")
	trophy_row = HBoxContainer.new()
	trophy_row.add_theme_constant_override("separation", 10)
	c3.add_child(trophy_row)
	trophy_info = Label.new()
	trophy_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	c3.add_child(trophy_info)

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
	fixtures.clear()
	for t in table:
		if not bool(t["mine"]):
			fixtures.append(t)
	fixture_idx = 0
	_pick_next_fixture()

func _pick_next_fixture() -> void:
	if fixture_idx >= 0 and fixture_idx < fixtures.size():
		next_opp = fixtures[fixture_idx]
	else:
		next_opp = {}

func _on_start() -> void:
	var all: Array = UKTeams.all_teams()
	club = all[club_option.selected]
	UKManager.confidence = 60
	UKManager.fan_mood = 65
	UKManager.sponsor = 100
	UKManager.cash = 8000
	UKManager.scandal = 0
	UKManager.set_target(str(club["division"]), 2)
	season_played = 0
	season_w = 0
	season_d = 0
	season_l = 0
	season_no = 1
	stadium_lv = 1
	results.clear()
	trophies.clear()
	last_result = "-"
	_gen_squad(int(club["ovr"]))
	_build_table()
	_gen_market()
	var logo: Texture2D = load("res://assets/logos/" + str(club["id"]) + ".svg") as Texture2D
	if logo != null:
		dash_logo.texture = logo
	match_active = false
	match_timer.stop()
	pause_btn.disabled = true
	sfx.play("whistle")
	_push_inbox("Kontrak: " + str(club["name"]), "Board menetapkan target " + UKManager.target + ". Stadion: " + str(club["stadium"]) + ". Buktikan dalam 6 pekan mini-liga!", "board", {})
	_render_all()
	_show_info("Karir dimulai", "Selamat, Coach! Kamu menukangi " + str(club["name"]) + ".\nTarget: " + UKManager.target + "\nSkuad: " + str(squad.size()) + " pemain.")
	_update_status()

func _update_status() -> void:
	if club.is_empty():
		status_bar.text = "Belum ada karir. Pilih klub di Home."
		head_res.text = ""
	else:
		status_bar.text = "%s • Musim %d Pekan %d • %d pts (%dM %dS %dK)" % [str(club["name"]), season_no, season_played + 1, season_w * 3 + season_d, season_w, season_d, season_l]
		head_res.text = "💰 %s   🛡 Conf %d   😍 Fans %d" % [UKManager.rupiah(float(UKManager.cash)), UKManager.confidence, UKManager.fan_mood]
		var logo: Texture2D = load("res://assets/logos/" + str(club["id"]) + ".svg") as Texture2D
		if logo != null:
			head_logo.texture = logo

func _form_str() -> String:
	if results.is_empty():
		return "-"
	var out: Array = []
	var start: int = maxi(0, results.size() - 5)
	for i in range(start, results.size()):
		out.append(str(results[i]))
	return " ".join(out)

# ---------------- RENDER ----------------
func _render_all() -> void:
	_render_dashboard()
	_render_squad()
	_render_market()
	if not club.is_empty() and pitch != null:
		pitch.set_lineup(_home_xi_names())
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
		dash_club.text = "Pilih klub lalu tekan Mulai Karir."
		dash_form.text = ""
		dash_top.text = ""
		dash_last.text = ""
		dash_next.text = "Laga berikut: -"
		dash_news.text = "Selamat datang di Ultrakickoff!"
		for c in table_grid.get_children():
			c.queue_free()
		return
	var avg: Dictionary = _squad_avg()
	dash_club.text = "🏟 %s (%s)\n⭐ OVR %d • Skuad %.1f • Target: %s\n📊 %d pts • %d laga (M%d S%d K%d)" % [str(club["name"]), str(club["stadium"]), int(club["ovr"]), float(avg["ovr"]), UKManager.target, season_w * 3 + season_d, season_played, season_w, season_d, season_l]
	dash_form.text = "Form (5 laga): " + _form_str()
	var ranked: Array = squad.duplicate()
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["ovr"]) > int(b["ovr"]))
	var tops: Array = []
	for i in range(mini(3, ranked.size())):
		tops.append("%s %d" % [str(ranked[i]["name"]), int(ranked[i]["ovr"])])
	dash_top.text = "🌟 Bintang: " + " • ".join(tops)
	dash_last.text = "Terakhir: " + last_result
	if next_opp.is_empty():
		dash_next.text = "Berikut: -"
	else:
		dash_next.text = "Berikut: vs " + str(next_opp["name"])
	if inbox.is_empty():
		dash_news.text = "Belum ada kabar."
	else:
		dash_news.text = "📰 " + str(inbox[0]["title"])
	for c in table_grid.get_children():
		c.queue_free()
	for h in ["#", "Tim", "M", "SG", "Pts", ""]:
		var hl := Label.new()
		hl.text = h
		hl.add_theme_color_override("font_color", GOLD)
		table_grid.add_child(hl)
	var pos: int = 1
	for t in _sorted_table():
		var gd: int = int(t["gf"]) - int(t["ga"])
		var gd_txt: String = ("+" if gd >= 0 else "") + str(gd)
		var mark: String = "◀" if bool(t["mine"]) else ""
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
	squad_info.text = "OVR %.1f • Stamina %.0f • Moril %.0f • %d pemain" % [float(avg["ovr"]), float(avg["stam"]), float(avg["morale"]), squad.size()]
	for h in ["Pemain", "Pos", "Um", "OVR", "Sta", "Mor"]:
		var hl := Label.new()
		hl.text = h
		hl.add_theme_color_override("font_color", GOLD)
		squad_grid.add_child(hl)
	for p in squad:
		var cell := HBoxContainer.new()
		cell.add_theme_constant_override("separation", 4)
		var face := FaceAvatar.new()
		face.face_size = 30.0
		face.player_name = str(p["name"])
		cell.add_child(face)
		var nm := Label.new()
		nm.text = str(p["name"])
		cell.add_child(nm)
		squad_grid.add_child(cell)
		for base in [str(p["pos"]), str(p["age"])]:
			var bl := Label.new()
			bl.text = base
			squad_grid.add_child(bl)
		squad_grid.add_child(_attr_cell(int(p["ovr"]), Color(0.91, 0.71, 0.30)))
		squad_grid.add_child(_attr_cell(int(p["stam"]), Color(0.25, 0.75, 0.35)))
		squad_grid.add_child(_attr_cell(int(p["morale"]), Color(0.25, 0.55, 0.95)))

func _attr_cell(val: int, color: Color) -> VBoxContainer:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 1)
	var lb := Label.new()
	lb.text = str(val)
	vb.add_child(lb)
	var bar := ProgressBar.new()
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.value = float(val)
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(56, 8)
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("fill", sb)
	vb.add_child(bar)
	return vb

func _render_tactic_info() -> void:
	tactic_info.text = "Taktik: " + UKTactics.describe_tactics(tactics)

func _on_save_taktik() -> void:
	var f: String = str(tactic_form.get_item_text(tactic_form.selected))
	var keep: Array = pitch.current_points()
	var same: bool = f == str(tactics.get("formation", ""))
	tactics["formation"] = f
	tactics["line"] = int(tactic_line.value)
	tactics["press"] = int(tactic_press.value)
	tactics["tempo"] = int(tactic_tempo.value)
	tactics["build"] = str(tactic_build.get_item_text(tactic_build.selected))
	tactics["passLen"] = str(tactic_passlen.get_item_text(tactic_passlen.selected))
	tactics["passDir"] = str(tactic_passdir.get_item_text(tactic_passdir.selected))
	pitch.set_formation(f)
	if same and keep.size() == 11:
		pitch.custom = keep
		pitch.queue_redraw()
		tactics["custom"] = pitch.current_points()
		tactic_custom.text = "✅ Posisi manual tersimpan (%d titik)" % pitch.current_points().size()
	else:
		tactics.erase("custom")
		tactic_custom.text = "Posisi: bawaan formasi"
	_render_tactic_info()
	_show_info("Taktik tersimpan", UKTactics.describe_tactics(tactics))

# ---------------- MATCH PROGRESIF + PREVIEW ----------------
func _opp_ovr(label: String) -> int:
	for t in UKTeams.all_teams():
		if str(t["name"]) == label:
			return int(t["ovr"])
	return 72

func _home_xi_names() -> Array:
	var out: Array = []
	for i in range(mini(11, squad.size())):
		out.append(str(squad[i]["name"]))
	return out

func _gen_away_xi(seed_key: String) -> Array:
	var rng := RandomNumberGenerator.new()
	var sd: int = 0
	for c in seed_key:
		sd = (sd * 37 + c.unicode_at(0)) % 2147483647
	rng.seed = sd + 1
	var out: Array = []
	for i in range(11):
		out.append(str(FIRST_NAMES[rng.randi() % FIRST_NAMES.size()]) + " " + str(LAST_NAMES[rng.randi() % LAST_NAMES.size()]))
	return out

func _on_kickoff() -> void:
	if club.is_empty():
		_show_info("Belum ada karir", "Pilih klub dan tekan Mulai Karir di Home.")
		return
	if match_active:
		_show_info("Laga berjalan", "Selesaikan atau fast-forward laga ini.")
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
	poss_h = 0
	poss_a = 0
	shots_h = 0
	shots_a = 0
	match_lines = ["KO! " + str(match_home["name"]) + " vs " + str(match_away["name"]), "Wasit: " + str(ref["info"])]
	preview.setup(_home_xi_names(), _gen_away_xi(str(match_opp.get("id", "x"))))
	preview.on_minute(true)
	match_active = true
	match_paused = false
	ff_active = false
	pause_btn.disabled = false
	pause_btn.text = "Jeda ⏸"
	sfx.play("whistle")
	sfx.crowd_start()
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
	match_home["staminaAvg"] = float(match_home["staminaAvg"]) - 0.06
	match_away["staminaAvg"] = float(match_away["staminaAvg"]) - 0.06
	var share: float = clampf(0.5 + (float(match_home["ovr"]) - float(match_away["ovr"])) * 0.02, 0.32, 0.68)
	var poss_home: bool = randf() < share
	if poss_home:
		poss_h += 1
	else:
		poss_a += 1
	preview.on_minute(poss_home)
	var g: String = UKEngine.sim_minute(match_home, match_away, tactics, UKTactics.default_tactics(), {"home": true, "refBias": match_ref_bias, "parkBus": ""})
	if g == "home":
		match_hs += 1
		shots_h += 1
		match_lines.append("%d' ⚽ GOOOL! %s (%d-%d)" % [match_minute, str(match_home["name"]), match_hs, match_as])
		preview.on_event("home_goal")
		sfx.play("cheer")
	elif g == "away":
		match_as += 1
		shots_a += 1
		match_lines.append("%d' ⚽ Gol %s (%d-%d)" % [match_minute, str(match_away["name"]), match_hs, match_as])
		preview.on_event("away_goal")
		sfx.play("boo")
	else:
		var r: float = randf()
		if r < 0.07:
			shots_h += 1
			match_lines.append("%d' 🥅 %s" % [match_minute, str(SAVE_LINES[randi() % SAVE_LINES.size()])])
			preview.on_event("chance_h")
			sfx.play("ooh")
		elif r < 0.13:
			shots_a += 1
			match_lines.append("%d' %s" % [match_minute, str(CHANCE_LINES[randi() % CHANCE_LINES.size()])])
			preview.on_event("chance_a")
		elif r < 0.15:
			match_lines.append("%d' %s" % [match_minute, str(CARD_LINES[randi() % CARD_LINES.size()])])
	if match_minute == 45:
		match_lines.append("---- HT: %s %d-%d %s ----" % [str(match_home["name"]), match_hs, match_as, str(match_away["name"])])
		sfx.play("ht")
		if not ff_active:
			match_paused = true
			match_timer.stop()
			pause_btn.text = "Lanjut ▶"
			_ask("☕ Jeda Babak Pertama", "Skor %d-%d.\nPidato apa untuk ruang ganti?\n\nMotivasi = moril +4 babak kedua.\nSantai = moril +1." % [match_hs, match_as], "teamtalk", -1, "Motivasi! 🔥", "Santai")
	if match_lines.size() > 200:
		match_lines = match_lines.slice(match_lines.size() - 200)

func _poss_str() -> String:
	var tot: int = poss_h + poss_a
	if tot == 0:
		return "50-50"
	return "%d-%d" % [int(round(100.0 * float(poss_h) / float(tot))), int(round(100.0 * float(poss_a) / float(tot)))]

func _refresh_match_ui() -> void:
	if match_home.is_empty():
		score_label.text = "Laga belum dimulai"
		minute_label.text = "Menit 0'"
		return
	score_label.text = "%s  %d - %d  %s" % [str(match_home["name"]), match_hs, match_as, str(match_away["name"])]
	var tag: String = "🔴 LIVE" if match_active else "FT"
	minute_label.text = "%s • Menit %d'" % [tag, match_minute]
	poss_home_rect.size_flags_stretch_ratio = float(maxi(poss_h, 1))
	poss_away_rect.size_flags_stretch_ratio = float(maxi(poss_a, 1))
	var out: Array = []
	for l in match_lines:
		out.append(str(l))
	live_log.text = "\n".join(out)
	stat_label.text = "🥅 Tembakan %d-%d • ⚖ Possession %s • Taktik: %s" % [shots_h, shots_a, _poss_str(), UKTactics.describe_tactics(tactics)]

func _on_fast_forward() -> void:
	if not match_active:
		return
	if ask_box.visible and ask_action == "teamtalk":
		ask_box.hide()
		ask_action = ""
		match_paused = false
	ff_active = true
	while match_minute < 90:
		_advance_minute()
	ff_active = false
	_refresh_match_ui()
	_finish_match()

func _table_add_result(label: String, gf: int, ga: int) -> void:
	for t in table:
		if str(t["name"]) == label:
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
	sfx.crowd_stop()
	sfx.play("ft")
	match_lines.append("==== FT: %s %d-%d %s ====" % [str(match_home["name"]), match_hs, match_as, str(match_away["name"])])
	var res: String = "draw"
	var code: String = "D"
	if match_hs > match_as:
		res = "win"
		code = "W"
		sfx.play("cheer")
		sfx.play("applause")
	elif match_hs < match_as:
		res = "lose"
		code = "L"
	season_played += 1
	if res == "win":
		season_w += 1
	elif res == "draw":
		season_d += 1
	else:
		season_l += 1
	results.append(code)
	last_result = "%s %d-%d %s" % [str(match_home["name"]), match_hs, match_as, str(match_away["name"])]
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
	fixture_idx += 1
	_pick_next_fixture()
	_refresh_match_ui()
	_render_all()
	if fixture_idx >= fixtures.size():
		_finish_season()
		return
	_show_info("🏁 Laga selesai", "%s\n🥅 Tembakan %d-%d • Possession %s\n\nBoard: %s\nFans: %s\n%s" % [last_result, shots_h, shots_a, _poss_str(), board_msg, fans_msg, sponsor_msg])

func _reset_table_stats() -> void:
	for t in table:
		t["played"] = 0
		t["w"] = 0
		t["d"] = 0
		t["l"] = 0
		t["gf"] = 0
		t["ga"] = 0
		t["pts"] = 0

func _finish_season() -> void:
	var order: Array = _sorted_table()
	var champ: Dictionary = order[0]
	var my_pos: int = 0
	for i in range(order.size()):
		if bool(order[i]["mine"]):
			my_pos = i + 1
	var prize: int = 0
	var headline: String = ""
	if my_pos == 1:
		prize = 5000
		trophies.append({"icon": "piala_liga", "name": "Juara Liga (Musim %d)" % season_no})
		headline = "🏆 JUARA! %s menjuarai mini-liga musim %d!" % [str(club["name"]), season_no]
		sfx.play("cheer")
		sfx.play("applause")
	elif my_pos <= 3:
		prize = 1500
		headline = "Peringkat %d. Hampir juara, coba lagi musim depan!" % my_pos
	else:
		headline = "Peringkat %d. Board kecewa, bangkit musim depan!" % my_pos
		UKManager.confidence = clampi(UKManager.confidence - 5, 0, 100)
	UKManager.cash += prize
	var ranked: Array = squad.duplicate()
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["ovr"]) > int(b["ovr"]))
	var mvp: String = str(ranked[0]["name"]) if not ranked.is_empty() else "-"
	trophies.append({"icon": "pemain_terbaik", "name": "MVP %s (Musim %d)" % [mvp, season_no]})
	var boot_name: String = _player_name()
	var boot_goals: int = 6 + randi() % 5
	var glove_team: String = str(champ["name"])
	_push_inbox("🏁 " + headline, "Juara: %s\nHadiah: %s\n\n🥇 MVP: %s\n👟 Sepatu Emas: %s (%d gol)\n🧤 Sarung Emas: kiper %s" % [str(champ["name"]), UKManager.rupiah(float(prize)), mvp, boot_name, boot_goals, glove_team], "board", {})
	season_no += 1
	season_played = 0
	season_w = 0
	season_d = 0
	season_l = 0
	results.clear()
	_reset_table_stats()
	fixture_idx = 0
	_pick_next_fixture()
	_gen_market()
	_render_all()
	_show_info("🏁 Musim selesai", "%s\n\nJuara: %s\nHadiah: %s\n🥇 MVP: %s\n👟 Top skor: %s (%d gol)\n🧤 Kiper terbaik: %s\n\nMusim baru dimulai!" % [headline, str(champ["name"]), UKManager.rupiah(float(prize)), mvp, boot_name, boot_goals, glove_team])

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
		_ask("⚖ Keputusan Titipan", str(m["title"]) + "\n\n" + str(m["body"]) + "\n\nTerima = kas +Rp800 jt, fans -5.\nTolak = confidence -6.", "titipan", sel[0], "Terima", "Tolak")
	else:
		_show_info(str(m["title"]), str(m["body"]))

func _on_ask_confirmed() -> void:
	if ask_action == "titipan" and ask_index >= 0 and ask_index < inbox.size():
		UKManager.cash += 800
		UKManager.fan_mood = clampi(UKManager.fan_mood - 5, 0, 100)
		inbox[ask_index]["title"] = "[DITERIMA] " + str(inbox[ask_index]["title"])
		_render_inbox_list()
		_render_board()
		_update_status()
		_show_info("Titipan diterima", "Kas +Rp800 jt. Fans -5 jika pemain tampil jelek.")
	elif ask_action == "teamtalk":
		match_home["moodAvg"] = float(match_home["moodAvg"]) + 4.0
		match_lines.append("45' 🔥 Pidato motivasi! Ruang ganti membara.")
		_resume_after_talk()
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
	elif ask_action == "teamtalk":
		match_home["moodAvg"] = float(match_home["moodAvg"]) + 1.0
		match_lines.append("45' 😌 Tetap tenang. Fokus babak kedua.")
		_resume_after_talk()
	ask_action = ""
	ask_index = -1

func _resume_after_talk() -> void:
	_refresh_match_ui()
	if match_active:
		match_paused = false
		pause_btn.text = "Jeda ⏸"
		match_timer.start()

func _on_titipan() -> void:
	if club.is_empty():
		_show_info("Belum ada karir", "Mulai karir dulu.")
		return
	var e: Dictionary = UKManager.titipan_event()
	_push_inbox("TITIPAN: " + str(e["TITIPAN"]), str(e["efek"]), "titipan", {})
	_show_info("Titipan masuk", "Buka Inbox dan putuskan: Terima atau Tolak.")

func _on_press() -> void:
	if club.is_empty():
		_show_info("Belum ada karir", "Mulai karir dulu.")
		return
	var tone: String = str(press_tone.get_item_text(press_tone.selected))
	var questions: Array = ["Target musim ini, Coach?", "Kabar ruang ganti memanas, benar?", "Kenapa striker utama mandul gol?", "Fans menuntut trofi. Komentar?", "Apakah taktikmu terlalu bertahan?"]
	var q: String = str(questions[randi() % questions.size()])
	var effect: String = UKManager.press("sombong" if tone == "sombong" else ("rendah" if tone == "rendah hati" else "aman"))
	_push_inbox("Pers: " + q, "Gaya: " + tone + ". Respon: " + effect, "press", {})
	_render_board()
	_update_status()
	sfx.play("click")
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
	academy_info.text = "Intake %d pemain • POT tertinggi %d • Pilih lalu promosikan (maks 25)." % [academy.size(), best]
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
	board_info.text = "Target: %s\nKas: %s • Sponsor: %d\nStadion %s (Lv %d)" % [UKManager.target, UKManager.rupiah(float(UKManager.cash)), UKManager.sponsor, str(club["stadium"]), stadium_lv]
	_render_trophies()

func _render_trophies() -> void:
	for c in trophy_row.get_children():
		c.queue_free()
	if trophies.is_empty():
		trophy_info.text = "Belum ada trofi. Juarai liga untuk mengisi lemari ini!"
		return
	trophy_info.text = "%d trofi & penghargaan:" % trophies.size()
	for tr in trophies:
		var vb := VBoxContainer.new()
		var im := TextureRect.new()
		im.custom_minimum_size = Vector2(64, 64)
		im.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		im.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var tex: Texture2D = load("res://assets/trophies/" + str(tr["icon"]) + ".svg") as Texture2D
		if tex != null:
			im.texture = tex
		vb.add_child(im)
		var lb := Label.new()
		lb.text = str(tr["name"])
		lb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lb.custom_minimum_size = Vector2(90, 0)
		vb.add_child(lb)
		trophy_row.add_child(vb)

func _on_income() -> void:
	if club.is_empty():
		return
	var att: int = 12000 + stadium_lv * 3000
	var msg: String = UKManager.stadium_income(att)
	_render_board()
	_update_status()
	_show_info("🏟 Pemasukan stadion", "Penonton %d (Lv %d)\n%s" % [att, stadium_lv, msg])

func _on_upgrade_stadium() -> void:
	if club.is_empty():
		return
	var cost: int = stadium_lv * 1500
	if UKManager.cash < cost:
		_show_info("🏗 Upgrade stadion", "Butuh %s untuk Lv %d." % [UKManager.rupiah(float(cost)), stadium_lv + 1])
		return
	UKManager.cash -= cost
	stadium_lv += 1
	UKManager.fan_mood = clampi(UKManager.fan_mood + 4, 0, 100)
	_render_board()
	_update_status()
	sfx.play("applause")
	_show_info("🏗 Stadion naik Lv %d!" % stadium_lv, "Kapasitas & pemasukan bertambah. Fans +4.")

func _on_funds() -> void:
	if club.is_empty():
		return
	if UKManager.confidence >= 50:
		UKManager.cash += 2000
		_push_inbox("Board menyetujui dana", "Proposal meyakinkan. Kas +Rp2,0 M.", "board", {})
		_show_info("💰 Dana disetujui", "Board menggelontorkan kas +Rp2,0 M.")
	else:
		UKManager.confidence = clampi(UKManager.confidence - 3, 0, 100)
		_push_inbox("Board menolak dana", "Kepercayaan rendah. Proposal ditolak.", "board", {})
		_show_info("💰 Dana ditolak", "Board tidak percaya padamu. Confidence -3.")
	_render_board()
	_update_status()
