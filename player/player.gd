extends CharacterBody2D

const GRAVITY := 600

func _physics_process(delta: float) -> void:
	
	# Make character fall
	if (not is_on_floor()):
		velocity.y = GRAVITY
	
	move_and_slide()
	
