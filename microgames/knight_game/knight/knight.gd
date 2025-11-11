extends Area2D

@export var flash_color : Color 
@export var flash_cooldown : float

@onready var sprite : Sprite2D = $Sprite2D
@onready var anim : AnimationPlayer = $AnimationPlayer
var attacking : bool = false
var flashing : bool = false 
var flash_on : bool = false
var flash_time : float = 0.0

signal sword_hit(body)

func _on_sword_hitbox_body_entered(body):
	sword_hit.emit(body)

func _process(delta):
	if flashing:
		flash_time += delta
		if flash_time >= flash_cooldown:
			flash_time = 0.0
			flash_on = not flash_on
			sprite.self_modulate = flash_color if flash_on else Color.WHITE
			
	if not attacking and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		start_attack()
			
func start_attack():
	attacking = true
	anim.play("attack")
	
func finish_attack():
	attacking = false
	anim.play("idle")
	stop_flashing()
	
func start_flashing():
	flashing = true
	flash_on = false
	sprite.self_modulate = flash_color

func stop_flashing():
	flashing = false
	sprite.self_modulate = Color.WHITE
