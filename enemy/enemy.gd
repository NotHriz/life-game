extends CharacterBody2D

const GRAVITY := 600
var health : int
var damage : float

var data: EnemyData

# Enemy death signal
signal enemy_death

signal animation_finished


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
		
# Play animation
func play_animation(anim_name: String):
	if anim_name != "":
		$CardEffect.play(anim_name) 
		await $CardEffect.animation_finished
		animation_finished.emit()
		
# Play attack animation
func play_attack_animation():
	$AnimatedSprite2D.play("attack")
	await $AnimatedSprite2D.animation_finished
	animation_finished.emit()
	
	play_idle()

# Play idle animation
func play_idle():
	$AnimatedSprite2D.play("idle")
