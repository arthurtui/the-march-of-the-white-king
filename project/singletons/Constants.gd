extends Node

enum {WHITE, BLACK}
enum UnitTypes {Pawn, Knight, Bishop, Rook, Queen, King}

# COLORS
const COLORS = [Color("c8c8c8"), Color("1e1e1e")]

# Z-INDICES
const CARD_INDEX = -2
const SELECTED_CARD_INDEX = -1


func _ready():
	randomize()


func opposite_side(side:int) -> int:
	return WHITE if side == BLACK else BLACK


func opposite_color(side:int) -> Color:
	return COLORS[opposite_side(side)]
