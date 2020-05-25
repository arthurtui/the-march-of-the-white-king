extends Panel
class_name UnitDisplay

onready var rarity_icon = $RarityBorder/RarityIcon
onready var unit_image = $MarginContainer/VBoxContainer/MarginContainer/UnitImage
onready var armor_container = $MarginContainer/VBoxContainer/BottomBar/HBoxContainer/ArmorContainer
onready var attack_container = $MarginContainer/VBoxContainer/BottomBar/HBoxContainer/AttackContainer
onready var influence_container = $MarginContainer/VBoxContainer/BottomBar/HBoxContainer/InfluenceContainer

export(int, "White", "Black") var side := Constants.WHITE
export(Resource) var unit

const PANEL_NORMAL = [preload("res://assets/themes/white_card.tres"),
		preload("res://assets/themes/black_card.tres")]
const PANEL_HIGHLIGHT = [preload("res://assets/themes/white_card_selected.tres"),
		preload("res://assets/themes/black_card_selected.tres")]
const RARITY_GEMS = [preload("res://assets/images/gems/gem_gray.png"),
		preload("res://assets/images/gems/gem_blue.png"),
		preload("res://assets/images/gems/gem_purple.png")]

# Attributes
var max_armor : int
var armor : int
var attack : int
var influence : int
var cost : int
var dismiss_gold : int

# Picking up
var overlapping_areas := []


func set_unit(new_unit:Unit):
	unit = new_unit
	
	# Interface
	unit_image.texture = unit.white_side_texture if side == Constants.WHITE else\
			unit.black_side_texture
	rarity_icon.texture = RARITY_GEMS[unit.rarity]
	unit_image.hint_tooltip = str(unit.RARITY_STRING[unit.rarity], " ",
			unit.TYPE_STRING[unit.type])
	cost = unit.cost
# warning-ignore:integer_division
	dismiss_gold = cost / 2
	if cost:
		unit_image.hint_tooltip += str("\n\nCost: ", cost,
				" gold\n(Dismiss to get ", dismiss_gold, " gold)")
	else:
		unit_image.hint_tooltip += str("\n\nCan't sell this unit.\nIf this unit dies, you lose the game.")
	
	
	# Armor
	max_armor = unit.armor
	armor = max_armor
	armor_container.set_value(armor)
	
	# Attack
	attack = unit.attack
	attack_container.set_value(attack)
	
	# Influence
	influence = unit.influence
	influence_container.set_value(influence)


func damage(amount:int):
	armor_container.change_value(-amount)
	armor -= amount


func highlight():
	set("custom_styles/panel", PANEL_HIGHLIGHT[side])


func unhighlight():
	set("custom_styles/panel", PANEL_NORMAL[side])


func _on_Area_area_entered(area):
	overlapping_areas.append(area)


func _on_Area_area_exited(area):
	overlapping_areas.erase(area)
