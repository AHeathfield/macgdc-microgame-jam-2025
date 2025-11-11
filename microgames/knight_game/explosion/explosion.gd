extends Sprite2D

func _ready():
	$AnimationPlayer.play("explode")
	$AudioStreamPlayer2D.play()
	
func _on_audio_stream_player_2d_finished():
	queue_free()
