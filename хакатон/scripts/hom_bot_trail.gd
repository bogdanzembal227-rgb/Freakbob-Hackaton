extends Line2D

@export var max_points := 10

func _ready() -> void:
	top_level = true
	global_position = Vector2.ZERO
	clear_points()

func _physics_process(_delta: float) -> void:
	add_point(get_parent().global_position)
	if get_point_count() > max_points:
		remove_point(0)
