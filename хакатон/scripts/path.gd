extends Path2D

@export var saw_scene: PackedScene 

func _ready() -> void:
	var offset = randf() * curve.get_baked_length()
	var local_pos = curve.sample_baked(offset)
	#var saw = saw_scene.instantiate()
	#saw.position = local_pos
	#add_child(saw)
