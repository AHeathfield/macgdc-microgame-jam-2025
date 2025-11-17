extends Microgame

@export var hit_overlay_duration : float = 0.5

# GUI
@onready var sub_viewport = $SubViewport
@onready var crosshair = $SubViewport/GUI/crosshair
@onready var crosshair_animations = $SubViewport/GUI/crosshair/CrosshairAnimations
@onready var hit_overlay = $SubViewport/GUI/HitOverlay
@onready var healthbar = $SubViewport/GUI/Healthbar
@onready var radar_entities = $SubViewport/GUI/Radar/RadarViewPort/Entities

# World
@onready var player: CharacterBody3D = $SubViewport/World/player
@onready var nav_region_3d = $SubViewport/World/NavigationRegion3D
@onready var spawners = $SubViewport/World/spawners

var zombie = load("res://microgames/ZombieShooter/Scenes/zombie.tscn")
var radar_enemy = load("res://microgames/ZombieShooter/Scenes/radar_enemy.tscn")


func _ready() -> void:
	super()
	set_process_unhandled_input(true)
	randomize() # Creates seed for random number generator
	# Position crosshair in center
	crosshair.position.x = sub_viewport.size.x / 2 - (32 * crosshair.scale.x)
	crosshair.position.y = sub_viewport.size.y / 2 - (32 * crosshair.scale.y)
	# Creating starting radar enemies
	_create_radar_enemy($SubViewport/World/Zombie)


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


func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)

func _create_radar_enemy(enemy : CharacterBody3D) -> void:
	var radar_enemy_inst = radar_enemy.instantiate()
	radar_enemy_inst.enemy3d = enemy
	radar_entities.add_child(radar_enemy_inst)

func _on_player_player_hit():
	healthbar.value = player.health
	hit_overlay.visible = true
	await get_tree().create_timer(hit_overlay_duration).timeout
	hit_overlay.visible = false


func _on_spawn_timer_timeout():
	# Spawning zombie
	var spawn_point = _get_random_child(spawners).global_position
	var zombie_inst = zombie.instantiate()
	zombie_inst.position = spawn_point
	zombie_inst.player = player
	nav_region_3d.add_child(zombie_inst)
	
	# Creating corresponding radar enemy
	_create_radar_enemy(zombie_inst)


func _on_player_enemy_hit():
	crosshair_animations.play("HitMarker")


func _on_player_player_dead():
	lose_game.emit()
	$SubViewport/GUI/DeathScreen/DeathAnimation.play("DeathScreen")
