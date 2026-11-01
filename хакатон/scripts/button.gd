extends Node2D

var color: Color = Color.YELLOW
var pressed := false
@onready var color_rect: ColorRect = $Area2D/ColorRect
@onready var point_light_2d: PointLight2D = $Area2D/ColorRect/PointLight2D

func _ready() -> void:
	color_rect.color = color
	point_light_2d.color = color
	if AttacksManager.effect_pool.is_empty() and not AttacksManager.win_added:
		AttacksManager.effect_pool = {
			shield:0,
			become_blind: 3,
			change_gravity: 0,
			slow_down_time: 5,
			speed_up_time: 2,
		}

func _on_area_2d_area_entered(area: Area2D) -> void:
	if pressed or not (area is Hurtbox and area.owner.is_dashing):
		return
	pressed = true
	$AudioStreamPlayer2D.play()
	color_rect.position.y += 8
	await get_tree().create_timer(0.05).timeout
	global_position.x +=10000
	var pool := AttacksManager.effect_pool
	if AttacksManager.wave > 4 and not AttacksManager.win_added:
		pool[win] = 0
		AttacksManager.win_added = true

	if pool.is_empty():
		return
	var effect: Callable = pool.keys().pick_random()
	AttacksManager.effect_waves_left = pool[effect]
	pool.erase(effect)
	effect.call()

func speed_up_time() -> void:
	Engine.time_scale = 1.2

func slow_down_time() -> void:
	Engine.time_scale = 0.5

func become_blind() -> void:
	var player = get_tree().get_first_node_in_group("player")
	player.get_node("PointLight2D").visible = true
	player.get_node("CanvasModulate").visible = true

func win() -> void:
	get_tree().paused  = true
	$"../../Label".visible = true


func change_gravity():
	var side = randi_range(0,2)
	var map = get_tree().get_first_node_in_group("map_layout")
	var player = get_tree().get_first_node_in_group("player")
	AttacksManager.stop()
	player.is_dashing = false
	var tween = create_tween()
	tween.tween_property(player,"global_position", map.player_spawn_point,1.5)
	var rot_tween = create_tween()
	if side == 0:
		rot_tween.tween_property(map,"rotation",map.rotation + PI/2,1.5)
	elif side == 1:
		rot_tween.tween_property(map,"rotation",map.rotation - PI/2,1.5)
	else:
		rot_tween.tween_property(map,"rotation",map.rotation + PI,1.5)
	await rot_tween.finished
	AttacksManager.start()

func shield() -> void:
	var player = get_tree().get_first_node_in_group("player")
	player.give_shield()
