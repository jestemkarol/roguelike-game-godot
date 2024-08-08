extends Node2D

const GRASS_MIN_NOISE = 0.1
const WATER_ROCKS_MIN_NOISE = 0.6
const MUSHROOM_MIN_NOISE = 0.55
const TREES_MIN_NOISE = 0.5
const BUSH_MIN_NOISE = 0.45
const CLIFF_MIN_NOISE = 0.3
const CLIFF_MAX_NOISE = 0.33
const PATHS_MIN_NOISE = 0.25
const PATHS_MAX_NOISE = 0.35

const GRADIENT = preload("res://data/gradient.png")


@export var noise_height_texture: NoiseTexture2D
@export var grain_noise_texture: NoiseTexture2D
@export var noise_cliff_texture: NoiseTexture2D
@export var noise_paths_texture: NoiseTexture2D


var bushes_array: Array = []
var height_noise: Noise
var grain_noise: Noise
var cliff_noise: Noise
var paths_noise: Noise
var grass_array: Array = []
var paths_array: Array = []
var cliffs_array: Array = []
var trees_array: Array = []
var water_rocks_array: Array = []

# Report vars
var cliff_density_reached: bool = false
var used_seed: int

var max_cliff_tiles: int


@onready var tile_map: TileMap = $TileMap
@onready var player: CharacterBody2D = $Player
@onready var config: AreaSettings = AreaSettings.new()
@onready var helpers: Helpers = Helpers.new()
@onready var report_formatter: ReportFormatter = ReportFormatter.new()

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
	used_seed = randi()
	#seed = 703819954 # cliff seed
	height_noise.set_seed(used_seed)
	grain_noise.set_seed(used_seed)
	cliff_noise.set_seed(used_seed)
	paths_noise.set_seed(used_seed)


func _initialize_constants() -> void:
	max_cliff_tiles = int(
		float(config.WIDTH * config.HEIGHT) * config.MAX_CLIFF_TILES_DENSITY
	)


func generate_level() -> void:
	_generate_terrain()
	_set_tile_terrain()
	_set_objects()
	_spawn_player()
	_check_reset_stage()
	_extend_terrain()
	_log_report()


func _generate_terrain() -> void:
	var gradient_image: Image = GRADIENT.get_image()

	for x in range(config.WIDTH):
		for y in range(config.HEIGHT):
			var point = Vector2i(x, y)
			var height_noise_val = height_noise.get_noise_2d(x * 0.3, y * 0.3) * 2.0
			var grain_noise_val = grain_noise.get_noise_2d(x, y)
			var cliff_noise_val = cliff_noise.get_noise_2d(x, y)
			var paths_noise_val = paths_noise.get_noise_2d(x, y)
			var gradient_val = gradient_image.get_pixel(x, y).r
			height_noise_val -= gradient_val
			_categorize_point(
				point, height_noise_val, grain_noise_val, cliff_noise_val, paths_noise_val
			)
			_set_initial_tile(point)

	_remove_duplicates()


func _categorize_point(
	point: Vector2i,
	height_noise_val: float,
	grain_noise_val: float,
	cliff_noise_val: float,
	paths_noise_val: float
) -> void:
	var is_grass_point = false
	if height_noise_val > GRASS_MIN_NOISE:
		is_grass_point = true
		grass_array.append(point)
		if (
			grain_noise_val > BUSH_MIN_NOISE
			&& grain_noise_val < TREES_MIN_NOISE
			&& cliff_noise_val < CLIFF_MIN_NOISE
		):
			bushes_array.append(point)
		if grain_noise_val > TREES_MIN_NOISE && cliff_noise_val < CLIFF_MIN_NOISE:
			trees_array.append(point)
	if cliff_noise_val > CLIFF_MIN_NOISE && cliff_noise_val < CLIFF_MAX_NOISE && is_grass_point:
		if cliffs_array.size() < max_cliff_tiles:
			cliffs_array.append(point)
		else:
			cliff_density_reached = true
	if paths_noise_val > PATHS_MIN_NOISE && paths_noise_val < PATHS_MAX_NOISE && is_grass_point:
		paths_array.append(point)
	if (
		!is_grass_point
		&& grain_noise_val > WATER_ROCKS_MIN_NOISE
		&& height_noise_val < GRASS_MIN_NOISE
	):
		water_rocks_array.append(point)


func _remove_duplicates() -> void:
	grass_array = helpers.make_unique(grass_array)
	trees_array = helpers.make_unique(trees_array)
	cliffs_array = helpers.make_unique(cliffs_array)
	paths_array = helpers.make_unique(paths_array)
	water_rocks_array = helpers.make_unique(water_rocks_array)
	bushes_array = helpers.make_unique(bushes_array)


func _set_initial_tile(point: Vector2i) -> void:
	tile_map.set_cell(
		config.LAYERS.water, point, config.WATER.source_id, config.WATER.atlas
	)


func _set_tile_terrain() -> void:
	tile_map.set_cells_terrain_connect(
		config.LAYERS.grass,
		grass_array,
		config.GRASS.terrain_set_id,
		config.GRASS.terrain_id
	)
	tile_map.set_cells_terrain_connect(
		config.LAYERS.path,
		paths_array,
		config.PATH.terrain_set_id,
		config.PATH.terrain_id
	)
	tile_map.set_cells_terrain_connect(
		config.LAYERS.cliff,
		cliffs_array,
		config.CLIFFS.terrain_set_id,
		config.CLIFFS.terrain_id
	)
	_generate_foam()


func _generate_foam() -> void:
	var grass_coords_array = tile_map.get_used_cells(config.LAYERS.grass)
	for coord in grass_coords_array:
		tile_map.set_cell(
			config.LAYERS.foam, coord, config.FOAM.source_id, config.FOAM.atlas
		)


func _set_objects() -> void:
	_set_water_rocks()
	_set_trees()
	_set_bushes()
	_set_mushrooms()


func _set_water_rocks() -> void:
	for water_rock_coords in water_rocks_array:
		var source_id = config.ON_WATER_ROCKS.source_ids[
			randi() % config.ON_WATER_ROCKS.source_ids.size()
		]
		tile_map.set_cell(
			config.LAYERS.foam,
			water_rock_coords,
			source_id,
			config.ON_WATER_ROCKS.atlas
		)


func _set_trees() -> void:
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
				tile_map.set_cell(
					config.LAYERS.objects,
					tree_spawn_coords,
					config.OBJECTS.tree.source_id,
					config.OBJECTS.tree.atlas
				)


func _set_bushes() -> void:
	for bush_coords in bushes_array:
		if !paths_array.has(bush_coords) && !cliffs_array.has(bush_coords):
			var source_id = config.OBJECTS.bush.source_ids[
				randi() % config.OBJECTS.bush.source_ids.size()
			]
			tile_map.set_cell(
				config.LAYERS.objects, bush_coords, source_id, config.OBJECTS.bush.atlas
			)


func _set_mushrooms() -> void:
	for mushroom_coords in paths_array:
		var grain_noise_val = grain_noise.get_noise_2d(mushroom_coords.x, mushroom_coords.y)
		if grain_noise_val > MUSHROOM_MIN_NOISE && !cliffs_array.has(mushroom_coords):
			var source_ids = config.OBJECTS.mushroom.source_ids
			var source_id = source_ids[randi() % source_ids.size()]
			tile_map.set_cell(
				config.LAYERS.objects,
				mushroom_coords,
				source_id,
				config.OBJECTS.mushroom.atlas
			)


func _check_reset_stage() -> void:
	var map_size = config.HEIGHT * config.WIDTH
	var land_density = float(grass_array.size()) / float(map_size) * 100.0
	if land_density < config.LAND_DENSITY_MIN:
		print("Resetting world-gen, because of non sufficient land density: %s%%" % land_density)
		_ready()


func _extend_terrain() -> void:
	var outer_border_tiles = config.GENERATE_TILES_PER_DIRECTION
	var width = config.WIDTH
	var height = config.HEIGHT
	for x in range(-outer_border_tiles, width + outer_border_tiles):
		for y in range(-outer_border_tiles, height + outer_border_tiles):
			if x < 0 or x >= width or y < 0 or y >= height:
				tile_map.set_cell(
					config.LAYERS.water,
					Vector2i(x, y),
					config.WATER.source_id,
					config.WATER.atlas
				)


func _log_report() -> void:
	report_formatter.log_report(
		cliffs_array,
		grass_array,
		paths_array,
		trees_array,
		config.HEIGHT * config.WIDTH,
		cliff_density_reached,
		used_seed
	)


func _spawn_player() -> void:
	grass_array.shuffle()
	for grass_point in grass_array:
		var tile_data = tile_map.get_cell_tile_data(config.LAYERS.cliff, grass_point)
		if tile_data:
			print("Tried to spawn at %s, but cliff tile detected." % grass_point)
		else:
			player.global_position = tile_map.map_to_local(grass_point)
			print("Player spawned successfully at %s." % grass_point)
			return

	# If no suitable grass tile is found, restart the setup
	print("Failed to find a suitable grass tile for player spawn. Restarting setup...")
	_ready()
