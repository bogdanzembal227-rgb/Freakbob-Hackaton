extends Player

var path: Array[Vector2]
var start_pos: Vector2
func _ready() -> void:
	is_player = false
	_ghost_loop()

var running := true

func _physics_process(delta: float) -> void:
	pass

func _ghost_loop() -> void:
	while running:
		start_pos = Vector2.ZERO
		for i in min(5, path.size()):
			global_position = start_pos
			if not running:
				return
			_move((path[i]-start_pos)/tile_size)
			start_pos = path[i]
			await get_tree().create_timer(0.5).timeout
		await get_tree().create_timer(0.4).timeout
