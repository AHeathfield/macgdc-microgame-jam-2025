extends Node2D
class_name BombTimer

# This is the class used for the 
# bomb timer, try not to change 
# anything in here to make sure
# your microgame works correctly!

@onready var tick_timer : Timer = $TickTimer
@onready var bomb_line : Line2D = $BombLine
@onready var bomb_head : AnimatedSprite2D = $BombHead
@onready var bomb_flare : AnimatedSprite2D = $BombFlare
@onready var bomb_explode : Sprite2D = $BombExplode
@onready var number : AnimatedSprite2D = $Number
@onready var sfx_tick : AudioStreamPlayer = $Tick
@onready var sfx_tock : AudioStreamPlayer = $Tock

@onready var line_length = bomb_line.get_point_position(1).x
const last_flare_pos = Vector2(-16, -32)
const flare_offset = Vector2(10, -8)

var sfx_tick_flag = true
var tick_count = -1

signal exploded

func activate(secs: int):
	#await get_tree().create_timer(1.0).timeout
	tick_count = secs * 2
	tick_timer.start()
	
	bomb_line.clear_points()
	var last = Vector2.ZERO
	for i in tick_count - 1:
		var point = Vector2(remap(i, 0, tick_count - 1, 0, line_length), 0)
		bomb_line.add_point(point)
		last = point
	
	bomb_flare.position = last + flare_offset
	bomb_head.play("head1")
	
	number.visible = true
	bomb_head.visible = true
	bomb_flare.visible = true
	bomb_explode.visible = false
	

func deactivate():
	tick_count = -1
	tick_timer.stop()
	number.visible = false
	bomb_head.visible = false
	bomb_flare.visible = false
	bomb_explode.visible = true


func tick():
	tick_count -= 1
	
	# Play the sfx
	if  0 < tick_count and tick_count <= 3:
		(sfx_tick if sfx_tick_flag else sfx_tock).play()
		sfx_tick_flag = not sfx_tick_flag
		
	# Show the number
	if tick_count == 0:
		emit_signal("exploded")
		deactivate()
	elif tick_count == 1:
		number.play("1")
		bomb_head.play("head2")
	elif tick_count == 2:
		number.play("2")
	elif tick_count == 3:
		number.play("3")
	
	# Remove last bomb point
	if not bomb_line.points.is_empty():
		bomb_line.remove_point(bomb_line.get_point_count() - 1)
		
	# Set flare pos
	if bomb_line.points.is_empty():
		bomb_flare.position = last_flare_pos
	else:
		bomb_flare.position = bomb_line.get_point_position(bomb_line.get_point_count() - 1) + flare_offset
		# print(bomb_flare.position)


func _on_tick_timer_timeout():
	tick()
