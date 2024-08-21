extends Node2D

const NOISE_THRESHOLDS = {
	WATER_ROCKS_MIN = 0.55,
	GRASS_MIN = 0.1,
	PATHS_MIN = 0.25,
	PATHS_MAX = 0.35,
	CLIFF_MIN = 0.3,
	CLIFF_MAX = 0.33,
	BUSH_MIN = 0.45,
	TREES_MIN = 0.5,
	MUSHROOM_MIN = 0.55,
	ENEMY_MIN = 0.2
}

const GRADIENT = preload("res://data/gradient.png")

@export var Enemy = preload("res://scenes/enemy.tscn")
@export var enemies_count: int = 5

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
var enemies_array: Array = []

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
	_verify_seed_adequacy()
	generate_level()


func _initialize_noise() -> void:
	randomize()
	height_noise = noise_height_texture.noise
	grain_noise = grain_noise_texture.noise
	cliff_noise = noise_cliff_texture.noise
	paths_noise = noise_paths_texture.noise
	used_seed = randi()
	height_noise.set_seed(used_seed)
	grain_noise.set_seed(used_seed)
	cliff_noise.set_seed(used_seed)
	paths_noise.set_seed(used_seed)


func _initialize_constants() -> void:
	max_cliff_tiles = int(
		float(config.WIDTH * config.HEIGHT) * config.MAX_CLIFF_TILES_DENSITY
	)


func _verify_seed_adequacy() -> void:
	# TODO: Decrease GRASS_MIN_NOISE instead of reseeding or:
	# Adjust all _NOISE values to the spread of highest/lowest noise vals instead of reseeding
	while true: # This is freaking scary, I will rethink it
		_initialize_noise()
		var land_density_temp_array = _calculate_land_density()
		var map_size = float(config.HEIGHT * config.WIDTH)
		var land_density = land_density_temp_array.size() / map_size * 100.0

		if land_density >= config.LAND_DENSITY_MIN:
			break
		else:
			print(
				"Regenerating with new seed due to insufficient land density of %s%%"
				% land_density
			)

func _calculate_land_density() -> Array:
	var land_density_temp_array: Array = []
	var gradient_image: Image = GRADIENT.get_image()

	for x in range(config.WIDTH):
		for y in range(config.HEIGHT):
			var height_noise_val = height_noise.get_noise_2d(x * 0.3, y * 0.3) * 2.0
			var gradient_val = gradient_image.get_pixel(x, y).r
			height_noise_val -= gradient_val

			if height_noise_val > NOISE_THRESHOLDS.GRASS_MIN:
				land_density_temp_array.append(Vector2i(x, y))

	return land_density_temp_array

func generate_level() -> void:
	_generate_terrain()
	_set_tile_terrain()
	_set_objects()
	_spawn_enemies()
	_spawn_player()
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
	if height_noise_val > NOISE_THRESHOLDS.GRASS_MIN:
		is_grass_point = true
		grass_array.append(point)
		if _can_set_bush(grain_noise_val, cliff_noise_val):
			bushes_array.append(point)
		if _can_set_tree(grain_noise_val, cliff_noise_val):
			trees_array.append(point)
	if _can_set_cliff(cliff_noise_val, is_grass_point):
		if cliffs_array.size() < max_cliff_tiles:
			cliffs_array.append(point)
		else:
			cliff_density_reached = true
	if _can_set_path(paths_noise_val, is_grass_point):
		paths_array.append(point)
	if _can_set_water_rock(grain_noise_val, height_noise_val, is_grass_point):
		water_rocks_array.append(point)
	if _can_spawn_enemy(grain_noise_val, is_grass_point):
		enemies_array.append(point)

func _can_set_bush(grain_noise_val: float, cliff_noise_val: float) -> bool:
	return (grain_noise_val > NOISE_THRESHOLDS.BUSH_MIN
		&& grain_noise_val < NOISE_THRESHOLDS.TREES_MIN
		&& cliff_noise_val < NOISE_THRESHOLDS.CLIFF_MIN)

func _can_set_tree(grain_noise_val: float, cliff_noise_val: float) -> bool:
	return (grain_noise_val > NOISE_THRESHOLDS.TREES_MIN
		&& cliff_noise_val < NOISE_THRESHOLDS.CLIFF_MIN)

func _can_set_cliff(cliff_noise_val: float, is_grass_point: bool) -> bool:
	return (cliff_noise_val > NOISE_THRESHOLDS.CLIFF_MIN
		&& cliff_noise_val < NOISE_THRESHOLDS.CLIFF_MAX
		&& is_grass_point)

func _can_set_path(paths_noise_val: float, is_grass_point: bool) -> bool:
	return (paths_noise_val > NOISE_THRESHOLDS.PATHS_MIN
		&& paths_noise_val < NOISE_THRESHOLDS.PATHS_MAX
		&& is_grass_point)

func _can_set_water_rock(grain_noise_val: float, height_noise_val: float, is_grass_point: bool) -> bool:
	return (!is_grass_point
		&& grain_noise_val > NOISE_THRESHOLDS.WATER_ROCKS_MIN
		&& height_noise_val < NOISE_THRESHOLDS.GRASS_MIN)

func _can_spawn_enemy(grain_noise_val: float, is_grass_point: bool) -> bool:
	return (is_grass_point
		&& grain_noise_val > NOISE_THRESHOLDS.ENEMY_MIN)

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
		if grain_noise_val > NOISE_THRESHOLDS.MUSHROOM_MIN && !cliffs_array.has(mushroom_coords):
			var source_ids = config.OBJECTS.mushroom.source_ids
			var source_id = source_ids[randi() % source_ids.size()]
			tile_map.set_cell(
				config.LAYERS.objects,
				mushroom_coords,
				source_id,
				config.OBJECTS.mushroom.atlas
			)


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
	report_formatter.log_report(build_log_report_data())

func build_log_report_data() -> Dictionary:
	var log_report_data: Dictionary = {
		'cliffs_array': cliffs_array,
		'grass_array': grass_array,
		'paths_array': paths_array,
		'trees_array': trees_array,
		'water_rocks_array': water_rocks_array,
		'map_size': config.HEIGHT * config.WIDTH,
		'cliff_density_reached': cliff_density_reached,
		'used_seed': used_seed,
		'enemies_array': enemies_array,
		'enemies_count': enemies_count
	}
	return log_report_data
	
func _spawn_enemies() -> void:
	var enemy_possible_positions = enemies_array
	var enemies = enemies_count
	while enemies > 0:
		enemy_possible_positions.shuffle()
		var enemy = Enemy.instantiate()
		add_child(enemy)
		enemy.global_position = tile_map.map_to_local(
			enemy_possible_positions.pop_back()
		)
		enemies -= 1

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

