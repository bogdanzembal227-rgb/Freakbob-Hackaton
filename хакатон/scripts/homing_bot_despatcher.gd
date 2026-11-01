extends Node2D

@export var hom_bot_scene: PackedScene = preload("uid://dg20mue0jjn2n")
@export var amount: float = 10.0


func _ready() -> void:
	get_tree().get_first_node_in_group("player")
	
	for i in amount:
		var hom_bot = hom_bot_scene.instantiate()
		add_child(hom_bot)
		await get_tree().create_timer(0.2).timeout
