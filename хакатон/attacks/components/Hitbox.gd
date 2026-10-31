extends Area2D
class_name Hitbox

func _ready() -> void:
	collision_layer = 0
	collision_mask = 0

	set_collision_layer_value(2,true)
