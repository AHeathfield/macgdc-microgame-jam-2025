extends Microgame

@export var hit_duration : float = 0.5

# GUI
@onready var sub_viewport = $SubViewport
@onready var crosshair = $SubViewport/GUI/crosshair
@onready var hit_overlay = $SubViewport/GUI/HitOverlay

# World
@onready var player: CharacterBody3D = $SubViewport/World/player
@onready var nav_region_3d = $SubViewport/World/NavigationRegion3D
@onready var spawners = $SubViewport/World/spawners

var zombie = load("res://microgames/ZombieShooter/Scenes/zombie.tscn")
var zombie_inst

func _ready() -> void:
	super()
	set_process_unhandled_input(true)
	randomize() # Creates seed for random number generator
	# Position crosshair in center
	crosshair.position.x = sub_viewport.size.x / 2 - (32 * crosshair.scale.x)
	crosshair.position.y = sub_viewport.size.y / 2 - (32 * crosshair.scale.y)


# Because of the subview port, input events like this need to be handled here
# Basically this will send down the event to the player node so I can just keep the logic there
func _input(event):
	# fix by ArdaE https://github.com/godotengine/godot/issues/17326#issuecomment-431186323
	if event is InputEventMouse:
		var mouseEvent = event.duplicate()
		mouseEvent.position = get_global_transform_with_canvas().affine_inverse() * event.position
		player.unhandled_input(mouseEvent)
	else:
		player.unhandled_input(event)


func _process(_delta: float) -> void:
	
	var we_won := false
	var we_lost := false
	
	
	if we_won:
		win_game.emit()
	
	if we_lost:
		lose_game.emit()


func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)


func _on_player_player_hit():
	hit_overlay.visible = true
	await get_tree().create_timer(hit_duration).timeout
	hit_overlay.visible = false


func _on_spawn_timer_timeout():
	var spawn_point = _get_random_child(spawners).global_position
	zombie_inst = zombie.instantiate()
	zombie_inst.position = spawn_point
	zombie_inst.player = player
	nav_region_3d.add_child(zombie_inst)


func _on_player_enemy_hit():
	var hitmarker = $SubViewport/GUI/crosshair/hitmarker
	hitmarker.visible = true
	await get_tree().create_timer(0.3).timeout
	hitmarker.visible = false
