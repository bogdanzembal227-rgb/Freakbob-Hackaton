extends Hitbox

@export var rotation_speed: float = 8.0

func _physics_process(delta: float) -> void:
	rotation -=rotation_speed*delta
