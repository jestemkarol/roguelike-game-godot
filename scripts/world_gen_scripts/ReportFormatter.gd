@tool

class_name ReportFormatter
extends RefCounted

const cliffs_msg = '[WORLD-GEN]: Too many cliffs ffs! No. reached after cutoff: '
const tiles_no_msg = """
[WORLD-GEN]: Generated:
%s cliff tiles,
%s grass tiles,
%s path tiles,
%s trees tiles,
%s water rocks
"""
const map_size_msg = '[WORLD-GEN]: Map size: '
const land_density_msg = '[WORLD-GEN]: Land density: %s%%'
const seed_msg = '[WORLD-GEN]: Used seed: '

func log_report(report_data: Dictionary) -> void:
	var tiles_no_arr = [
		report_data.cliffs_array.size(),
		report_data.grass_array.size(),
		report_data.paths_array.size(),
		report_data.trees_array.size(),
		report_data.water_rocks_array.size()
	]
	var land_density = float(report_data.grass_array.size()) / float(report_data.map_size) * 100.0
	if report_data.cliff_density_reached:
		print(cliffs_msg, report_data.cliffs_array.size())
	print(tiles_no_msg % tiles_no_arr)
	print(map_size_msg, report_data.map_size)
	print(land_density_msg % land_density)
	print(seed_msg, report_data.used_seed)

# TODO: Change prints to some simple logger
