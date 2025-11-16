extends CharacterBody3D

@export var health : int = 100
@export var walk_speed : float = 5.0
@export var mouse_sens : float = 0.4
@export var bullet_damage: int = 25
## This adds a gradual increase and decrease to movement speed
@export var lerp_speed : float = 15.0
@export var hit_stagger : float = 5.0


@onready var head = $head
@onready var gun_animation = $head/Gun/AnimationPlayer
@onready var aim_ray = $head/AimRay

# signals
signal player_hit
signal player_dead
signal enemy_hit

var jump_velocity = 4.5
var hit_velocity : Vector3 = Vector3.ZERO
var direction : Vector3 = Vector3.ZERO

func _ready() -> void:
	# Locks the cursor in middle of screen and makes it invisible
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_sens /= 100 # just to work with more reasonable values


# Runs this code when node is freed https://docs.godotengine.org/en/stable/classes/class_object.html#class-object-constant-notification-predelete
func _notification(what):
	if (what == NOTIFICATION_PREDELETE):
		# Setting cursor back to normal once player goes bye bye
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func unhandled_input(event) -> void:
	if event is InputEventMouseMotion and health >= 0:
		# event.relative.x is the how much the mouse moves in the x direction, and this rotates the entire player
		# We need to invert it since left and rights were mixed up
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		# This will clamp the rotation so we don't snap neck...
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))


func _physics_process(delta: float) -> void:
	if health > 0:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		# Handle Shooting
		if Input.is_action_pressed("mouse_left"):
			_shoot()

		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jump_velocity

		# Get the input direction and handle the movement/deceleration.
		var input_dir := Input.get_vector("keyboard_left", "keyboard_right", "keyboard_up", "keyboard_down")
		# See lerp_speed for desc
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)
		if direction:
			velocity.x = direction.x * walk_speed
			velocity.z = direction.z * walk_speed
		else:
			velocity.x = move_toward(velocity.x, 0, walk_speed)
			velocity.z = move_toward(velocity.z, 0, walk_speed)
		
		# Adding enemy hit to velocity
		velocity += hit_velocity
		hit_velocity.x = move_toward(hit_velocity.x, 0, 0.1)
		hit_velocity.z = move_toward(hit_velocity.z, 0, 0.1)
		
		move_and_slide()


# Zombie will call this function
func hit(dir : Vector3, damage : int) -> void:
	health -= damage
	# signals UI to make screen red
	emit_signal("player_hit")
	hit_velocity.x = dir.x * hit_stagger
	hit_velocity.z = dir.z * hit_stagger
	if health <= 0:
		emit_signal("player_dead")
		_die()


func _die() -> void:
	$CollisionShape3D.disabled = true
	$AnimationPlayer.play("Death")

func _shoot() -> void:
	if !gun_animation.is_playing():
		gun_animation.play("Shoot")
		if aim_ray.is_colliding():
			var object_hit = aim_ray.get_collider()
			if object_hit.is_in_group("Enemy"):
				# Calling the hit() method on zombie
				object_hit.hit(bullet_damage)
				emit_signal("enemy_hit")
		
