extends Hitbox

@export var speed:float = 1000.0
var direction: Vector2 = Vector2.RIGHT
func _ready() -> void:
	body_entered.connect(on_body_entered)
	set_collision_layer_value(1,true)
	set_physics_process(false)
	await get_tree().create_timer(1.5).timeout
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	position += speed*direction*delta

func on_body_entered(body:StaticBody2D):
	queue_free()
