extends Node

class_name BorderAreaGenerator

var tile_map: TileMap
var noise: Noise

var BORDER_AREAS: Dictionary
var area_settings: AreaSettings
var cliff_coords_array: Array = []

func _init(tile_map: TileMap, noise: Noise, area_settings: AreaSettings) -> void:
	self.tile_map = tile_map
	self.noise = noise
	self.area_settings = area_settings

func initialize_borders() -> void:
	BORDER_AREAS = {
		"top": { "top_corner": Vector2i(-2, -2), "bottom_corner": Vector2i(area_settings.WIDTH + 2, 1) },
		"left": { "top_corner": Vector2i(-2, -2), "bottom_corner": Vector2i(1, area_settings.HEIGHT + 2) },
		"right": { "top_corner": Vector2i(AreaSettings.WIDTH - 2, -2), "bottom_corner": Vector2i(AreaSettings.WIDTH + 2, AreaSettings.HEIGHT + 2) },
		"bottom": { "top_corner": Vector2i(-2, AreaSettings.HEIGHT - 2), "bottom_corner": Vector2i(AreaSettings.WIDTH + 2, AreaSettings.HEIGHT + 2) }
	}
	
	collect_coords()

func generate_borders() -> void:
	initialize_borders()
	generate_outer_borders()

func generate_outer_borders() -> void:
	tile_map.set_cells_terrain_connect(AreaSettings.LAYERS.cliff, cliff_coords_array, AreaSettings.CLIFFS.terrain_set_id, AreaSettings.CLIFFS.terrain_id)

func collect_coords() -> void:
	for key in BORDER_AREAS.keys():
		var top_corner = BORDER_AREAS[key]["top_corner"]
		var bottom_corner = BORDER_AREAS[key]["bottom_corner"]
		
		for y in range(top_corner.y, bottom_corner.y + 1):
			for x in range(top_corner.x, bottom_corner.x + 1):
				cliff_coords_array.append(Vector2(x, y))
