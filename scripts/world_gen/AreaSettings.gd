extends Node

class_name AreaSettings

# Area size
# REMEMBER if changing to change Noise H&W
const HEIGHT = 50
const WIDTH = 75

# Layers
const LAYERS = {
	"ground": 0,
	"cliff": 1,
	"objects": 2
}

# Grass
const GRASS = {
	"source_id": 0,
	"atlas": Vector2i(0, 0)
}

# Cliffs
const CLIFFS = {
	"source_id": 1,
	"terrain_set_id": 1,
	"terrain_id": 0
}

const PATH = {
	"terrain_set_id": 0,
	"terrain_id": 0
}

