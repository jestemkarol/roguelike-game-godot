extends Node2D

# Exported variables for textures
@export var noise_height_texture: NoiseTexture2D
@export var grain_noise_texture: NoiseTexture2D
@export var noise_cliff_texture: NoiseTexture2D
@export var noise_paths_texture: NoiseTexture2D

# Onready variables for nodes and resources
@onready var tile_map: TileMap = $TileMap
@onready var player: CharacterBody2D = $Player
@onready var AreaSettings = preload("res://scripts/AreaSettings.gd")
@onready var Helpers = preload("res://scripts/ScriptHelpers.gd")
const GRADIENT = preload("res://data/gradient.png")

var height_noise: Noise
var grain_noise: Noise
var cliff_noise: Noise
var paths_noise: Noise
var grass_array: Array = []
var paths_array: Array = []
var cliffs_array: Array = []
var trees_array: Array = []
var water_rocks_array: Array = []

const GRASS_MIN_NOISE = 0.1
const WATER_ROCKS_MIN_NOISE = 0.5
const TREES_MIN_NOISE = 0.7
const CLIFF_MIN_NOISE = 0.3
const CLIFF_MAX_NOISE = 0.33
const PATHS_MIN_NOISE = 0.25
const PATHS_MAX_NOISE = 0.35

# Report vars
var cliff_density_reached: bool = false
var seed: int

var PLAYER_SPAWN_AREA: Dictionary
var MAX_CLIFF_TILES: int

func _ready() -> void:
	_initialize_noise()
	_initialize_constants()
	generate_level()

func _initialize_noise() -> void:
	randomize()
	height_noise = noise_height_texture.noise
	grain_noise = grain_noise_texture.noise
	cliff_noise = noise_cliff_texture.noise
	paths_noise = noise_paths_texture.noise
	#seed = randi()
	seed = 703819954 # cliff seed
	height_noise.set_seed(seed)
	grain_noise.set_seed(seed)
	cliff_noise.set_seed(seed)
	paths_noise.set_seed(seed)

func _initialize_constants() -> void:
	PLAYER_SPAWN_AREA = {
		"top_left": Vector2i(5, 5),
		"bottom_right": Vector2i(AreaSettings.WIDTH - 5, AreaSettings.HEIGHT - 5)
	}
	MAX_CLIFF_TILES = int(float(AreaSettings.WIDTH * AreaSettings.HEIGHT) * AreaSettings.MAX_CLIFF_TILES_DENSITY)

func generate_level() -> void:
	var height_values = _generate_terrain()
	_set_tile_terrain()
	_set_objects()
	_spawn_player()
	_check_reset_stage(height_values)
	_extend_terrain()
	_log_report()

func _generate_terrain() -> Array:
	var height_values = []
	var gradient_image: Image = GRADIENT.get_image()

	for x in range(AreaSettings.WIDTH):
		for y in range(AreaSettings.HEIGHT):
			var point = Vector2i(x, y)
			var height_noise_val = height_noise.get_noise_2d(x * 0.3, y * 0.3) * 2.0
			var grain_noise_val = grain_noise.get_noise_2d(x, y)
			var cliff_noise_val = cliff_noise.get_noise_2d(x, y)
			var paths_noise_val = paths_noise.get_noise_2d(x, y)
			var gradient_val = gradient_image.get_pixel(x, y).r
			height_noise_val -= gradient_val
			height_values.append(height_noise_val)
			_categorize_point(point, height_noise_val, grain_noise_val, cliff_noise_val, paths_noise_val)
			_set_initial_tile(point, height_noise_val)

	_remove_duplicates()
	return height_values

func _categorize_point(point: Vector2i, height_noise_val: float, grain_noise_val: float, cliff_noise_val: float, paths_noise_val: float) -> void:
	var is_grass_point = false
	if height_noise_val > GRASS_MIN_NOISE:
		is_grass_point = true
		grass_array.append(point)
		if grain_noise_val > TREES_MIN_NOISE && cliff_noise_val < CLIFF_MIN_NOISE:
			trees_array.append(point)
	if cliff_noise_val > CLIFF_MIN_NOISE && cliff_noise_val < CLIFF_MAX_NOISE && is_grass_point:
		if cliffs_array.size() < MAX_CLIFF_TILES:
			cliffs_array.append(point)
		else:
			cliff_density_reached = true
	if paths_noise_val > PATHS_MIN_NOISE && paths_noise_val < PATHS_MAX_NOISE && is_grass_point:
		paths_array.append(point)
	if !is_grass_point && grain_noise_val > WATER_ROCKS_MIN_NOISE && height_noise_val < GRASS_MIN_NOISE:
		water_rocks_array.append(point)

func _remove_duplicates() -> void:
	grass_array = _make_unique(grass_array)
	trees_array = _make_unique(trees_array)
	cliffs_array = _make_unique(cliffs_array)
	paths_array = _make_unique(paths_array)

func _make_unique(array: Array) -> Array:
	var unique_set = {}
	for element in array:
		unique_set[element] = true
	return unique_set.keys()

func _set_initial_tile(point: Vector2i, height_noise_val: float) -> void:
	tile_map.set_cell(AreaSettings.LAYERS.water, point, AreaSettings.WATER.source_id, AreaSettings.WATER.atlas)

func _set_tile_terrain() -> void:
	tile_map.set_cells_terrain_connect(AreaSettings.LAYERS.grass, grass_array, AreaSettings.GRASS.terrain_set_id, AreaSettings.GRASS.terrain_id)
	tile_map.set_cells_terrain_connect(AreaSettings.LAYERS.path, paths_array, AreaSettings.PATH.terrain_set_id, AreaSettings.PATH.terrain_id)
	tile_map.set_cells_terrain_connect(AreaSettings.LAYERS.cliff, cliffs_array, AreaSettings.CLIFFS.terrain_set_id, AreaSettings.CLIFFS.terrain_id)
	_generate_foam()

func _generate_foam() -> void:
	var grass_coords_array = tile_map.get_used_cells(AreaSettings.LAYERS.grass)
	for coord in grass_coords_array:
		tile_map.set_cell(AreaSettings.LAYERS.foam, coord, AreaSettings.FOAM.source_id, AreaSettings.FOAM.atlas)

func _set_objects() -> void:
	for water_rock_coords in water_rocks_array:
		var source_id = AreaSettings.ON_WATER_ROCKS.source_ids[randi() % AreaSettings.ON_WATER_ROCKS.source_ids.size()]
		tile_map.set_cell(AreaSettings.LAYERS.foam, water_rock_coords, source_id, AreaSettings.ON_WATER_ROCKS.atlas)
	var trees_array_copy = trees_array.duplicate()
	while !trees_array_copy.is_empty():
		var tree_spawn_coords = trees_array_copy.pop_back()
		
		# Check if the position is occupied by a cliff or path
		if !(tree_spawn_coords in cliffs_array || tree_spawn_coords in paths_array):
			# Check bordering positions for cliffs
			var should_set_tree = true
			for offset in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var neighbor = tree_spawn_coords + offset
				if neighbor in cliffs_array:
					should_set_tree = false
					break

			if should_set_tree:
				_set_tree(tree_spawn_coords)

func _set_tree(point: Vector2i) -> void:
	tile_map.set_cell(AreaSettings.LAYERS.objects, point, AreaSettings.OBJECTS.tree.source_id, AreaSettings.OBJECTS.tree.atlas)

func _check_reset_stage(height_values: Array) -> void:
	var map_size = AreaSettings.HEIGHT * AreaSettings.WIDTH
	var land_density = float(grass_array.size()) / float(map_size) * 100.0
	if height_values.max() < 0.4 || height_values.min() > -0.2:
		print('Resetting world-gen, because of noise low: %s and high %s' % [height_values.min(), height_values.max()])
		#_ready()
	if land_density < AreaSettings.LAND_DENSITY_MIN:
		print('Resetting world-gen, because of non sufficient land density: %s%%' % land_density)
		_ready()

func _extend_terrain() -> void:
	var outer_border_tiles = AreaSettings.GENERATE_TILES_PER_DIRECTION
	var width = AreaSettings.WIDTH
	var height = AreaSettings.HEIGHT
	for x in range(-outer_border_tiles, width + outer_border_tiles):
		for y in range(-outer_border_tiles, height + outer_border_tiles):
			if (x < 0 or x >= width or y < 0 or y >= height):
				tile_map.set_cell(AreaSettings.LAYERS.water, Vector2i(x, y), AreaSettings.WATER.source_id, AreaSettings.WATER.atlas)


func _log_report() -> void:
	var tiles_no_arr = [cliffs_array.size(), grass_array.size(), paths_array.size(), trees_array.size()]
	var map_size = AreaSettings.HEIGHT * AreaSettings.WIDTH
	var land_density = float(grass_array.size()) / float(map_size) * 100.0
	if cliff_density_reached:
		print('[WORLD-GEN]: Too many cliffs ffs! No. reached after cutoff: ', cliffs_array.size())
	print('[WORLD-GEN]: Generated %s cliff tiles, %s grass tiles, %s path tiles, %s trees tiles' % tiles_no_arr)
	print('[WORLD-GEN]: Map size: ', map_size)
	print('[WORLD-GEN]: Land density: %s%%' % land_density)
	print('[WORLD-GEN]: Used seed: ', seed)

func _spawn_player() -> void:
	grass_array.shuffle()
	for grass_point in grass_array:
		var tile_data = tile_map.get_cell_tile_data(AreaSettings.LAYERS.cliff, grass_point)
		
		if !tile_data:
			player.global_position = tile_map.map_to_local(grass_point)
			print('Player spawned successfully at %s.' % grass_point)
			return
		else:
			print('Tried to spawn at %s, but cliff tile detected.' % grass_point)
	
	# If no suitable grass tile is found, restart the setup
	print("Failed to find a suitable grass tile for player spawn. Restarting setup...")
	_ready()
