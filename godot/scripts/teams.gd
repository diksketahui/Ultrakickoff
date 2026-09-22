class_name UKTeams
extends RefCounted

# Nama klub asli (faktual 2025/26), rating estimasi sendiri (fan-made).
static func liga_super() -> Array:
	return [
		{"id": "S0", "name": "Persib Bandung", "ovr": 82, "stadium": "GBLA", "division": "super"},
		{"id": "S1", "name": "Persija Jakarta", "ovr": 80, "stadium": "JIS", "division": "super"},
		{"id": "S2", "name": "Persebaya Surabaya", "ovr": 80, "stadium": "GBT", "division": "super"},
		{"id": "S3", "name": "Borneo Samarinda", "ovr": 81, "stadium": "Segiri", "division": "super"},
		{"id": "S4", "name": "Bali United", "ovr": 79, "stadium": "Dipta", "division": "super"},
		{"id": "S5", "name": "Dewa United Banten", "ovr": 80, "stadium": "Banten Intl", "division": "super"},
		{"id": "S6", "name": "PSM Makassar", "ovr": 78, "stadium": "BJ Habibie", "division": "super"},
		{"id": "S7", "name": "Arema FC", "ovr": 78, "stadium": "Kanjuruhan", "division": "super"},
		{"id": "S8", "name": "PSIM Yogyakarta", "ovr": 76, "stadium": "Sultan Agung", "division": "super"},
		{"id": "S9", "name": "Persijap Jepara", "ovr": 74, "stadium": "Bumi Kartini", "division": "super"},
		{"id": "S10", "name": "Bhayangkara Lampung", "ovr": 75, "stadium": "Sumpah Pemuda", "division": "super"},
		{"id": "S11", "name": "Persita Tangerang", "ovr": 75, "stadium": "Indomilk", "division": "super"},
		{"id": "S12", "name": "Persik Kediri", "ovr": 75, "stadium": "Brawijaya", "division": "super"},
		{"id": "S13", "name": "Madura United", "ovr": 74, "stadium": "Ratu Pamelingan", "division": "super"},
		{"id": "S14", "name": "Malut United", "ovr": 76, "stadium": "Kie Raha", "division": "super"},
		{"id": "S15", "name": "Persis Solo", "ovr": 74, "stadium": "Manahan", "division": "super"},
		{"id": "S16", "name": "PSBS Biak", "ovr": 72, "stadium": "Maguwoharjo", "division": "super"},
		{"id": "S17", "name": "Semen Padang", "ovr": 72, "stadium": "H Agus Salim", "division": "super"},
	]

static func championship() -> Array:
	var names: Array = [
		"PSS Sleman", "Barito Putera", "PSIS Semarang", "Persipura Jayapura",
		"Adhyaksa Banten", "Garudayaksa FC", "Sumsel United", "Bekasi City",
		"Persiraja Banda Aceh", "PSMS Medan", "Persikad Depok", "PSPS Pekanbaru",
		"Persekat Tegal", "Sriwijaya FC", "Persela Lamongan", "Deltras Sidoarjo",
		"Persiku Kudus", "Persiba Balikpapan", "Persipal Palu", "Kendal Tornado",
	]
	var out: Array = []
	for i in range(names.size()):
		var ovr: int = 62 + ((i * 7) % 12)
		out.append({"id": "C%d" % i, "name": names[i], "ovr": ovr, "stadium": "%s Stadium" % names[i], "division": "champ"})
	return out

static func all_teams() -> Array:
	var all: Array = liga_super()
	all.append_array(championship())
	return all

static func find_by_id(team_id: String) -> Dictionary:
	for t in all_teams():
		if t["id"] == team_id:
			return t
	return {}
