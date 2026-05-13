extends CharacterBody2D

const GRAVITY := 600

func _physics_process(delta: float) -> void:
	
	# Make character fall
	if (not is_on_floor()):
		velocity.y = GRAVITY
		
	# Face other way
	$AnimatedSprite2D.flip_h = true
	
	move_and_slide()
	
