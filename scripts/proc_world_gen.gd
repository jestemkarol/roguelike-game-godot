extends Node2D

@export var noise_height_texture: NoiseTexture2D
@export var noise_paths_texture: NoiseTexture2D
var height_noise: Noise
var paths_noise: Noise

@onready var tile_map: TileMap = $TileMap
@onready var player: CharacterBody2D = $Player

@onready var AreaSettings = preload("res://scripts/world_gen/AreaSettings.gd")
@onready var Helpers = preload("res://scripts/ScriptHelpers.gd")

# Generators
@onready var BorderAreaGenerator = preload("res://scripts/world_gen/BorderAreaGenerator.gd")

var border_area_generator: BorderAreaGenerator
var paths_array: Array = []
var cliffs_array: Array = []

var PLAYER_SPAWN_AREA: Dictionary

func _ready() -> void:
	randomize()
	height_noise = noise_height_texture.noise
	paths_noise = noise_paths_texture.noise
	height_noise.set_seed(randi())
	paths_noise.set_seed(randi())
	initialize_constants()
	var area_settings = AreaSettings.new()
	border_area_generator = BorderAreaGenerator.new(tile_map, height_noise, area_settings)
	generate_level()

func initialize_constants() -> void:
	PLAYER_SPAWN_AREA = {
		"top_left": Vector2i(5, 5),
		"bottom_right": Vector2i(AreaSettings.WIDTH - 5, AreaSettings.HEIGHT - 5)
	}

func generate_level() -> void:
	for x in range(AreaSettings.WIDTH):
		for y in range(AreaSettings.HEIGHT):
			var point = Vector2i(x, y)
			var paths_noise_val = paths_noise.get_noise_2d(x, y)
			var height_noise_val = height_noise.get_noise_2d(x, y)
			set_grass(point)
			if paths_noise_val > 0.0 && paths_noise_val < 0.1:
				paths_array.append(point)
			elif height_noise_val > 0.2:
				cliffs_array.append(point)
	
	tile_map.set_cells_terrain_connect(AreaSettings.LAYERS.ground, paths_array, AreaSettings.PATH.terrain_set_id, AreaSettings.PATH.terrain_id)
	tile_map.set_cells_terrain_connect(AreaSettings.LAYERS.cliff, cliffs_array, AreaSettings.CLIFFS.terrain_set_id, AreaSettings.CLIFFS.terrain_id)
	border_area_generator.generate_borders()
	spawn_player()

func set_grass(position: Vector2i) -> void:
	tile_map.set_cell(AreaSettings.LAYERS.ground, position, AreaSettings.GRASS.source_id, AreaSettings.GRASS.atlas)

func spawn_player() -> void:
	var attempts = 0
	var max_attempts = 30
	var player_position = Vector2()
	var tile_data = null
	
	while attempts < max_attempts:
		player_position = Helpers.get_random_point_in_area(PLAYER_SPAWN_AREA.top_left, PLAYER_SPAWN_AREA.bottom_right)
		tile_data = tile_map.get_cell_tile_data(AreaSettings.LAYERS.cliff, player_position)
		
		if !tile_data:
			player.global_position = tile_map.map_to_local(player_position)
			print('Player spawned successfully after ', attempts + 1, ' attempts.')
			print('Player pos: ', player_position)
			return
		else:
			print('[%s] Tried to spawn at %s, but tile_data.terrain: %s, terrain_set: %s' % [attempts, player_position, tile_data.terrain, tile_data.terrain_set])
			attempts += 1
	
	# If the loop completes without finding a suitable tile, restart the setup
	print("Failed to find a suitable grass tile for player spawn after %d attempts. Restarting setup..." % max_attempts)
	_ready()  # Call the _ready() function to reset the setup
