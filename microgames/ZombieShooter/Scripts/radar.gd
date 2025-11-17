extends SubViewport

@export var player : CharacterBody3D

@onready var mini_player = $Entities/Player
@onready var background = $Background

# For 3D -> 2D, +x -> +x, +z -> +y, 
func _process(_delta):
	# For player icon
	mini_player.global_position.x = player.global_position.x
	mini_player.global_position.y = player.global_position.z
	mini_player.rotation = -player.rotation.y
	
	# Moving background so they will never see the default godot grey bg
	background.global_position = mini_player.global_position
	background.global_position.x -= background.size.x / 2
	background.global_position.y -= background.size.y / 2
