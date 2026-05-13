extends Control

var data: CardData

func setup(incoming_data: CardData):
	data = incoming_data
	$ColorRect.color = data.card_color
	$NameLabel.text = data.card_name
	$CostLabel.text = str(data.cost) + "yr"
	$DiceLabel.text = str(data.dice_count) + "d" + str(data.dice_type)
	$DescLabel.text = data.description

func play_card():
	if GameState.current_age < data.cost:
		print("not enough years!")
		return
	
	GameState.current_age -= data.cost
	var result = roll_dice()
	print("Rolled: ", result)
	return result

func roll_dice() -> int:
	var total = 0
	for i in data.dice_count:
		total += randi_range(1, data.dice_type)
	return total
