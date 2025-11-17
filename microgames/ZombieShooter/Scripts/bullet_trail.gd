extends MeshInstance3D

var alpha = 1.0

# This makes sure each mat is unique, for some reason this is less laggy then setting material to local only
func _ready() -> void:
	var dup_mat = material_override.duplicate()
	material_override = dup_mat

# Followed this tutorial for this: https://www.youtube.com/watch?v=tryYXX30FGg
func init(start : Vector3, end : Vector3) -> void:
	var draw_mesh = ImmediateMesh.new()
	mesh = draw_mesh
	draw_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material_override)
	draw_mesh.surface_add_vertex(start)
	draw_mesh.surface_add_vertex(end)
	draw_mesh.surface_end() # Lets Godot know mesh is ready to be drawn


func _process(delta) -> void:
	alpha -= delta * 3.5
	material_override.albedo_color.a = alpha


func _on_timer_timeout():
	queue_free()
