extends Node

class_name Helpers

static func is_point_in_area(point: Vector2, a: Vector2, b: Vector2) -> bool:
	var min_x = min(a.x, b.x)
	var max_x = max(a.x, b.x)
	var min_y = min(a.y, b.y)
	var max_y = max(a.y, b.y)
	
	return min_x <= point.x and point.x <= max_x and min_y <= point.y and point.y <= max_y

static func get_random_point_in_area(top_left: Vector2i, bottom_right: Vector2i) -> Vector2i:
	var min_x = min(top_left.x, bottom_right.x)
	var max_x = max(top_left.x, bottom_right.x)
	var min_y = min(top_left.y, bottom_right.y)
	var max_y = max(top_left.y, bottom_right.y)
	
	var random_x = randi_range(min_x, max_x)
	var random_y = randi_range(min_y, max_y)
	
	return Vector2i(random_x, random_y)
