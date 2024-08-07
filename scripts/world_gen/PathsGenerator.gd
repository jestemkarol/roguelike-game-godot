extends Node

class_name PathsGenerator

var tile_map: TileMap
var noise: Noise
var area_settings: AreaSettings

func _init(tile_map: TileMap, noise: Noise, area_settings: AreaSettings) -> void:
	self.tile_map = tile_map
	self.noise = noise
	self.area_settings = area_settings

func generate_paths(position: Vector2i) -> void:
	tile_map.set_cell(AreaSettings.LAYERS.ground, position, AreaSettings.PATH.source_id, AreaSettings.PATH.inner)
