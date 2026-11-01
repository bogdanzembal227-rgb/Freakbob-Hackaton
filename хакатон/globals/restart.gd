extends Node
var win
func _ready() -> void:
	win = get_tree().get_first_node_in_group("win")
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		AttacksManager.full_reload()
		if win:
			win.queue_free()
