extends Node2D
class_name CardMovement

signal attack_finished
signal clicked
signal unclicked
signal hovered_dismiss_began(card)
signal hovered_dismiss_ended

onready var tween = $Tween

enum {PLAYER, ENEMY, RECRUIT}
enum SlotTypes {PLAYER, ENEMY, RECRUITMENT, DISMISS}

const HEIGHT := 200.0
const NO_TARGET := Vector2(-7, -7)
const SMOOTHING := .4
const EPSILON := .01
const ATTACK_DURATION := .5
const ATTACK_RECOIL_DURATION := .3
const DEATH_DURATION := .9

var type := PLAYER

# Unit
var unit_display : UnitDisplay

# Picking up
var can_pick := true
var picked_up := false
var original_position : Vector2
var target_position := NO_TARGET
var closest_slot


func _ready():
	original_position = global_position


func add_unit_display(new_unit_display:UnitDisplay):
	if unit_display:
		return
	
	unit_display = new_unit_display
	add_child(unit_display)
	
# warning-ignore:return_value_discarded
	unit_display.connect("gui_input", self, "_on_Unit_gui_input")
# warning-ignore:return_value_discarded
	unit_display.connect("mouse_entered", self, "_on_Unit_mouse_entered")
# warning-ignore:return_value_discarded
	unit_display.connect("mouse_exited", self, "_on_Unit_mouse_exited")


func _process(_delta):
	if picked_up:
		var old_closest_slot = closest_slot
		target_position = get_global_mouse_position()
		closest_slot = null
		var dist := INF
		for area in unit_display.overlapping_areas:
			var area_dist = global_position.distance_to(area.global_position)
			if area_dist < dist:
				dist = area_dist
				closest_slot = area.get_parent()
		
		if closest_slot == old_closest_slot:
			pass
		elif closest_slot and closest_slot.type == SlotTypes.DISMISS:
			emit_signal("hovered_dismiss_began", self)
		elif old_closest_slot and old_closest_slot.type == SlotTypes.DISMISS:
			emit_signal("hovered_dismiss_ended")
	
	elif global_position.distance_to(target_position) <= EPSILON:
		global_position = target_position
		target_position = NO_TARGET
		can_pick = true
	
	if target_position != NO_TARGET:
		global_position = lerp(global_position, target_position, SMOOTHING)


func damage(amount:int):
	unit_display.damage(amount)


func attack(card:CardMovement):
	z_index = Constants.SELECTED_CARD_INDEX
	original_position = global_position
	tween.interpolate_property(self, "global_position", null, card.global_position,
			ATTACK_DURATION, Tween.TRANS_BACK, Tween.EASE_IN)
	tween.start()
	
	yield(tween, "tween_completed")
	damage(card.unit_display.attack)
	card.damage(unit_display.attack)
	
	tween.interpolate_property(self, "global_position", null, original_position,
			ATTACK_RECOIL_DURATION, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	
	yield(tween, "tween_completed")
	emit_signal("attack_finished")
	z_index = Constants.CARD_INDEX


func die():
	tween.interpolate_property(self, "modulate:a", null, 0, DEATH_DURATION,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()
	
	yield(tween, "tween_completed")
	queue_free()


func set_target_position(new_target_position:Vector2):
	target_position = new_target_position
	can_pick = false


func pick_up() -> bool:
	if not can_pick:
		return false
	
	original_position = global_position
	picked_up = true
	z_index = Constants.SELECTED_CARD_INDEX
	return true


func let_go(new_target_position:Vector2):
	picked_up = false
	can_pick = false
	z_index = Constants.CARD_INDEX
	target_position = new_target_position


func _on_Unit_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			emit_signal("clicked", self)
		else:
			emit_signal("unclicked", self)


func _on_Unit_mouse_entered():
	unit_display.highlight()


func _on_Unit_mouse_exited():
	unit_display.unhighlight()
