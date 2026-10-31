extends CharacterBody2D
class_name Player

const tile_size: Vector2= Vector2(16,16)
var sprite_node_pos_tween: Tween
var is_moving: bool = false
var is_player: bool = true

func _physics_process(delta: float) -> void:
	if not is_moving:
		if Input.is_action_just_pressed("ui_up") and !$up.is_colliding():
			_move(Vector2(0,-1))
		elif Input.is_action_just_pressed("ui_down") and !$down.is_colliding():
			_move(Vector2(0,1))
		elif Input.is_action_just_pressed("ui_left") and !$left.is_colliding():
			_move(Vector2(-1,0))
		elif Input.is_action_just_pressed("ui_right") and !$right.is_colliding():
			_move(Vector2(1,0))

func _move(dir: Vector2):
	is_moving = true
	global_position += dir*tile_size
	if is_player:
		History.this_try.append(global_position)
	$Sprite2D.global_position -= dir *tile_size

	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	var sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.set_trans(Tween.TRANS_SINE)
	sprite_node_pos_tween.tween_property($Sprite2D,"global_position",global_position,0.2)
	await sprite_node_pos_tween.finished
	is_moving = false


#func get_closest_tile_from_player():
	#var minimum_distance_tile: Vector2
	#minimum_distance_tile = History.this_try.pop_back() - History.last_try.pop_back()
	#for i in History.last_try.size():
		#if global_position - (Vector2.ZERO+History.last_try[i])<minimum_distance_tile:
			#minimum_distance_tile = History.last_try[i]
	#print("minimum_distance_tile")
	#return minimum_distance_tile 
