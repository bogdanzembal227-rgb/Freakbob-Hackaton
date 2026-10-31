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
const WALL_JUMP_TIME = 0.3
var wall_jump_timer = 0.0
var wall_jump_dir = 0
const WALL_COYOTE_TIME = 0.35
var wall_coyote_timer = 0.0
var last_wall_normal_x = 0.0 
@export var dashes_left: float =2.0

@onready var pivot: Node2D = $Pivot
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const GRAVITY = 2400.0
const FALL_MULT = 3.0


func _physics_process(delta: float) -> void:
	#kolhoz
	var direction = Input.get_axis("move_left", "move_right")
	#try_wall_jump()
	#update_wall_grab(direction)
	update_dash()
	#
	#if is_grabing_onto_wall:
		#handle_wall_grab()
	if not is_dashing:
		if is_on_wall() and direction == -sign(get_wall_normal().x):
			velocity = Vector2.ZERO
		else:
			handle_gravity(delta)
		handle_jump()
		handle_horizontal_movement(direction)
	
	#momentum
	momentum = momentum.move_toward(Vector2.ZERO, 10.0 * 100.0 * delta)
	velocity.x += momentum.x 
	
	move_and_slide()
	#update_wall_coyote(direction)
	roll(delta)



func dash(dir: Vector2):
	if is_dashing or dashes_left <=0:
		return
	is_dashing = true
	dashes_left-=1
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
func handle_gravity(delta:float):
	var g = GRAVITY
	if velocity.y > 0:
		g *= FALL_MULT
	velocity.y += g * delta
	velocity.y = min(velocity.y, 2400.0)
func handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_grabing_onto_wall:
		velocity.y = jump_velocity
func update_dash():
	if is_on_floor() and dashes_left!=2:
		dashes_left = 2
	
	var dash_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dash_dir != Vector2.ZERO:
		last_dir = dash_dir
	if Input.is_action_just_pressed("dash") and not is_dashing and not is_grabing_onto_wall:
		dash(last_dir.normalized())
func handle_horizontal_movement(dir:float):
	velocity.x = dir*speed


##wall grab
func update_wall_grab(dir: float):
	if is_dashing :
		is_grabing_onto_wall = false
		return
	if is_on_wall() and not is_on_floor() and dir != 0:
		is_grabing_onto_wall = (dir == -sign(get_wall_normal().x))
	else:
		is_grabing_onto_wall = false
#func handle_wall_grab():
	#var wall_dir = -sign(get_wall_normal().x)
	#velocity = Vector2(wall_dir * 30, 0)
	#momentum = Vector2.ZERO
#
#func update_wall_coyote(delta):
	#if is_on_wall() and not is_on_floor():
		#last_wall_normal_x = get_wall_normal().x
		#wall_coyote_timer = WALL_COYOTE_TIME
	#else:
		#wall_coyote_timer = max(wall_coyote_timer - delta, 0.0)
#
#func try_wall_jump():
	#if Input.is_action_just_pressed("jump") and wall_coyote_timer > 0.0 and not is_on_floor():
		#wall_jump_dir = sign(last_wall_normal_x) 
		#wall_jump_timer = WALL_JUMP_TIME
		#wall_coyote_timer = 0.0
		#is_grabing_onto_wall = false
		#velocity = Vector2(wall_jump_dir * speed, jump_velocity)
