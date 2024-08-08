@tool
extends RefCounted

class_name Helpers

func make_unique(array: Array) -> Array:
	var unique_set = {}
	for element in array:
		unique_set[element] = true
	return unique_set.keys()
