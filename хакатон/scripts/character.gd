extends CharacterBody2D
class_name Player

@export var speed: float = 700.0
@export var jump_velocity = -500.0
@export var dash_dist:float = 300.0
var last_dir: Vector2= Vector2.RIGHT

var is_dashing: bool = false

const GRAVITY = 2400.0

const MAX_FALL = 900.0

const FALL_MULT = 1.6
const ACCEL = 3000.0 
const FRICTION = 4000.0       
const AIR_ACCEL = 12000.0      
const AIR_FRICTION = 800.0

func _physics_process(delta: float) -> void:
	#if velocity.x == 0:
		#animated_sprite_2d.animation = "default"
	#elif velocity.x != 0 and is_on_floor():
		#animated_sprite_2d.animation = "run"
	#if velocity.y<0: 
		#animated_sprite_2d.animation ="jump"
	#elif velocity.y>0:
		#animated_sprite_2d.animation ="fall"
		
		
	if not is_on_floor() and !is_dashing:
		var g = GRAVITY
		if velocity.y > 0:
			g *= FALL_MULT
		velocity.y += g * delta
		velocity.y = min(velocity.y, 900.0)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if !is_dashing:
		var direction = Input.get_axis("move_left", "move_right")
		velocity.x = direction * speed

	var dash_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dash_dir != Vector2.ZERO:
		last_dir = dash_dir
	if Input.is_action_just_pressed("dash"):
		dash(last_dir.normalized())

	move_and_slide()

func dash(dir: Vector2):
	is_dashing = true
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"global_position",global_position+dir*dash_dist,0.1)
	await tween.finished
	is_dashing = false
