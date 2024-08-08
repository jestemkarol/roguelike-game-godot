@tool

class_name AreaSettings
extends RefCounted

# Area size
# REMEMBER if changing to change Noise H&W
const HEIGHT = 75
const WIDTH = 125

const GENERATE_TILES_PER_DIRECTION = 15

const LAND_DENSITY_MIN = 35.0

const MAX_CLIFF_TILES_DENSITY = 0.1

# Layers
const LAYERS = {
	"water": 0,
	"foam": 1,
	"grass": 2,
	"path": 3,
	"cliff": 4,
	"objects": 5
}

const WATER = {
	"source_id": 11,
	"atlas": Vector2i(0,0)
}

const ON_WATER_ROCKS = {
	"source_ids": [1, 2, 3, 4],
	"atlas": Vector2i(0, 0)
}

const FOAM = {
	"source_id": 0,
	"atlas": Vector2i(0,0)
}

const GRASS = {
	"source_id": 8,
	"terrain_set_id": 1,
	"terrain_id": 0
}

const PATH = {
	"source_id": 8,
	"terrain_set_id": 1,
	"terrain_id": 1
}

const CLIFFS = {
	"source_id": 9,
	"terrain_set_id": 2,
	"terrain_id": 0
}

const OBJECTS = {
	"tree": {
		"source_id": 10,
		"atlas": Vector2i(0,0)
	},
	"mushroom": {
		"source_ids": [5, 6, 7],
		"atlas": Vector2i(0,0)
	},
	"bush": {
		"source_ids": [12, 13, 14],
		"atlas": Vector2i(0,0)
	}
}
