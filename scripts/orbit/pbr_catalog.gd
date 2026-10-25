class_name OrbitPlanetCatalog
extends RefCounted

## Chart coordinates deliberately favor readable routes over astronomical scale.
const SUN_POSITION := Vector2(-1300.0, -80.0)
const CHART_SIZE := Vector2(2400.0, 1400.0)
const START_ID := "ember"

static func planets() -> Array[Dictionary]:
	return [
		_planet("ember", "EMBER", "Rocky world", "bd7765", "f9ad82", Vector2(430, 730), 34.0, 2, false, 0, ["dune", "pelagos"]),
		_planet("dune", "DUNE", "Desert world", "c5a163", "f5df9f", Vector2(650, 400), 41.0, 3, false, 1, ["viridia"]),
		_planet("pelagos", "PELAGOS", "Ocean world", "3b97bf", "9ae2ed", Vector2(660, 1060), 44.0, 4, false, 1, ["viridia"]),
		_planet("viridia", "VIRIDIA", "Terrestrial world", "638c75", "b8d3a2", Vector2(940, 715), 49.0, 3, false, 2, ["vesper", "cobalt"]),
		_planet("vesper", "VESPER", "Volcanic world", "8e4b54", "ffac69", Vector2(1180, 330), 46.0, 6, false, 3, ["jovian"]),
		_planet("cobalt", "COBALT", "Storm world", "557aa4", "c7e3ee", Vector2(1190, 1070), 50.0, 5, false, 3, ["jovian"]),
		_planet("jovian", "JOVIAN", "Gas giant", "c39b7c", "e7ceac", Vector2(1440, 710), 70.0, 18, false, 4, ["boreas", "aurora"]),
		_planet("boreas", "BOREAS", "Ice giant", "5a9eaa", "bbf2ea", Vector2(1640, 280), 62.0, 12, true, 5, ["chronos"]),
		_planet("aurora", "AURORA", "Frozen world", "a3bcca", "edf5f5", Vector2(1670, 1140), 47.0, 9, false, 5, ["chronos"]),
		_planet("chronos", "CHRONOS", "Ringed giant", "baab82", "eee0b5", Vector2(1860, 700), 66.0, 16, true, 6, ["nyx"]),
		_planet("nyx", "NYX", "Carbon world", "756886", "c2a5d6", Vector2(2060, 420), 44.0, 8, false, 7, ["terminus"]),
		_planet("terminus", "TERMINUS", "Crystal world", "7aafbc", "c6eef5", Vector2(2220, 890), 57.0, 7, true, 8, []),
	]

static func _planet(id: String, display_name: String, kind: String, color_hex: String, accent_hex: String, position: Vector2, radius: float, moons: int, ringed: bool, stage: int, destinations: Array[String]) -> Dictionary:
	return {
		"id": id,
		"name": display_name,
		"kind": kind,
		"battle_environment": id if id in ["viridia", "aurora"] else "space",
		"color": Color(color_hex),
		"accent": Color(accent_hex),
		"position": position - Vector2(1200.0, 700.0),
		"radius": radius,
		"moons": moons,
		"ringed": ringed,
		"stage": stage,
		"routes": destinations,
	}
