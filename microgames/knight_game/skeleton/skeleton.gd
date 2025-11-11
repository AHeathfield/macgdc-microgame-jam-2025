extends CharacterBody2D

@export var walk_speed : float = 100
@export var juke_chance : float = 0.5
@export var juke_after : float = 1
@export var juke_for : float = 1

var do_juke = false
var juking = false
var juke_time = 0

@onready var anim = $AnimationPlayer

func _ready():
	randomize()
	do_juke = juke_chance >= randf()


func _physics_process(delta):
	if juking:	velocity = Vector2.ZERO
	else:		velocity = Vector2.LEFT * walk_speed
	move_and_slide()
	
	if juking:	anim.play("idle")
	else:		anim.play("walk")
	
	if do_juke:
		juke_time += delta
		if juke_time >= juke_after + juke_for:
			juking = false
		elif juke_time >= juke_after:
			juking = true
