extends CanvasLayer

func _ready() -> void:
	$Control/Age.text = "Age Remaining: "+ str(GameState.current_age) + " Years"

func _physics_process(delta: float) -> void:
	$Control/Age.text = "Age Remaining: "+ str(GameState.current_age) + " Years"
