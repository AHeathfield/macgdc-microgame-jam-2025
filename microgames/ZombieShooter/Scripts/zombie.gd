extends CharacterBody3D

@export var player : CharacterBody3D
@export var health : int = 100
@export var speed : float = 5.0
@export var damage: int = 50

@onready var nav_agent = $NavigationAgent3D
@onready var animation_tree = $AnimationTree


var state_machine
var left_arm_colliding : bool = false
var right_arm_colliding : bool = false

func _ready() -> void:
	state_machine = animation_tree.get("parameters/playback")


# Physics process is better for things that have physics aka collision since it relies on a set physics framerate (i.e. 60fps)
func _physics_process(delta) -> void:
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"Walk":
			# Navigation
			nav_agent.target_position = player.global_position
			var next_nav_path_pos = nav_agent.get_next_path_position()
			# No need to multiply by delta since move_and_slide() does this (note any acceleration needs to be multiplied by delta)
			velocity = (next_nav_path_pos - global_position).normalized() * speed
			
			# Looking in direction zombie moves
			if velocity != Vector3.ZERO:
				rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 5)
				#look_at(Vector3(global_position.x + velocity.x, global_position.y + velocity.y, global_position.z + velocity.z), Vector3.UP)
		"Attack":
			# Looking at player when attacking
			# keeping the y rotation same as zombie since it may mess up if looking at player
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	
	# Animation Conditions
	animation_tree.set("parameters/conditions/attack", _player_in_range())
	animation_tree.set("parameters/conditions/walk", !_player_in_range())
	
	move_and_slide()


func take_damage(damage_taken : int) -> void:
	health -= damage_taken
	var texture = $zombie/Skeleton3D/Head.get_active_material(0)
	texture.emission = Color(255, 0, 0)
	if health <= 0:
		queue_free()
	else:
		await get_tree().create_timer(0.3).timeout
		texture.emission = Color(0, 0, 0)


func _player_in_range() -> bool:
	return left_arm_colliding or right_arm_colliding


func _hit_finished() -> void:
	if left_arm_colliding or right_arm_colliding:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir, damage)


func _on_left_arm_area_3d_body_entered(body):
	if body.is_in_group("player"):
		left_arm_colliding = true

func _on_left_arm_area_3d_body_exited(body):
	if body.is_in_group("player"):
		left_arm_colliding = false

func _on_right_arm_area_3d_body_entered(body):
	if body.is_in_group("player"):
		right_arm_colliding = true

func _on_right_arm_area_3d_body_exited(body):
	if body.is_in_group("player"):
		right_arm_colliding = false
