extends Resource
class_name Unit

export(int, "Pawn", "Knight", "Bishop", "Rook", "Queen", "King") var type = 0
export(int, "Common", "Uncommon", "Rare") var rarity = 0
export(int) var attack = 1
export(int) var influence = 1
export(int) var armor = 1
export(int) var cost = 0
export(Texture) var white_side_texture
export(Texture) var black_side_texture
export(int) var number_in_pool = 0

const RARITY_STRING = ["Common", "Uncommon", "Rare"]
const TYPE_STRING = ["Pawn", "Knight", "Bishop", "Rook", "Queen", "King"]
