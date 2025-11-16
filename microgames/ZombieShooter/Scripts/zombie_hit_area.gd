extends Area3D

@export var damage_multiplier : float = 1.0
@onready var zombie = $"../../../.."

# Will send signal to the zombie 
func hit(damage : float) -> void:
	zombie.take_damage(damage * damage_multiplier)
