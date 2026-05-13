extends CharacterBody2D

const GRAVITY := 600
var health := 20

func _ready() -> void:
	$ProgressBar.max_value = health
	$ProgressBar.value = health

func _physics_process(delta: float) -> void:
	
	# Make character fall
	if (not is_on_floor()):
		velocity.y = GRAVITY
	
	move_and_slide()
	
