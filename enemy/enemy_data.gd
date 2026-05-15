extends Resource
class_name EnemyData

@export var enemy_name: String = ""
@export var health: float = 20.0
@export var dice_count: int = 1
@export var dice_type: int = 6
@export var sprite: SpriteFrames
@export var enemy_type: String = "normal"  # normal / boss
