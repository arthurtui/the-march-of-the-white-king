tool
extends Node2D
class_name CardSlot

onready var area = $Area2D

enum {PLAYER, ENEMY, RECRUITMENT, DISMISS}

export(Color) var slot_color = Color("c8c8c8") setget set_color
export(int, "Player", "Enemy", "Recruitment", "Dismiss") var type = PLAYER

var card : CardMovement


func _ready():
	pass


func set_color(new_color:Color):
	slot_color = new_color
	$Polygon2D.color = slot_color
