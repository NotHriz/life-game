extends TileMapLayer

func _ready() -> void:
	# Fetch camera2d Node
	var camera = get_viewport().get_camera_2d()
	
	if (camera):
		# Get size of TileMap
		var rect = get_used_rect()
		var block_size = tile_set.tile_size
		
		# Set camera limit
		camera.limit_left = rect.position.x * block_size.x
		camera.limit_top = rect.position.y * block_size.y
		
		camera.limit_right = rect.end.x * block_size.x
		camera.limit_bottom = rect.end.y * block_size.y
		
