extends Node2D

# Preload cards
var card_scene = preload("res://cards/card.tscn")
# Preload enemy
var enemy_scene = preload("res://enemy/enemy.tscn")

var enemy_pool: Array = []
var enemy = null

func _ready() -> void:
	deal_hand()
	spawn_enemy()
	
	# Randomize character starting age
	var age_max = randf_range(85, 110)
	GameState.max_age = age_max
	

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
	# Check if enemy still alive
	if (not enemy):
		return
		
	# Check if user have enough age to play
	if GameState.current_age + data.cost > GameState.max_age:
		print("You Died")
		return
		
	# Add user age from cost
	GameState.current_age += data.cost
	
	# Roll dice
	var result = roll_dice(data)
	match data.card_type:
		"attack":
			enemy.take_damage(result)
		
	print("played: ", data.card_name) # For debugging purposes

# Roll Dice
func roll_dice(data: CardData):
	var sum := 0
	
	# Roll Dice for x amount of time
	for i in range(data.dice_count):
		sum += randi_range(1, data.dice_type)
	return sum

#################################################################
# Enemies Section
#################################################################

# Load all enemies
func load_all_enemy() -> Array:
	var enemies = []
	var dir = DirAccess.open("res://enemy/enemy_data/")
	dir.list_dir_begin()
	var file = dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			enemies.append(load("res://enemy/enemy_data/" + file))
		file = dir.get_next()
	return enemies
	
	
# Spawn Enemy
func spawn_enemy():
	# Refill pool if empty
	if enemy_pool.is_empty():
		enemy_pool = load_all_enemy()
		enemy_pool.shuffle()
		
	# Pick and remove from pool
	var data = enemy_pool.pop_back()
	
	# Spawn enemy
	var enemy_instance = enemy_scene.instantiate()
	add_child(enemy_instance)
	enemy_instance.position = $EnemySpawnPoint.position
	enemy_instance.setup(data)
	enemy = enemy_instance
	
	# Spawn next enemy when current one dies
	enemy.enemy_death.connect(spawn_enemy)
