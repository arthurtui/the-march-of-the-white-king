extends CanvasLayer

signal win_screen_ended

onready var battles_label = $Banner/BattlesLabel
onready var dismiss_label = $DismissLabel
onready var gold_label = $Banner/GoldContainer/GoldLabel
onready var change_label = $Banner/GoldContainer/GoldLabel/ChangeLabel
onready var change_label_tween = $Banner/GoldContainer/GoldLabel/ChangeLabel/ChangeLabelTween
onready var tween = $Tween
onready var screen_fade = $ScreenFade
onready var win_label = $ScreenFade/WinLabel
onready var lose_label = $ScreenFade/LoseLabel
onready var play_again = $ScreenFade/LoseLabel/PlayAgainButton

const TWEEN_DURATION := .8
const TWEEN_HEIGHT := 50
const GOLD_FONT_COLOR := Color("c8c8c8")
const GOLD_FONT_COLOR_ERROR := Color("850000")
const SCREEN_FADE_ALPHA := .8
const WIN_SCREEN_DELAY := .8


func set_battles_won(amount:int):
	battles_label.text = str(" Battles won: ", amount)


func set_gold_value(amount:int):
	gold_label.text = str(amount)


func change_gold_value(new_gold_value:int, change_amount:int):
	gold_label.text = str(new_gold_value)
	
	var change = change_label.duplicate()
	change.text = str("+") if change_amount > 0 else str("")
	change.text += str(change_amount)
	gold_label.add_child(change)
	change.show()
	
	change_label_tween.interpolate_property(change, "modulate:a", 1, 0,
			TWEEN_DURATION, Tween.TRANS_QUART, Tween.EASE_IN)
	change_label_tween.interpolate_property(change, "rect_position:y", null,
			change.rect_position.y + TWEEN_HEIGHT, TWEEN_DURATION,
			Tween.TRANS_QUART, Tween.EASE_OUT)
	change_label_tween.start()


func not_enough_gold_animation():
	tween.stop_all()
	tween.interpolate_property(gold_label, "custom_colors/font_color",
			GOLD_FONT_COLOR_ERROR, GOLD_FONT_COLOR, TWEEN_DURATION*2,
			Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()


func show_dismiss_label(amount:int):
	if amount:
		dismiss_label.text = str("+", amount)
	else:
		dismiss_label.text = "Can't sell this unit"
	dismiss_label.show()


func show_dismiss_recruit():
	dismiss_label.text = "Can only dismiss units you've recruited"
	dismiss_label.show()


func hide_dismiss_label():
	dismiss_label.hide()


func win():
	screen_fade.show()
	win_label.show()
	tween.interpolate_property(screen_fade, "modulate:a", 0, SCREEN_FADE_ALPHA,
			TWEEN_DURATION)
	tween.start()
	
	yield(tween, "tween_completed")
	yield(get_tree().create_timer(WIN_SCREEN_DELAY), "timeout")
	
	tween.interpolate_property(screen_fade, "modulate:a", null, 0, TWEEN_DURATION)
	tween.start()
	
	yield(tween, "tween_completed")
	
	screen_fade.hide()
	win_label.hide()
	emit_signal("win_screen_ended")


func lose():
	screen_fade.show()
	lose_label.show()
	tween.interpolate_property(screen_fade, "modulate:a", 0, SCREEN_FADE_ALPHA,
			TWEEN_DURATION)
	tween.start()
	
	yield(tween, "tween_completed")
	
	play_again.disabled = false


func _on_ChangeLabelTween_tween_completed(object, _key):
	change_label_tween.stop(object)
	object.queue_free()


func _on_Button_pressed():
	pass # Replace with function body.


func _on_PlayAgainButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
