class_name Missile
extends CharacterBody2D

@export var speed :float = 350.0
@export var turn_rate :float= 3.0 
@export var bounce_stun :float= 0.35      
@export var bounce_keep :float= 1.0        
@onready var target: Node2D = $"../../Character"
var stun_timer := 0.0
var exploded := false
var init_angle: float

func _ready() -> void:
	set_physics_process(false)
	await get_tree().create_timer(1.5).timeout
	set_physics_process(true)
	#init_angle = deg_to_rad(randf_range(-PI/5, PI/5))
	$Lifetime.start(10.0)

func _physics_process(delta: float) -> void:
	stun_timer -= delta
	if stun_timer <= 0.0 and is_instance_valid(target):
		var to_target := (target.global_position - global_position).angle()
		var diff := angle_difference(velocity.angle(), to_target)
		var step := clampf(diff, -turn_rate * delta, turn_rate * delta)
		velocity = Vector2.from_angle(velocity.angle() + step) * speed

	var hit = move_and_collide(velocity * delta)
	if hit:
		_handle_collision(hit)

	rotation = velocity.angle()


func _handle_collision(hit: KinematicCollision2D) -> void:
	var n = hit.get_normal()
	var other = hit.get_collider()
	
	if other is Missile:
		var rel = (velocity - other.velocity).dot(n)
		if rel < 0.0:
			var v1n := velocity.dot(n)
			var v2n: float = other.velocity.dot(n)
			velocity += n * (v2n - v1n)
			other.velocity += n * (v1n - v2n)
			other.stun_timer = bounce_stun
	else:
		var new_time = max($Lifetime.time_left - 2.0,0.5)
		$Lifetime.stop()
		$Lifetime.start(new_time)
		velocity = velocity.bounce(n) * bounce_keep

	stun_timer = bounce_stun


func _on_lifetime_timeout() -> void:
	explode()


func explode() -> void:
	#if exploded:
		#return
	#exploded = true
	#set_physics_process(false)
	#$CollisionShape2D.set_deferred("disabled", true)
	#$AnimationPlayer.play("explode")
	#await $AnimationPlayer.animation_finished
	queue_free()
