extends Node

class_name AreaSettings

# Area size
# REMEMBER if changing to change Noise H&W
const HEIGHT = 50
const WIDTH = 75

const LAND_DENSITY_MIN = 75.0

const MAX_CLIFF_TILES_DENSITY = 0.1

# Layers
const LAYERS = {
	"water": 0,
	"grass": 1,
	"path": 2,
	"cliff": 3,
	"objects": 4
}

const WATER = {
	"source_id": 11,
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
	}
}
