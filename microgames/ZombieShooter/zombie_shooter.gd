extends Microgame

@onready var player: CharacterBody3D = $SubViewport/World/player

func _ready() -> void:
	super()
	set_process_unhandled_input(true)


# Because of the subview port, input events like this need to be handled here
func _input(event):
	# fix by ArdaE https://github.com/godotengine/godot/issues/17326#issuecomment-431186323
	if event is InputEventMouse:
		var mouseEvent = event.duplicate()
		mouseEvent.position = get_global_transform_with_canvas().affine_inverse() * event.position
		player.unhandled_input(mouseEvent)
	else:
		player.unhandled_input(event)


func _process(delta: float) -> void:
	
	var we_won := false
	var we_lost := false
	
	
	if we_won:
		win_game.emit()
	
	if we_lost:
		lose_game.emit()
