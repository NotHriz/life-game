extends Resource
class_name CardData

@export var card_name: String = ""
@export var description: String = ""
@export var cost: float = 0.5
@export var dice_count: int = 1
@export var dice_type: int = 6
@export var card_color: Color = Color.GRAY
@export var card_type: String = "attack"  # attack / defense / heal
