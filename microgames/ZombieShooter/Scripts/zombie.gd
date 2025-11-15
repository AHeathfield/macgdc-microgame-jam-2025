extends CharacterBody3D

@export var player : CharacterBody3D
@export var speed : float = 5.0
@export var attack_range : float = 2.5

@onready var nav_agent = $NavigationAgent3D
@onready var animation_tree = $AnimationTree

# Physics process is better for things that have physics aka collision since it relies on a set physics framerate (i.e. 60fps)
func _physics_process(_delta) -> void:
	velocity = Vector3.ZERO
	
	# Navigation
	nav_agent.target_position = player.global_position
	var next_nav_path_pos = nav_agent.get_next_path_position()
	# No need to multiply by delta since move_and_slide() does this (note any acceleration needs to be multiplied by delta)
	velocity = (next_nav_path_pos - global_position).normalized() * speed
	
	# keeping the y rotation same as zombie since it may mess up if looking at player
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	# Animation Conditions
	animation_tree.set("parameters/conditions/attack", _player_in_range())
	
	move_and_slide()


func _player_in_range() -> bool:
	return global_position.distance_to(player.global_position) <= attack_range
