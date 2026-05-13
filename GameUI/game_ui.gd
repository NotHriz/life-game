extends CanvasLayer

func _ready() -> void:
	$Control/Age.text = "Age: "+ str(GameState.current_age) + " Years"
