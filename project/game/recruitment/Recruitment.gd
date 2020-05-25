extends Node2D
class_name Recruitment

signal battle_pressed

onready var dismiss_slot = $DismissSlot
onready var cost_labels = [$Elements/CostLabel1, $Elements/CostLabel2,
		$Elements/CostLabel3]
onready var slots = [$CardSlot1, $CardSlot2, $CardSlot3]

const SLOT_COLOR = Color("e4bd20")
const SIZE = 3


func set_costs():
	for i in range(SIZE):
		var slot := slots[i] as CardSlot
		var cost = slot.card.unit_display.cost
		cost_labels[i].text = str("Cost: ", cost)


func card_sold(card:CardMovement):
	var index := -1
	for i in range(SIZE):
		if slots[i].card == card:
			index = i
			slots[i].card = null
			break
	cost_labels[index].text = "-"
	slots[index].set_color(Constants.COLORS[Constants.WHITE])


func reset():
	for slot in slots:
		slot.set_color(SLOT_COLOR)


func _on_Battle_pressed():
	emit_signal("battle_pressed")
