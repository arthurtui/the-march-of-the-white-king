extends Node

enum {WHITE, BLACK}

const COLORS = [Color("c8c8c8"), Color("1e1e1e")]
const COLOR_BUFF = Color()
const DAMAGED_BUFF = Color()

func opposite_side(side:int) -> int:
	return WHITE if side == BLACK else BLACK


func opposite_color(side:int) -> Color:
	return COLORS[opposite_side(side)]
