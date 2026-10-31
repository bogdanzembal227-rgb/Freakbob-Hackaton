extends CharacterBody2D
class_name Player

@export var speed: float = 700.0
@export var jump_velocity = -1000.0
@export var dash_speed:float = 1500.0
@export var rotation_speed:float = 0.5
var size: Vector2 = Vector2(65,65)
var last_dir: Vector2= Vector2.RIGHT
var is_dashing: bool = false
var momentum:Vector2 = Vector2.ZERO
var is_grabing_onto_wall: bool = false
var wall_side: float

@onready var pivot: Node2D = $Pivot
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const GRAVITY = 2400.0
const FALL_MULT = 3.0


func _physics_process(delta: float) -> void:
	#if velocity.x == 0:
		#animated_sprite_2d.animation = "default"
	#elif velocity.x != 0 and is_on_floor():
		#animated_sprite_2d.animation = "run"
	#if velocity.y<0: 
		#animated_sprite_2d.animation ="jump"
	#elif velocity.y>0:
		#animated_sprite_2d.animation ="fall"
	#gravity

	if not is_on_floor() and not is_dashing and not is_grabing_onto_wall:
		var g = GRAVITY
		if velocity.y > 0:
			g *= FALL_MULT
		velocity.y += g * delta
		velocity.y = min(velocity.y, 2400.0)
		

	#jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_grabing_onto_wall:
		velocity.y = jump_velocity
	#move
	if not is_dashing:
		var direction = Input.get_axis("move_left", "move_right")
		velocity.x = direction * speed
		
		#wall grab
		if is_on_wall() and not is_on_floor() and direction!=0:
			var wall_side = -sign(get_wall_normal().x)
			if direction == wall_side:
				is_grabing_onto_wall = true
				is_dashing = true
			else:
				is_grabing_onto_wall = false
				is_dashing = false
		else:
			is_grabing_onto_wall = false
			is_dashing = false

	#dash_stuff
	var dash_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dash_dir != Vector2.ZERO:
		last_dir = dash_dir
	if Input.is_action_just_pressed("dash") and not is_dashing and not is_grabing_onto_wall:
		dash(last_dir.normalized())
	if is_grabing_onto_wall:
			var wall_dir = -sign(get_wall_normal().x)
			velocity = Vector2(wall_dir* 10.0, 0)
			if Input.is_action_just_pressed("jump"):
				is_grabing_onto_wall = false
				is_dashing = false
				velocity = Vector2(-wall_dir * 3000.0, jump_velocity)
	momentum = momentum.move_toward(Vector2.ZERO, 10.0 * 100.0 * delta)
	velocity.x += momentum.x 
	

	
	move_and_slide()
	roll(delta)

func dash(dir: Vector2):
	is_dashing = true
	#var tween = create_tween()
	#tween.set_trans(Tween.TRANS_SINE)
	#tween.tween_property(self,"global_position",global_position+dir*dash_dist,0.1)
	#await tween.finished
	
	velocity =dash_speed*dir
	await get_tree().create_timer(0.1).timeout
	is_dashing = false
	velocity = dir * speed
	momentum = dir*700.0
	#rotation += velocity.x * delta / (size.x / 2.0)*rotation_speed

func roll(delta:float):
	if is_on_floor():
		if abs(velocity.x)>5.0:
			rotation += velocity.x * delta / (size.x / 2.0)*rotation_speed
		else:
			var target = round(rotation / (PI / 2.0)) * (PI / 2.0)
			rotation = lerp_angle(rotation, target, 50 * delta)
	elif not is_dashing:
		rotation += velocity.x * delta / size.x
