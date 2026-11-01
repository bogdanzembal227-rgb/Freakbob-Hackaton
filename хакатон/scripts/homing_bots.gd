extends Hitbox

@export var speed = 400.0
@export var steer_force = 50.0
@export var turn_rate: float = 3.0

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
@onready var target = $"../Character"


#func _ready() -> void:
	#set_physics_process(false)
	#var i = randi_range(2,6)
	#await get_tree().create_timer(i).timeout
	#set_physics_process(true)

func seek():
	if not is_instance_valid(target):
		return Vector2.ZERO
	var desired = (target.global_position - global_position).normalized() * speed
	return (desired - velocity).normalized() * steer_force

func _physics_process(delta):
	if is_instance_valid(target):
		var to_target = (target.global_position - global_position).angle()
		var diff := angle_difference(velocity.angle(), to_target)
		var new_angle := velocity.angle() + clampf(diff, -turn_rate * delta, turn_rate * delta)
		velocity = Vector2.from_angle(new_angle) * speed
	rotation = velocity.angle()
	global_position += velocity * delta

func _on_Missile_body_entered(body):
	explode()

func _on_Lifetime_timeout():
	explode()

func explode():
	queue_free()
