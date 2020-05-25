extends Node
class_name Game

onready var player_hand := $PlayerHand
onready var recruitment := $Recruitment
onready var battle := $Battle
onready var ui := $UI

enum States {RECRUITMENT, BATTLE}

# Unit and card scenes
const CARD = preload("res://game/board/CardMovement.tscn")
const WHITE_UNIT = preload("res://game/unit/WhiteUnit.tscn")
const KING = preload("res://data/units/king.tres")

const INITIAL_GOLD := 80
const BATTLE_DELAY := .3

# State
var state : int = States.RECRUITMENT
var unit_pool : Array

# Picking up cards
var picked_card : CardMovement = null

# Player stats
var battles_won := 0
var gold : int



func _ready():
	# Initial player hand
	var king_slot = player_hand.slots[4]
	var king_display = WHITE_UNIT.instance()
	
	add_card(king_slot, CardMovement.PLAYER)
	king_slot.card.add_unit_display(king_display)
	king_display.set_unit(KING)
	
	# Initial gold
	gold = INITIAL_GOLD
	ui.set_gold_value(gold)
	
	# Initial unit pool
	unit_pool = UnitDB.unit_pool.duplicate()
	
	# Recruitment step
	begin_recruitment()


func change_state(new_state:int):
	if state == new_state:
		return

	state = new_state

	if state == States.BATTLE:
		recruitment.hide()
		player_hand.hide()
		battle.show()
		
		clear_recruitment()
		battle.set_player(player_hand)
		battle.generate_battle(get_player_value())

		yield(get_tree().create_timer(BATTLE_DELAY), "timeout")
		battle.start()

	elif state == States.RECRUITMENT:
		battle.hide()
		recruitment.show()
		player_hand.show()
		
		battle.reset()
		begin_recruitment()


func begin_recruitment():
	add_new_recruits()
	recruitment.set_costs()


func add_new_recruits():
	unit_pool.shuffle()
	
	for i in range(recruitment.SIZE):
		var slot = recruitment.slots[i]
		var unit_display = WHITE_UNIT.instance()
		
		add_card(slot, CardMovement.RECRUIT)
		slot.card.add_unit_display(unit_display)
		unit_display.set_unit(unit_pool[i])


func clear_recruitment():
	for slot in recruitment.slots:
		if slot.card:
			unit_pool.append(slot.card.unit_display.unit)
			slot.card.queue_free()
			slot.card = null
	
	recruitment.reset()


func add_card(slot:CardSlot, card_type:int):
	var card = CARD.instance()
	card.type = card_type
	slot.add_child(card)
	slot.card = card
	
	card.connect("clicked", self, "_on_card_clicked")
	card.connect("unclicked", self, "_on_card_unclicked")
	card.connect("hovered_dismiss_began", self, "_on_card_hovered_dismiss_began")
	card.connect("hovered_dismiss_ended", self, "_on_card_hovered_dismiss_ended")


func get_player_value() -> int:
	var value = 1
	
	for slot in player_hand.slots:
		if slot.card:
			value += slot.card.unit_display.cost
	
	return value


func move_player_card(card:CardMovement, slot:CardSlot):
	var target_position = card.original_position
	
	if not slot:
		pass
	elif not slot.card:
		target_position = slot.global_position
		reparent_card(card, slot)
	elif slot.card != card:
		target_position = slot.global_position
		displace_player_cards(card, slot)
	
	card.let_go(target_position)


func reparent_card(card:CardMovement, slot:CardSlot):
	var global_pos = card.global_position
	card.get_parent().remove_child(card)
	slot.add_child(card)
	
	for hand_slot in player_hand.slots:
		if hand_slot.card == card:
			hand_slot.card = null
			break
	slot.card = card
	
	card.global_position = global_pos


func displace_player_cards(displacing_card:CardMovement, slot:CardSlot):
	var displacement := 1
	
	if displacing_card.original_position.x < slot.global_position.x:
		displacement = -1
	
	var displaced_card = slot.card
	var index = player_hand.slots.find(slot)
	reparent_card(displacing_card, slot)
	recursive_displacement(displaced_card, displacement,
			player_hand.slots[index + displacement])


func recursive_displacement(card:CardMovement, displacement:int, slot:CardSlot):
	if not slot.card:
		reparent_card(card, slot)
		card.set_target_position(slot.global_position)
	else:
		var index = player_hand.slots.find(slot)
		recursive_displacement(slot.card, displacement,
				player_hand.slots[index + displacement])
		reparent_card(card, slot)
		card.set_target_position(slot.global_position)


func buy_card(card:CardMovement, slot:CardSlot):
	if card.unit_display.cost > gold:
		ui.not_enough_gold_animation()
		card.let_go(card.original_position)
		return
	if player_hand.is_full():
		card.let_go(card.original_position)
		return
	
	# Update recruitment tab
	recruitment.card_sold(card)
	
	# Spend gold
	var cost = card.unit_display.cost
	gold -= cost
	ui.change_gold_value(gold, -cost)
	
	# Put card in hand
	card.type = CardMovement.PLAYER
	move_player_card(card, slot)


func sell_card(card:CardMovement):
	ui.hide_dismiss_label()
	if card.unit_display.cost == 0 or card.type == CardMovement.RECRUIT:
		card.let_go(card.original_position)
		return
	
	# Remove card from slot
	card.get_parent().remove_child(card)
	for slot in player_hand.slots:
		if slot.card == card:
			slot.card = null
			break
	
	# Gain gold
	var gold_gained = card.unit_display.dismiss_gold
	gold += gold_gained
	ui.change_gold_value(gold, gold_gained)
	
	# Put unit back into pool
	unit_pool.append(card.unit_display.unit)
	
	# Destroy card
	card.queue_free()


func _on_card_clicked(card:CardMovement):
	if state == States.BATTLE:
		return
	
	if not picked_card and card.pick_up():
		picked_card = card


func _on_card_unclicked(card:CardMovement):
	if state == States.BATTLE or card != picked_card:
		return
	
	picked_card = null
	
	var closest_slot := card.closest_slot as CardSlot
	if not closest_slot:
		card.let_go(card.original_position)
		return
	
	match card.type:
		card.PLAYER:
			match closest_slot.type:
				CardSlot.PLAYER:
					move_player_card(card, closest_slot)
				CardSlot.ENEMY:
					assert(false)
				CardSlot.RECRUITMENT:
					card.let_go(card.original_position)
				CardSlot.DISMISS:
					sell_card(card)
		card.RECRUIT:
			match closest_slot.type:
				CardSlot.PLAYER:
					buy_card(card, closest_slot)
				CardSlot.ENEMY:
					assert(false)
				CardSlot.RECRUITMENT:
					card.let_go(card.original_position)
				CardSlot.DISMISS:
					sell_card(card)
		card.ENEMY:
			assert(false)


func _on_card_hovered_dismiss_began(card:CardMovement):
	if card.type == CardMovement.PLAYER:
		ui.show_dismiss_label(card.unit_display.dismiss_gold)
	elif card.type == CardMovement.RECRUIT:
		ui.show_dismiss_recruit()


func _on_card_hovered_dismiss_ended():
	ui.hide_dismiss_label()


func _on_Recruitment_battle_pressed():
	change_state(States.BATTLE)


func _on_Battle_enemy_killed(unit:Unit):
	var gold_gained = unit.cost / 2
	gold += gold_gained
	ui.change_gold_value(gold, gold_gained)


func _on_Battle_lost():
	ui.lose()


func _on_Battle_won():
	battles_won += 1
	ui.set_battles_won(battles_won)
	ui.win()


func _on_UI_win_screen_ended():
	change_state(States.RECRUITMENT)
