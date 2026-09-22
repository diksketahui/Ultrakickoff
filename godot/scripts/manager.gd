class_name UKManager
extends RefCounted

static var confidence: int = 60
static var fan_mood: int = 65
static var sponsor: int = 100
# Kas dalam JUTA Rupiah (8000 = Rp8,0 M). Transfer realistis ala Liga Indonesia.
static var cash: int = 8000
static var scandal: int = 0
static var target: String = "-"

static func rupiah(jt: float) -> String:
	if jt >= 1000.0:
		var s: String = "%.1f" % (jt / 1000.0)
		return "Rp" + s.replace(".", ",") + " M"
	return "Rp%d jt" % int(jt)

static func transfer_fee(ovr: int, pot: int, age: int) -> int:
	var fee: int = (ovr - 58) * (ovr - 58) * 6 + maxi(0, pot - ovr) * 40 + maxi(0, 21 - age) * 30
	return maxi(150, fee)

static func set_target(division: String, idx: int = 2) -> String:
	var list: Array = UKConfig.CLUB_TARGETS_SUPER if division == "super" else UKConfig.CLUB_TARGETS_CHAMP
	var i: int = clampi(idx, 0, list.size() - 1)
	target = str(list[i])
	return target

static func board_tick(res: String) -> String:
	if res == "win":
		confidence += 4
	elif res == "draw":
		confidence -= 1
	elif res == "lose":
		confidence -= 5
	if scandal > 0:
		confidence -= 6
		scandal -= 1
	confidence = clampi(confidence, 0, 100)
	if confidence < 15:
		return "PECAT: board vote out"
	if confidence < 25:
		return "peringatan keras terakhir"
	return "aman (%d)" % confidence

static func sponsor_tick(res: String) -> String:
	if res == "win":
		sponsor = mini(120, sponsor + 2)
	elif res == "lose":
		sponsor = maxi(0, sponsor - 4)
	if res == "win":
		cash += 350
	elif res == "draw":
		cash += 120
	else:
		cash -= 80
	return "sponsor %d | kas %s" % [sponsor, rupiah(float(cash))]

static func fan_tick(res: String, derby: bool = false) -> String:
	if res == "win":
		fan_mood += 8 if derby else 4
	elif res == "lose":
		fan_mood -= 9 if derby else 5
	fan_mood = clampi(fan_mood, 0, 100)
	if fan_mood < 20:
		return "ANCAMAN: boikot kandang + teror inbox + tuntut mundur"
	if fan_mood < 30:
		return "protes: spanduk + boikot + ancaman"
	if fan_mood < 50:
		return "siul + desak ganti taktik"
	return "dukungan penuh"

static func stadium_income(att: int) -> String:
	var inc: int = int(round(float(att) * 0.05))
	cash += inc
	return "tiket +%s | merch +%s" % [rupiah(float(inc)), rupiah(float(inc) * 0.4)]

static func academy_intake() -> Array:
	var names: Array = ["Raka", "Dimas", "Fajar", "Bagas", "Yoga", "Ilham", "Rizky", "Andika", "Putra", "Galih", "Bima", "Eko"]
	var out: Array = []
	for i in range(6):
		var age: int = 14 + randi() % 5
		var ovr: int = clampi(45 + randi() % 20, UKConfig.RATING_MIN, 90)
		var pot: int = clampi(ovr + 5 + randi() % 20, UKConfig.RATING_MIN, UKConfig.POT_MAX)
		var r: float = randf()
		var ptype: String = "murni"
		if r < 0.12:
			ptype = "anak legenda"
		elif r < 0.20:
			ptype = "titipan sponsor"
		elif r < 0.26:
			ptype = "anak artis"
		out.append({
			"name": "%s U%d" % [names[randi() % names.size()], age],
			"age": age, "ovr": ovr, "pot": pot,
			"stam": 80 + randi() % 15, "mood": 65 + randi() % 15,
			"type": ptype,
		})
	return out

static func age_decline(age: int, ovr: int) -> int:
	if age < 21:
		return ovr + 2
	if age <= 30:
		return ovr
	if age <= 33:
		return ovr - 1
	return ovr - 3

static func satisfaction(minutes: int, target_minutes: int) -> int:
	return clampi(60 + int((float(minutes) - float(target_minutes)) * 0.5), 0, 100)

static func titipan_event() -> Dictionary:
	var t: Array = ["anak legenda minta debut 3 laga", "anak sponsor wajib main 5 laga", "anak artis minta nomor 10"]
	var p: String = str(t[randi() % t.size()])
	return {"TITIPAN": p, "efek": "Terima: kas +Rp800 jt, fans -5 jika jelek. Tolak: confidence -6, ruang ganti +5."}

static func ref_event(choice: String) -> Dictionary:
	if choice == "sogok":
		if randf() < 0.35:
			scandal = 3
			confidence = maxi(0, confidence - 20)
			sponsor = maxi(0, sponsor - 15)
			return {"bias": "", "scandal": true, "info": "MEDIA UNGKAP: skandal suap! Board -20, sponsor tahan dana, diselidiki 3 laga."}
		return {"bias": "home", "scandal": false, "info": "Wasit condong tuan rumah (risiko diedus media)."}
	return {"bias": "", "scandal": false, "info": "Main bersih."}

static func rumor(other: String) -> String:
	var l: float = randf()
	if l < 0.5:
		return "SAMAR: %s dikaitkan pindah..." % other
	if l < 0.85:
		return "Bang R: negosiasi %s tahap akhir." % other
	return "Bang R HERE WE GO! %s deal, tinggal medis." % other

static func press(choice: String) -> String:
	if choice == "sombong":
		fan_mood = clampi(fan_mood + 3, 0, 100)
		confidence = clampi(confidence - 2, 0, 100)
		return "Fans suka, board tidak suka."
	if choice == "rendah":
		confidence = clampi(confidence + 3, 0, 100)
		return "Board suka."
	fan_mood = clampi(fan_mood + 1, 0, 100)
	confidence = clampi(confidence + 1, 0, 100)
	return "Aman."
