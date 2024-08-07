extends Node

class_name AreaSettings

# Area size
# REMEMBER if changing to change Noise H&W
const HEIGHT = 50
const WIDTH = 75

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

# Grass
const GRASS = {
	"source_id": 8,
	"terrain_set_id": 1,
	"terrain_id": 0
}

# Cliffs
const CLIFFS = {
	"source_id": 9,
	"terrain_set_id": 2,
	"terrain_id": 0
}

const PATH = {
	"source_id": 8,
	"terrain_set_id": 1,
	"terrain_id": 1
}

