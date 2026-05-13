extends Node2D

# Preload cards
var card_scene = preload("res://cards/card.tscn")

func _ready() -> void:
	deal_hand()

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
	
func deal_hand():
	var cards = load_all_cards()
	for data in cards:
		var card = card_scene.instantiate()
		$CardHand.add_child(card)
		card.setup(data)
		card.card_played.connect(_on_card_played)

func _on_card_played(data: CardData):
	# Check if user have enough age to play
	if GameState.current_age < data.cost:
		print("not enough years!")
		return
		
	# Deduct user age from cost
	GameState.current_age -= data.cost
	print("played: ", data.card_name)
