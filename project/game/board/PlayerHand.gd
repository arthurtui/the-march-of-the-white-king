extends Node2D
class_name Hand

const SIZE := 8

var slots : Array


func _ready():
	slots = get_children()


func is_empty() -> bool:
	for slot in slots:
		if slot.card:
			return false
	
	return true


func is_full() -> bool:
	for slot in slots:
		if not slot.card:
			return false
	
	return true
