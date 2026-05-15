extends Node2D

# Preload cards
var card_scene = preload("res://cards/card.tscn")
# Preload enemy
var enemy_scene = preload("res://enemy/enemy.tscn")
# Preload player
@onready var player: CharacterBody2D = $player

var enemy_just_spawned : bool = true
# Sound Preload
var card_select_sfx = load("res://assets/sound/Card select (mp3cut.net).wav")
var dragon_attack_sfx = load("res://assets/sound/DragonAttack.wav")
var ghost_attack_sfx = load("res://assets/sound/Ghost attack (mp3cut.net).wav")
var goblin_attack_sfx = load("res://assets/sound/goblin attack 2.mp3")
var wizard_attack_sfx = load("res://assets/sound/Wizard attack (mp3cut.net).wav")
var heal_sfx = load("res://assets/sound/heal.wav")
var sword_attack_sfx = load("res://assets/sound/sword attack (mp3cut.net).wav")

var enemy_pool: Array = []
var enemy = null

func _ready() -> void:
	deal_hand()
	# Add enemy to pool
	enemy_pool = load_all_enemy()
	spawn_enemy()
	
	# Randomize character starting age
	var age_max = randf_range(85, 110)
	GameState.max_age = age_max
	
	# Temporary OP Age
	# TODO: Remove
	GameState.max_age = 99999999
	

##########################################################
# Cards Section
##########################################################

# Load all cards
func load_all_cards() -> Array:
	var cards = []
	var dir = DirAccess.open("res://cards/card_data/")
	dir.list_dir_begin()
	var file = dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			cards.append(load("res://cards/card_data/" + file))
		file = dir.get_next()
	return cards

# Give initial hand
func deal_hand():
	var cards = load_all_cards()
	for data in cards:
		var card = card_scene.instantiate()
		$CardHand.add_child(card)
		card.setup(data)
		card.card_played.connect(_on_card_played)

# Play Card
func _on_card_played(data: CardData):
	# Disable all card while active
	set_cards_interactable(true)
	
	# Play card select sound
	play_sfx(card_select_sfx)
	
	# Add buffer so sound isnt spammy
	await get_tree().create_timer(0.5).timeout
	
	# Check if enemy still alive
	if (not enemy):
		return
	
	############### Player Turn ####################
	# Check if user have enough age to play
	if GameState.current_age + data.cost > GameState.max_age:
		print("You Died")
		return
		
	# Add user age from cost
	GameState.current_age += data.cost
	
	# Roll dice
	var result = roll_dice(data)
	var player_anim = ""
	var enemy_anim = ""
	match data.card_type:
		"attack":
			enemy.take_damage(result)
			player_anim = "attack"
			enemy_anim = "attack"
			play_sfx(sword_attack_sfx)
		"defence":
			GameState.shield = min(12, GameState.shield + result)
		"heal":
			GameState.current_age -= result
			player_anim = "heal"
			play_sfx(heal_sfx)
			
	# Play animation
	player.play_animation(player_anim)
	if (enemy):
		enemy.play_animation(enemy_anim)
	
	# Wait for animation to finish
	if (player_anim != ""):
		await player.animation_finished
	if (enemy_anim != ""):
		await enemy.animation_finished
		
	await get_tree().create_timer(0.5).timeout


	print("played: ", data.card_name) # For debugging purposes

	############### Enemy Turn ####################
	# Check again if player killed enemy
	if is_instance_valid(enemy) and not enemy_just_spawned:
		await enemy_attack()
	
	enemy_just_spawned = false
	
	# Added buffer so it isnt spammy
	await get_tree().create_timer(1.5).timeout
	
	# Check if enemy killed player
	if (GameState.current_age >= GameState.max_age):
		GameState.player_death.emit()
	else:
		set_cards_interactable(false)

# Roll Dice
func roll_dice(data: CardData):
	var sum := 0
	
	# Roll Dice for x amount of time
	for i in range(data.dice_count):
		sum += randi_range(1, data.dice_type)
	return sum

func set_cards_interactable(value: bool):
	for card in $CardHand.get_children():
		card.disabled = value
#################################################################
# Enemies Section
#################################################################

# Load all enemies
func load_all_enemy() -> Array:
	return [
		preload("res://enemy/enemy_data/wizard.tres"),
		preload("res://enemy/enemy_data/dragon.tres"),
		preload("res://enemy/enemy_data/ghost.tres"),
		preload("res://enemy/enemy_data/goblin.tres")
	]
	
	
# Spawn Enemy
func spawn_enemy():
	# Pick and remove from pool
	var data = enemy_pool.pop_back()
	
	# Spawn enemy
	var enemy_instance = enemy_scene.instantiate()
	add_child(enemy_instance)
	enemy_instance.position = $EnemySpawnPoint.position
	enemy_instance.setup(data)
	enemy_just_spawned = true
	enemy = enemy_instance
	
	# Spawn next enemy when current one dies
	enemy.enemy_death.connect(spawn_enemy)
	
func enemy_attack():
	var enemy_damage = enemy.data.damage
	var original_damage = enemy_damage
	# Caluclate shield if applicable (prevent -ve number)
	enemy_damage = max(0, enemy_damage - GameState.shield)
	GameState.shield = max(0, GameState.shield - original_damage)
	
	GameState.current_age += enemy_damage
	
	# Enemy attack animation
	enemy.play_attack_animation()
	var player_anim = ""
	match enemy.data.enemy_name:
		"goblin":
			player_anim = "goblin_attack"
			play_sfx(goblin_attack_sfx)
		"ghost":
			player_anim = "ghost_attack"
			play_sfx(ghost_attack_sfx)
		"dragon":
			player_anim = "dragon_attack"
			play_sfx(dragon_attack_sfx)
		"wizard":
			player_anim = "wizard_attack"
			play_sfx(wizard_attack_sfx)
	
	player.play_animation(player_anim)
	
	# Wait for animation to finish
	if (player_anim != ""):
		await player.animation_finished
		

# -------------------------- UTILITY -------------------------------
func play_sfx(sfx: AudioStream):
	var audio = AudioStreamPlayer.new()
	audio.stream = sfx
	add_child(audio)
	audio.play()
	# Auto cleanup when done
	audio.finished.connect(audio.queue_free)
