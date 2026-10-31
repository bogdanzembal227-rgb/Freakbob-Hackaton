extends CharacterBody2D

@export var max_speed := 420.0
@export var ground_accel := 3200.0
@export var ground_friction := 3600.0
@export var air_accel := 2200.0
@export var air_friction := 900.0

@export var jump_velocity := -720.0
@export var gravity := 2200.0
@export var fall_gravity_mult := 1.4
@export var jump_cut_mult := 0.45      
@export var max_fall_speed := 1100.0
@export var coyote_time := 0.1
@export var jump_buffer_time := 0.12

@export var wall_slide_speed := 140.0
@export var wall_jump_velocity := Vector2(520.0, -680.0)
@export var wall_jump_lock := 0.12

@export var dash_speed := 1100.0
@export var dash_time := 0.14
@export var dash_cooldown := 0.25
@export var air_dashes := 1
@export var dash_end_up_speed := -250.0

@export var ghost_interval := 0.03
@export var ghost_lifetime := 0.25
@export var ghost_color := Color(1, 1, 1, 0.6)
var ghost_timer := 0.0

var coyote_timer := 0.0
var buffer_timer := 0.0
var wall_lock_timer := 0.0
var dash_timer := 0.0
var dash_cd_timer := 0.0
var dash_dir := Vector2.ZERO
var dashes_left := 1
var facing := 1.0

@onready var sprite: AnimatedSprite2D = $Sprite2D



func _physics_process(delta: float) -> void:
	var input_x := Input.get_axis("move_left", "move_right")
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_x != 0.0:
		facing = signf(input_x)
	coyote_timer = coyote_time if is_on_floor() else coyote_timer - delta
	buffer_timer -= delta
	wall_lock_timer -= delta
	dash_cd_timer -= delta
	if Input.is_action_just_pressed("jump"):
		buffer_timer = jump_buffer_time
	if is_on_floor():
		dashes_left = air_dashes
		
	if dash_timer > 0.0:
		dash_timer -= delta
		_update_ghosts(delta, true)
		velocity = _dash_velocity()
		move_and_slide()
		if dash_timer <= 0.0:
			velocity.x *= 0.4
			velocity.y = clampf(velocity.y, dash_end_up_speed, max_fall_speed)
		_squash_stretch(delta)
		return

	if Input.is_action_just_pressed("dash") and dash_cd_timer <= 0.0 \
			and (is_on_floor() or dashes_left > 0):
		dash_dir = input_dir.normalized() if input_dir != Vector2.ZERO else Vector2(facing, 0)
		dash_timer = dash_time
		dash_cd_timer = dash_cooldown
		if not is_on_floor():
			dashes_left -= 1
		velocity = dash_dir * dash_speed
		move_and_slide()
		return

	var wall_dir := _get_wall_dir()
	var wall_sliding := not is_on_floor() and wall_dir != 0 and velocity.y > 0.0 \
			and input_x == float(wall_dir)

	if not is_on_floor():
		var g := gravity * (fall_gravity_mult if velocity.y > 0.0 else 1.0)
		velocity.y = minf(velocity.y + g * delta, max_fall_speed)
		if wall_sliding:
			velocity.y = minf(velocity.y, wall_slide_speed)

	if wall_lock_timer <= 0.0:
		var accel := ground_accel if is_on_floor() else air_accel
		var fric := ground_friction if is_on_floor() else air_friction
		if input_x != 0.0:
			var turn_boost := 1.8 if signf(velocity.x) != signf(input_x) and velocity.x != 0.0 else 1.0
			velocity.x = move_toward(velocity.x, input_x * max_speed, accel * turn_boost * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, fric * delta)

	if buffer_timer > 0.0:
		if coyote_timer > 0.0:
			velocity.y = jump_velocity
			buffer_timer = 0.0
			coyote_timer = 0.0
		elif wall_dir != 0 and not is_on_floor():
			velocity = Vector2(-wall_dir * wall_jump_velocity.x, wall_jump_velocity.y)
			facing = -wall_dir
			wall_lock_timer = wall_jump_lock
			buffer_timer = 0.0

	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut_mult

	move_and_slide()
	_squash_stretch(delta)
	_update_animation()


func _get_wall_dir() -> int:
	if is_on_wall_only():
		var n := get_wall_normal()
		return -int(signf(n.x)) 
	return 0

func _squash_stretch(delta: float) -> void:
	var target := Vector2.ONE
	if absf(velocity.y) > 200.0:
		target = Vector2(0.85, 1.2)
	elif absf(velocity.x) > 300.0:
		target = Vector2(1.1, 0.92)
	scale = scale.lerp(target, 14.0 * delta)

func _update_animation() -> void:
	if velocity.x < -10.0:
		sprite.flip_h = false
	elif velocity.x > 10.0:
		sprite.flip_h = true

	var anim := "default"
	#if velocity.y <-10.0 and not is_on_floor():
		#anim = "jump"
	if not is_on_floor() and _get_wall_dir() != 0 and velocity.y > 0.0 \
			and Input.get_axis("move_left", "move_right") == float(_get_wall_dir()):
		anim = "grab"
	elif absf(velocity.x) > 10.0 and is_on_floor():
		anim = "run"
	

	if sprite.animation != anim:
		sprite.play(anim)

func _dash_velocity() -> Vector2:
	var y_mult := 0.6 if dash_dir.y < 0.0 else 1.0
	return Vector2(dash_dir.x * dash_speed, dash_dir.y * dash_speed * y_mult)

func _spawn_ghost() -> void:
	var ghost := Sprite2D.new()
	ghost.texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	ghost.flip_h = sprite.flip_h
	ghost.centered = sprite.centered
	ghost.offset = sprite.offset
	ghost.modulate = ghost_color
	ghost.z_index = z_index - 1
	get_parent().add_child(ghost)               # parent is the level, so it stays behind
	ghost.global_transform = sprite.global_transform  # set AFTER add_child

	var tw := ghost.create_tween()
	tw.tween_property(ghost, "modulate:a", 0.0, ghost_lifetime)
	tw.tween_callback(ghost.queue_free)


func _update_ghosts(delta: float, active: bool) -> void:
	if not active:
		ghost_timer = 0.0
		return
	ghost_timer -= delta
	if ghost_timer <= 0.0:
		ghost_timer = ghost_interval
		_spawn_ghost()
