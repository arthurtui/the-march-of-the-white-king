extends Node2D
class_name Battle

signal enemy_killed(unit)
signal won
signal lost

onready var enemy_hand = $EnemyHand
onready var player_hand = $PlayerHand

const DIFFICULTY_RAMP := 20
const TURN_DELAY := 1.2
const CARD := preload("res://game/board/CardMovement.tscn")
const BLACK_UNIT := preload("res://game/unit/BlackUnit.tscn")
const WHITE_UNIT := preload("res://game/unit/WhiteUnit.tscn")

var difficulty := 0
var turn := Constants.WHITE
var white_index := -1
var black_index := -1
var king_died := false


func _ready():
	var all_slots := (enemy_hand.slots + player_hand.slots) as Array
	for slot in all_slots:
		slot.area.monitoring = false
		slot.area.monitorable = false


func reset():
	var all_slots := (enemy_hand.slots + player_hand.slots) as Array
	for slot in all_slots:
		if slot.card:
			slot.card.queue_free()
			slot.card = null
	
	turn = Constants.WHITE
	white_index = -1
	black_index = -1


func set_player(original_player_hand:Hand):
	for i in range(Hand.SIZE):
		if original_player_hand.slots[i].card:
			var unit = original_player_hand.slots[i].card.unit_display.unit
			add_card(unit, player_hand.slots[i], WHITE_UNIT, CardMovement.PLAYER)


func generate_battle(player_value:int):
	var pool = UnitDB.unit_pool.duplicate()
	var value = player_value + difficulty
	var slots = enemy_hand.slots.duplicate()
	
	pool.shuffle()
	slots.shuffle()
	
	while value > 0 and slots.size():
		var unit := pool.pop_front() as Unit
		var slot := slots.pop_front() as CardSlot
		add_card(unit, slot, BLACK_UNIT, CardMovement.ENEMY)
		value -= unit.cost


func add_card(unit:Unit, slot:CardSlot, unit_display_scene:PackedScene, card_type:int):
	var card = CARD.instance()
	var unit_display = unit_display_scene.instance()
	card.type = card_type
	slot.add_child(card)
	slot.card = card
	card.add_unit_display(unit_display)
	unit_display.set_unit(unit)


func start():
	new_turn()


func new_turn():
	var hand : Hand
	var opposing_hand : Hand
	var index : int
	var attacking_card : CardMovement
	
	if turn == Constants.WHITE:
		hand = player_hand
		opposing_hand = enemy_hand
		white_index += 1
		index = white_index
	else:
		hand = enemy_hand
		opposing_hand = player_hand
		black_index += 1
		index = black_index
	
	attacking_card = hand.slots[index].card
	while not attacking_card:
		index += 1
		index %= Hand.SIZE
		if hand.slots[index].card:
			attacking_card = hand.slots[index].card
			if turn == Constants.WHITE:
				white_index = index
			else:
				black_index = index
	
	var target_pool := []
	for slot in opposing_hand.slots:
		if slot.card:
			var unit = slot.card.unit_display.unit
			for _i in range(unit.influence):
				target_pool.append(slot.card)
	
	target_pool.shuffle()
	attacking_card.attack(target_pool.pop_front())
	
	yield(attacking_card, "attack_finished")
	end_turn()


func end_turn():
	yield(get_tree().create_timer(TURN_DELAY), "timeout")
	kill_units()
	if not check_victory():
		turn = Constants.BLACK if turn == Constants.WHITE else Constants.WHITE
		new_turn()


func kill_units():
	var unit_slots := (player_hand.slots + enemy_hand.slots) as Array
	for slot in unit_slots:
		if slot.card and slot.card.unit_display.armor <= 0:
			if slot.card.type == CardMovement.ENEMY:
				emit_signal("enemy_killed", slot.card.unit_display.unit)
			elif slot.card.type == CardMovement.PLAYER:
				king_died = slot.card.unit_display.unit.type == Constants.UnitTypes.King
			slot.card.die()
			slot.card = null


func check_victory() -> bool:
	if king_died:
		emit_signal("lost")
		return true
	elif enemy_hand.is_empty():
		emit_signal("won")
		difficulty += DIFFICULTY_RAMP
		return true
	
	return false
