extends CharacterBody2D

const GRAVITY := 600
var health : float = 20.0

func _ready() -> void:
	$ProgressBar.max_value = health
	$ProgressBar.value = health

func _physics_process(delta: float) -> void:
	
	# Make character fall
	if (not is_on_floor()):
		velocity.y = GRAVITY
	
	move_and_slide()
	
func take_damage(amount: float):
	print(amount)
	health -= amount
	
	# Update health bar
	$ProgressBar.value -= amount
	
	# Kill enemy if health 0 or below
	if health <= 0:
		print("enemy die")
		queue_free()
	
