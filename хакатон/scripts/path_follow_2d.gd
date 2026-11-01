extends PathFollow2D

@export var speed := 200.0

func _ready() -> void:
	loop = true
	rotates = false
	progress_ratio = randf()

func _process(delta: float) -> void:
	progress += speed * delta
