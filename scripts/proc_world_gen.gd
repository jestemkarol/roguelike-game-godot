extends Node2D

@export var noise_height_texture: NoiseTexture2D
@export var noise_trees_texture: NoiseTexture2D
var height_noise: Noise
var trees_noise: Noise

@onready var tile_map: TileMap = $TileMap
@onready var player: CharacterBody2D = $Player

@onready var AreaSettings = preload("res://scripts/AreaSettings.gd")
@onready var Helpers = preload("res://scripts/ScriptHelpers.gd")

var grass_array: Array = []
var paths_array: Array = []
var cliffs_array: Array = []

var PLAYER_SPAWN_AREA: Dictionary

func _ready() -> void:
	randomize()
	height_noise = noise_height_texture.noise
	trees_noise = noise_trees_texture.noise
	height_noise.set_seed(randi())
	trees_noise.set_seed(randi())
	initialize_constants()
	var area_settings = AreaSettings.new()
	generate_level()

func initialize_constants() -> void:
	PLAYER_SPAWN_AREA = {
		"top_left": Vector2i(5, 5),
		"bottom_right": Vector2i(AreaSettings.WIDTH - 5, AreaSettings.HEIGHT - 5)
	}

func generate_level() -> void:
	var arr = []
	for x in range(AreaSettings.WIDTH):
		for y in range(AreaSettings.HEIGHT):
			var point = Vector2i(x, y)
			var trees_noise_val = trees_noise.get_noise_2d(x, y)
			var height_noise_val = height_noise.get_noise_2d(x, y)

			arr.append(height_noise_val)
			tile_map.set_cell(AreaSettings.LAYERS.water, point, AreaSettings.WATER.source_id, AreaSettings.WATER.atlas)
			if height_noise_val > -0.15:
				grass_array.append(point)
				if trees_noise_val > 0.75 && height_noise_val < 0.15:
					set_tree(point)
			if height_noise_val > 0.2:
				cliffs_array.append(point)
			if height_noise_val > 0.0 && height_noise_val < 0.05:
				paths_array.append(point)
	
	tile_map.set_cells_terrain_connect(AreaSettings.LAYERS.grass, grass_array, AreaSettings.GRASS.terrain_set_id, AreaSettings.GRASS.terrain_id)
	tile_map.set_cells_terrain_connect(AreaSettings.LAYERS.path, paths_array, AreaSettings.PATH.terrain_set_id, AreaSettings.PATH.terrain_id)
	tile_map.set_cells_terrain_connect(AreaSettings.LAYERS.cliff, cliffs_array, AreaSettings.CLIFFS.terrain_set_id, AreaSettings.CLIFFS.terrain_id)

	spawn_player()
	reset_stage(arr)

func set_tree(point: Vector2i) -> void:
	var atlas = AreaSettings.OBJECTS.tree.atlas_points
	tile_map.set_cell(AreaSettings.LAYERS.objects, point, AreaSettings.OBJECTS.tree.source_id, atlas[randi() % atlas.size()])

func reset_stage(arr) -> void:
	if arr.max() < 0.2 || arr.min() > -0.2:
		print('Resetting world-gen, because of noise low: %s and high %s' % [arr.min(), arr.max()])
		_ready()

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
