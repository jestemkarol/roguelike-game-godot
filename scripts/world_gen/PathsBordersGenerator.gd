extends Node

class_name PathsBordersGenerator

var tile_map: TileMap
var area_settings: AreaSettings

func _init(tile_map: TileMap, area_settings: AreaSettings) -> void:
	self.tile_map = tile_map
	self.area_settings = area_settings

func generate_paths_borders() -> void:
	for x in range(AreaSettings.WIDTH):
		for y in range(AreaSettings.HEIGHT):
			var area_point = Vector2i(x, y)
			var atlas_coordinates = get_tile_atlas(area_point)
			if atlas_coordinates == AreaSettings.PATH.inner:
				generate_borders(area_point)

func generate_borders(area_point: Vector2i) -> void:
	pass
	top_border(area_point)
	bottom_border(area_point)
	left_border(area_point)
	right_border(area_point)
	generate_corners(area_point)

func top_border(area_point: Vector2i) -> void:
	var top_coords = Vector2i(area_point.x, area_point.y - 1)
	var top_left_coords = Vector2i(area_point.x - 1, area_point.y - 1)
	var top_right_coords = Vector2i(area_point.x + 1, area_point.y - 1)
	var top_tile = get_tile_atlas(top_coords)
	if top_tile == AreaSettings.GRASS.atlas:
		var top_left_tile = get_tile_atlas(top_left_coords)
		var top_right_tile = get_tile_atlas(top_right_coords)
		if top_left_tile != AreaSettings.PATH.inner && top_right_tile != AreaSettings.PATH.inner:
			place_cell(top_coords, AreaSettings.PATH.top.standard)
		elif top_left_tile != AreaSettings.PATH.inner && top_right_tile == AreaSettings.PATH.inner:
			place_cell(top_coords, AreaSettings.PATH.top.left_outer)
		elif top_left_tile == AreaSettings.PATH.inner && top_right_tile != AreaSettings.PATH.inner:
			place_cell(top_coords, AreaSettings.PATH.top.right_outer)
		elif top_left_tile == AreaSettings.PATH.inner && top_right_tile == AreaSettings.PATH.inner:
			place_cell(top_coords, AreaSettings.PATH.inner)
			var top_top_coords = Vector2i(top_coords.x, top_coords.y - 1)
			place_cell(top_top_coords, AreaSettings.PATH.top.standard)

func bottom_border(area_point: Vector2i) -> void:
	var bottom_coords = Vector2i(area_point.x, area_point.y + 1)
	var bottom_left_coords = Vector2i(area_point.x - 1, area_point.y + 1)
	var bottom_right_coords = Vector2i(area_point.x + 1, area_point.y + 1)
	var bottom_tile = get_tile_atlas(bottom_coords)
	if bottom_tile == AreaSettings.GRASS.atlas:
		var bottom_left_tile = get_tile_atlas(bottom_left_coords)
		var bottom_right_tile = get_tile_atlas(bottom_right_coords)
		if bottom_left_tile != AreaSettings.PATH.inner && bottom_right_tile != AreaSettings.PATH.inner:
			place_cell(bottom_coords, AreaSettings.PATH.bottom.standard)
		elif bottom_left_tile != AreaSettings.PATH.inner && bottom_right_tile == AreaSettings.PATH.inner:
			place_cell(bottom_coords, AreaSettings.PATH.bottom.left_outer)
		elif bottom_left_tile == AreaSettings.PATH.inner && bottom_right_tile != AreaSettings.PATH.inner:
			place_cell(bottom_coords, AreaSettings.PATH.bottom.right_outer)
		elif bottom_left_tile == AreaSettings.PATH.inner && bottom_right_tile == AreaSettings.PATH.inner:
			place_cell(bottom_coords, AreaSettings.PATH.inner)
			var bottom_bottom_coords = Vector2i(bottom_coords.x, bottom_coords.y + 1)
			place_cell(bottom_bottom_coords, AreaSettings.PATH.bottom.standard)

func left_border(area_point: Vector2i) -> void:
	var left_coords = Vector2i(area_point.x - 1, area_point.y)
	var left_bottom_coords = Vector2i(area_point.x - 1, area_point.y + 1)
	var left_top_coords = Vector2i(area_point.x - 1, area_point.y - 1)
	var left_tile = get_tile_atlas(left_coords)
	if left_tile == AreaSettings.GRASS.atlas:
		var left_bottom_tile = get_tile_atlas(left_bottom_coords)
		var left_top_tile = get_tile_atlas(left_top_coords)
		if left_bottom_tile != AreaSettings.PATH.inner && left_top_tile != AreaSettings.PATH.inner:
			place_cell(left_coords, AreaSettings.PATH.left.standard)

func right_border(area_point: Vector2i) -> void:
	var right_coords = Vector2i(area_point.x + 1, area_point.y)
	var right_bottom_cords = Vector2i(area_point.x + 1, area_point.y + 1)
	var right_top_cords = Vector2i(area_point.x + 1, area_point.y - 1)
	var right_tile = get_tile_atlas(right_coords)
	if right_tile == AreaSettings.GRASS.atlas:
		var right_bottom_tile = get_tile_atlas(right_bottom_cords)
		var right_top_tile = get_tile_atlas(right_top_cords)
		if right_bottom_tile != AreaSettings.PATH.inner && right_top_tile != AreaSettings.PATH.inner:
			place_cell(right_coords, AreaSettings.PATH.right.standard)

func generate_corners(area_point: Vector2i) -> void:
	top_left_corner(area_point)
	top_right_corner(area_point)
	bottom_left_corner(area_point)
	bottom_right_corner(area_point)

func top_left_corner(area_point: Vector2i) -> void:
	var top_coords = Vector2i(area_point.x, area_point.y - 1)
	var left_coords = Vector2i(area_point.x - 1, area_point.y)
	var top_left_coords = Vector2i(area_point.x - 1, area_point.y - 1)
	var top_tile = get_tile_atlas(top_coords)
	var left_tile = get_tile_atlas(left_coords)
	if top_tile != AreaSettings.PATH.inner && left_tile != AreaSettings.PATH.inner:
		place_cell(top_left_coords, AreaSettings.PATH.left.top_inner)

func top_right_corner(area_point: Vector2i) -> void:
	var top_coords = Vector2i(area_point.x, area_point.y - 1)
	var right_coords = Vector2i(area_point.x + 1, area_point.y)
	var top_right_coords = Vector2i(area_point.x + 1, area_point.y - 1)
	var top_tile = get_tile_atlas(top_coords)
	var right_tile = get_tile_atlas(right_coords)
	if top_tile != AreaSettings.PATH.inner && right_tile != AreaSettings.PATH.inner:
		place_cell(top_right_coords, AreaSettings.PATH.right.top_inner)

func bottom_left_corner(area_point: Vector2i) -> void:
	var bottom_coords = Vector2i(area_point.x, area_point.y + 1)
	var left_coords = Vector2i(area_point.x - 1, area_point.y)
	var bottom_left_coords = Vector2i(area_point.x - 1, area_point.y + 1)
	var bottom_tile = get_tile_atlas(bottom_coords)
	var left_tile = get_tile_atlas(left_coords)
	if bottom_tile != AreaSettings.PATH.inner && left_tile != AreaSettings.PATH.inner:
		place_cell(bottom_left_coords, AreaSettings.PATH.left.bottom_inner)

func bottom_right_corner(area_point: Vector2i) -> void:
	var bottom_coords = Vector2i(area_point.x, area_point.y + 1)
	var right_coords = Vector2i(area_point.x + 1, area_point.y)
	var bottom_right_coords = Vector2i(area_point.x + 1, area_point.y + 1)
	var bottom_tile = get_tile_atlas(bottom_coords)
	var right_tile = get_tile_atlas(right_coords)
	if bottom_tile != AreaSettings.PATH.inner && right_tile != AreaSettings.PATH.inner:
		place_cell(bottom_right_coords, AreaSettings.PATH.right.bottom_inner)

func get_tile_atlas(coords: Vector2i) -> Vector2i:
	return tile_map.get_cell_atlas_coords(AreaSettings.LAYERS.ground, coords)

func place_cell(coords: Vector2i, cell_coords: Vector2i) -> void:
	if is_within_bounds(coords):
		tile_map.set_cell(AreaSettings.LAYERS.ground, coords, AreaSettings.PATH.source_id, cell_coords)

func is_within_bounds(coords: Vector2i) -> bool:
	return coords.x >= 0 and coords.x < AreaSettings.WIDTH and coords.y >= 0 and coords.y < AreaSettings.HEIGHT
