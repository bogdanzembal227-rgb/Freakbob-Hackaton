extends Node2D

var effects: Dictionary[String,Dictionary]={
	"shield":{"Color":Color.VIOLET},
	"gravity":{"Color":Color.RED},
	"time_speed_up":{"Color": Color.ORANGE},
	"time_slow_down":{"Color": Color.BLUE},
	"blindness":{"Color":Color.GREEN},
	"ПЕРЕМОГА":{"Color":Color.YELLOW}
	}


func _ready() -> void:
	await get_tree().create_timer(5.0).timeout
	speed_up_time() 

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Hurtbox and area.owner.is_dashing:
		print("B")

func change_gravity():
	var side = randi_range(0,2)
	var map = get_tree().get_first_node_in_group("map_layout")
	var player = get_tree().get_first_node_in_group("player")
	AttacksManager.stop_all_attacks()
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

func speed_up_time():
	Engine.time_scale = 1.3
	await get_tree().create_timer(10.0)
	#score multiply

func slow_down_time():
	Engine.time_scale = 0.5
	await get_tree().create_timer(15.0)

func become_blind():
	pass
