extends Area2D
class_name Hurtbox

func _ready() -> void:
	collision_layer = 0 
	collision_mask = 0
	set_collision_mask_value(2,true)
	area_entered.connect(on_area_entered)

func on_area_entered(area:Area2D):
	if area is Hitbox:
		owner.death()
