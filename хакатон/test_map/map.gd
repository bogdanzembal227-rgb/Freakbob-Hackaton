extends Node2D
#
#@export var ghost_scene: PackedScene = preload("uid://btombpl6oh2pf")
#
#func _unhandled_input(event: InputEvent) -> void:
	#if Input.is_action_just_pressed("restart"):
		#History.last_try = History.this_try
		#spawn_ghost()
		#History.this_try.clear()
		#
		#
#
#func spawn_ghost():
	#var ghost = ghost_scene.instantiate()
	#ghost.path = History.last_try.duplicate()
	#print(ghost.path)
	#add_child(ghost)
