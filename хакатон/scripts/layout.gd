extends Node2D

@export var player_spawn_point: Vector2 = Vector2(375,375)

func _ready() -> void:
	add_to_group("map_layout")
