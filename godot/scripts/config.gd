class_name UKConfig
extends RefCounted

const RATING_MIN: int = 30
const RATING_MAX: int = 90
const POT_MAX: int = 94
const SAVE_KEY: String = "ultrakickoff_v01"

const COMPETITIONS: Dictionary = {
	"ligaSuper": {"name": "Liga Super", "teams": 18, "rounds": 34, "relegated": 3, "promoted": 0},
	"championship": {"name": "Championship", "teams": 20, "groups": 2, "promoted": 3, "relegated": 3},
	"pialaPresiden": {"name": "Piala Presiden", "teams": 8, "groups": 2, "knockout": true},
}

const CLUB_TARGETS_SUPER: Array = ["Juara", "Asia (3 besar)", "10 besar", "Hindari degradasi"]
const CLUB_TARGETS_CHAMP: Array = ["Juara+promosi", "Playoff promosi", "Papan tengah", "Hindari degradasi"]
