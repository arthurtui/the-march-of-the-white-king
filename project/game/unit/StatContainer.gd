tool
extends Control

onready var animated_label = $AnimatedLabel
onready var label = $VBoxContainer/Label
onready var tween = $Tween

export(Color) var font_color = Color("c8c8c8") setget set_font_color
export(Color) var font_color_buff
export(Color) var font_color_damage

const TWEEN_DURATION := .8
const TWEEN_HEIGHT := 10

var value : int
var original_value : int


func _ready():
	pass


func set_font_color(new_color:Color):
	font_color = new_color
	$VBoxContainer/Label.set("custom_colors/font_color", font_color)


func set_value(new_value:int):
	value = new_value
	original_value = value
	label.text = str(value)


func change_value(amount:int):
	if amount == 0:
		return
	
	animate_change(amount)
	value += amount
	label.text = str(value)
	
	if value > original_value:
		label.set("custom_colors/font_color", font_color_buff)
	elif value < original_value:
		label.set("custom_colors/font_color", font_color_damage)
	else:
		label.set("custom_colors/font_color", font_color)


func animate_change(amount:int):
	var new_label = animated_label.duplicate()
	if amount > 0:
		new_label.text = str("+", amount)
		new_label.set("custom_colors/font_color", Color.green)
	else:
		new_label.text = str(amount)
		new_label.set("custom_colors/font_color", Color.red)
	new_label.show()
	add_child(new_label)
	
	tween.interpolate_property(new_label, "modulate:a", 1, 0, TWEEN_DURATION,
			Tween.TRANS_QUART, Tween.EASE_IN)
	tween.interpolate_property(new_label, "rect_position:y", null,
			rect_position.y - TWEEN_HEIGHT, TWEEN_DURATION, Tween.TRANS_QUART,
			Tween.EASE_OUT)
	tween.start()


func _on_Tween_tween_completed(object, _key):
	tween.stop(object)
	object.queue_free()
