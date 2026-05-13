extends Button

signal card_played(card_data)

var data: CardData

func setup(incoming_data: CardData):
	data = incoming_data
	$ColorRect.color = data.card_color
	$NameLabel.text = data.card_name
	$CostLabel.text = str(data.cost) + "yr"
	$DiceLabel.text = str(data.dice_count) + "d" + str(data.dice_type)
	$DescLabel.text = data.description
	$CardArt/TextureRect.texture = data.icon

func _on_pressed():
	emit_signal("card_played", data)
