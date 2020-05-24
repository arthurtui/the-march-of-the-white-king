extends Panel
class_name UnitDisplay

onready var rarity_icon = $RarityBorder/RarityIcon

export(int, "White", "Black") var side := Constants.WHITE

const PANEL_NORMAL = [preload("res://assets/themes/white_card.tres"),
		preload("res://assets/themes/black_card.tres")]
const PANEL_HIGHLIGHT = [preload("res://assets/themes/white_card_selected.tres"),
		preload("res://assets/themes/black_card_selected.tres")]

var max_armor : int
var armor : int
var attack : int
var influence : int
var on := false


func _ready():
	pass


func _input(event):
	if event.is_action_pressed("ui_accept"):
		on = !on
		if on:
			set("custom_styles/panel", PANEL_NORMAL[side])
		else:
			set("custom_styles/panel", PANEL_HIGHLIGHT[side])
