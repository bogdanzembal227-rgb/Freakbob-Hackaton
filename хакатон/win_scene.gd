extends Control

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("restart"):
		queue_free()
