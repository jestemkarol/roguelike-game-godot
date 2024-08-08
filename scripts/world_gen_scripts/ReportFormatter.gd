extends RefCounted

class_name ReportFormatter

func log_report(cliffs_array: Array, grass_array: Array, paths_array: Array, trees_array: Array, map_size: int, cliff_density_reached: bool, seed: int) -> void:
	var tiles_no_arr = [cliffs_array.size(), grass_array.size(), paths_array.size(), trees_array.size()]
	var land_density = float(grass_array.size()) / float(map_size) * 100.0
	if cliff_density_reached:
		print('[WORLD-GEN]: Too many cliffs ffs! No. reached after cutoff: ', cliffs_array.size())
	print('[WORLD-GEN]: Generated %s cliff tiles, %s grass tiles, %s path tiles, %s trees tiles' % tiles_no_arr)
	print('[WORLD-GEN]: Map size: ', map_size)
	print('[WORLD-GEN]: Land density: %s%%' % land_density)
	print('[WORLD-GEN]: Used seed: ', seed)
