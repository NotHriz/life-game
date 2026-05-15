extends CharacterBody2D

const GRAVITY := 600
signal animation_finished

func _ready() -> void:
	GameState.player_death.connect(_on_player_death)
	$AnimatedSprite2D.play("idle")

func _physics_process(delta: float) -> void:
	
	# Make character fall
	if (not is_on_floor()):
		velocity.y = GRAVITY
	
	move_and_slide()
	
# Play Death Animation
func _on_player_death():
	# Play player death animation
	$AnimatedSprite2D.play("dying")

# Play Animation
func play_animation(anim_name: String):
	if anim_name != "":
		$CardEffect.play(anim_name) 
		await $CardEffect.animation_finished
		animation_finished.emit()
	
