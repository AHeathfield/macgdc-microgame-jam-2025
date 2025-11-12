extends CharacterBody3D

@export var walking_speed : float
@export var mouse_sens : float = 0.4
## This adds a gradual increase and decrease to movement speed
@export var lerp_speed : float = 15.0

@onready var head = $head

var current_speed = 5.0
var jump_velocity = 4.5
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
	if event is InputEventMouseMotion:
		# event.relative.x is the how much the mouse moves in the x direction, and this rotates the entire player
		# We need to invert it since left and rights were mixed up
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		# This will clamp the rotation so we don't snap neck...
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("keyboard_left", "keyboard_right", "keyboard_up", "keyboard_down")
	# See lerp_speed for desc
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
