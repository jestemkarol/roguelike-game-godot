extends Node

class_name BorderAreaGenerator

var tile_map: TileMap
var noise: Noise

var BORDER_AREAS: Dictionary
var INNER_BORDER_AREA: Dictionary
var INNER_BORDER_CORNERS: Dictionary
var INNER_BORDER_ATLAS_MAPPING: Dictionary
var INNER_BORDER_CORNERS_ATLAS_MAPPING: Dictionary
var area_settings: AreaSettings

func _init(tile_map: TileMap, noise: Noise, area_settings: AreaSettings) -> void:
	self.tile_map = tile_map
	self.noise = noise
	self.area_settings = area_settings

func initialize_borders() -> void:
	BORDER_AREAS = {
		"top": { "top_corner": Vector2i(0, 0), "bottom_corner": Vector2i(area_settings.WIDTH - 1, 1) },
		"left": { "top_corner": Vector2i(0, 0), "bottom_corner": Vector2i(1, area_settings.HEIGHT - 1) },
		"right": { "top_corner": Vector2i(AreaSettings.WIDTH - 1, 0), "bottom_corner": Vector2i(AreaSettings.WIDTH - 2, AreaSettings.HEIGHT - 1) },
		"bottom": { "top_corner": Vector2i(0, AreaSettings.HEIGHT - 2), "bottom_corner": Vector2i(AreaSettings.WIDTH - 1, AreaSettings.HEIGHT - 1) }
	}

	INNER_BORDER_AREA = {
		"top": { "top_corner": Vector2i(3, 2), "bottom_corner": Vector2i(AreaSettings.WIDTH - 4, 2) },
		"left": { "top_corner": Vector2i(2, 3), "bottom_corner": Vector2i(2, AreaSettings.HEIGHT - 4) },
		"right": { "top_corner": Vector2i(AreaSettings.WIDTH - 3, 3), "bottom_corner": Vector2i(AreaSettings.WIDTH - 3, AreaSettings.HEIGHT - 4) },
		"bottom": { "top_corner": Vector2i(3, AreaSettings.HEIGHT - 3), "bottom_corner": Vector2i(AreaSettings.WIDTH - 4, AreaSettings.HEIGHT - 3) }
	}

	INNER_BORDER_CORNERS = {
		"top_left": Vector2i(2, 2),
		"top_right": Vector2i(AreaSettings.WIDTH - 3, 2),
		"bottom_left": Vector2i(2, AreaSettings.HEIGHT - 3),
		"bottom_right": Vector2i(AreaSettings.WIDTH - 3, AreaSettings.HEIGHT - 3)
	}

	INNER_BORDER_ATLAS_MAPPING = {
		"top": AreaSettings.CLIFFS.bottom_outer_top,
		"left": AreaSettings.CLIFFS.right_outer,
		"right": AreaSettings.CLIFFS.left_outer,
		"bottom": AreaSettings.CLIFFS.top_outer
	}

	INNER_BORDER_CORNERS_ATLAS_MAPPING = {
		"top_left": AreaSettings.CLIFFS.bottom_inner_left,
		"top_right": AreaSettings.CLIFFS.bottom_inner_right,
		"bottom_left": AreaSettings.CLIFFS.top_inner_left,
		"bottom_right": AreaSettings.CLIFFS.top_inner_right
	}

func generate_closed_borders(position: Vector2i) -> void:
	initialize_borders()
	generate_outer_borders(position)
	generate_inner_borders(position)
	generate_inner_border_corners(position)

func generate_inner_border_corners(position: Vector2i) -> void:
	for corner in INNER_BORDER_CORNERS.keys():
		if position == INNER_BORDER_CORNERS[corner]:
			tile_map.set_cell(AreaSettings.LAYERS.cliff, position, AreaSettings.CLIFFS.source_id, INNER_BORDER_CORNERS_ATLAS_MAPPING[corner])
			return

func generate_outer_borders(position: Vector2i) -> void:
	for border in BORDER_AREAS.values():
		if Helpers.is_point_in_area(position, border["top_corner"], border["bottom_corner"]):
			tile_map.set_cell(AreaSettings.LAYERS.cliff, position, AreaSettings.CLIFFS.source_id, AreaSettings.CLIFFS.inner)
			return

func generate_inner_borders(position: Vector2i) -> void:
	for side in INNER_BORDER_AREA.keys():
		var area = INNER_BORDER_AREA[side]
		if Helpers.is_point_in_area(position, area["top_corner"], area["bottom_corner"]):
			tile_map.set_cell(AreaSettings.LAYERS.cliff, position, AreaSettings.CLIFFS.source_id, INNER_BORDER_ATLAS_MAPPING[side])
			return
