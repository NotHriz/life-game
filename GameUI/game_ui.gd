extends CanvasLayer

func _ready() -> void:
	$Control/Age.text = "Age: " + "%.2f" % GameState.current_age + " Years"
	GameState.age_changed.connect(_update_age_label)
	_update_age_label()

func _update_age_label():
	$Control/Age.text = "Age: " + "%.2f" % GameState.current_age + " Years"
