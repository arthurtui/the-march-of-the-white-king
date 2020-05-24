extends Panel
class_name Unit

onready var rarity_icon = $RarityBorder/RarityIcon

export(int, "White", "Black") var side := Constants.WHITE

var max_armor : int
var armor : int
var attack : int
var influence : int


func _ready():
	pass
