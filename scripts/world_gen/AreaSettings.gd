extends Node

class_name AreaSettings

# Area size
# REMEMBER if changing to change Noise H&W
const HEIGHT = 75
const WIDTH = 100

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
	"inner": Vector2i(2, 5),
	"top_inner_left": Vector2i(4, 5),
	"top_outer": Vector2i(2, 4),
	"top_inner_right": Vector2i(5, 5),
	"bottom_inner_left": Vector2i(4, 4),
	"bottom_outer_top": Vector2i(2, 6),
	"bottom_inner_right": Vector2i(5, 4),
	"left_outer": Vector2i(1, 5),
	"right_outer": Vector2i(3, 5)
}

const PATH = {
	"terrain_set_id": 0,
	"terrain_id": 0
}

