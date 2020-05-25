extends Node

var unit_pool := []

func _ready():
	var dir := Directory.new()
	var path := "res://data/units/"
	if not dir.open(path) == OK:
		print("UnitDB: Error while trying to access path ", path)
	else:
		if not dir.list_dir_begin() == OK:
			assert(false)
		var file_name := dir.get_next() as String
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() == "tres":
				var unit : Unit = load(str(path, file_name)) as Unit
				for _i in range(unit.number_in_pool):
					unit_pool.append(unit)
			
			file_name = dir.get_next()
