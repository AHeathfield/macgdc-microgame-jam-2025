extends Sprite2D

var enemy3d : CharacterBody3D

func _process(_delta) -> void:
	if enemy3d == null:
		queue_free()
	else:
		global_position.x = enemy3d.global_position.x
		global_position.y = enemy3d.global_position.z
