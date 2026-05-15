extends CharacterBody2D

const GRAVITY := 600
var health : int
var damage : float

var data: EnemyData

# Enemy death signal
signal enemy_death


func setup(incoming_data: EnemyData):
	data = incoming_data
	health = data.health
	$AnimatedSprite2D.sprite_frames = data.sprite
	$AnimatedSprite2D.play("idle")
	
	# Initialize health bar
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
		enemy_death.emit()
		queue_free()
		
