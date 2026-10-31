extends Node2D

@export var bullet_scene : PackedScene =preload("uid://24gsiqxilx53")
var sides: Dictionary = {
	"ceiling": {"start": Vector2.ZERO, "along": Vector2.RIGHT, "fire": Vector2.DOWN},
	"bottom": {"start": Vector2(0, 750), "along": Vector2.RIGHT, "fire": Vector2.UP},
	"left_wall": {"start": Vector2.ZERO, "along": Vector2.DOWN, "fire": Vector2.RIGHT},
	"right_wall": {"start": Vector2(750, 0), "along": Vector2.DOWN, "fire": Vector2.LEFT},
}

var along: Vector2
var fire_dir: = Vector2.DOWN

func setup(side: String,variation: String):
	var s = sides[side]
	along = s["along"]
	fire_dir = s["fire"]
	global_position = s["start"]
	if variation == "RL" or variation == "BT":
		global_position += along * 750.0
		along = -along

func _ready() -> void:
	var spacing := 20.0
	var offset := (750.0 / spacing)
	var count := int((750.0) / spacing)
	for i in count:
		var bullet = bullet_scene.instantiate()
		bullet.position = along * ( i * spacing) + fire_dir*offset
		bullet.direction = fire_dir
		bullet.rotation = fire_dir.angle() + PI/2
		add_child(bullet)
		await get_tree().create_timer(0.1).timeout
