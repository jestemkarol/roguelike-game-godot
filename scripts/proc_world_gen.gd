extends Node2D

@export var noise_height_texture: NoiseTexture2D
var noise: Noise

@onready var tile_map: TileMap = $TileMap
@onready var player: CharacterBody2D = $Player

@onready var AreaSettings = preload("res://scripts/world_gen/AreaSettings.gd")
@onready var Helpers = preload("res://scripts/ScriptHelpers.gd")

# Generators
@onready var BorderAreaGenerator = preload("res://scripts/world_gen/BorderAreaGenerator.gd")

var border_area_generator: BorderAreaGenerator
var paths_array: Array = []

var PLAYER_SPAWN_AREA: Dictionary

func _ready() -> void:
	randomize()
	noise = noise_height_texture.noise
	initialize_constants()
	var area_settings = AreaSettings.new()
	border_area_generator = BorderAreaGenerator.new(tile_map, noise, area_settings)
	generate_level()

func initialize_constants() -> void:
	PLAYER_SPAWN_AREA = {
		"top_left": Vector2i(5, AreaSettings.HEIGHT - 7),
		"bottom_right": Vector2i(AreaSettings.WIDTH - 5, AreaSettings.HEIGHT - 5)
	}

func generate_level() -> void:
	for x in range(AreaSettings.WIDTH):
		for y in range(AreaSettings.HEIGHT):
			var point = Vector2i(x, y)
			var noise_val = noise.get_noise_2d(x, y)
			set_grass(point)
			if noise_val > 0.0 && noise_val < 0.1:
				paths_array.append(point)
	
	print(paths_array)
	tile_map.set_cells_terrain_connect(AreaSettings.LAYERS.ground, paths_array, AreaSettings.PATH.terrain_set_id, AreaSettings.PATH.terrain_id)
	spawn_player()

func set_grass(position: Vector2i) -> void:
	tile_map.set_cell(AreaSettings.LAYERS.ground, position, AreaSettings.GRASS.source_id, AreaSettings.GRASS.atlas)

func spawn_player() -> void:
	var player_position = Helpers.get_random_point_in_area(PLAYER_SPAWN_AREA.top_left, PLAYER_SPAWN_AREA.bottom_right)
	player.global_position = tile_map.map_to_local(player_position)

