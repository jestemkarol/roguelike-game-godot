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

var PLAYER_SPAWN_AREA: Dictionary

func _ready() -> void:
	randomize()
	noise = noise_height_texture.noise
	initialize_constants()
	border_area_generator = BorderAreaGenerator.new(tile_map, noise, AreaSettings.new())
	generate_level()

func initialize_constants() -> void:
	PLAYER_SPAWN_AREA = {
		"top_left": Vector2i(5, AreaSettings.HEIGHT - 7),
		"bottom_right": Vector2i(AreaSettings.WIDTH - 5, AreaSettings.HEIGHT - 5)
	}
func generate_level() -> void:
	for x in range(AreaSettings.WIDTH):
		for y in range(AreaSettings.HEIGHT):
			set_grass(Vector2i(x, y))
			border_area_generator.generate_closed_borders(Vector2i(x, y))
	spawn_player()

func set_grass(position: Vector2i) -> void:
	tile_map.set_cell(AreaSettings.LAYERS.grass, position, AreaSettings.GRASS.source_id, AreaSettings.GRASS.atlas)

func spawn_player() -> void:
	var player_position = Helpers.get_random_point_in_area(PLAYER_SPAWN_AREA.top_left, PLAYER_SPAWN_AREA.bottom_right)
	player.global_position = tile_map.map_to_local(player_position)

