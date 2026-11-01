extends Node2D

@export var target: Node2D
@export var max_reflections: int = 3
@export var max_length: float = 2500.0
@export_flags_2d_physics var collision_mask: int = 1
@onready var area: Hitbox = $Beam/Area2D

@onready var beam: Line2D = $Beam

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	target = get_tree().get_first_node_in_group("player")
	var dir = (target.global_position - global_position).normalized()
	layout_beam(global_position, dir)

#func _physics_process(_delta: float) -> void:
	#if is_instance_valid(target):
		#var dir := (target.global_position - global_position).normalized()
		#layout_beam(global_position, dir)

func layout_beam(origin: Vector2, dir: Vector2) -> void:
	var space := get_world_2d().direct_space_state
	var remaining := max_length

	beam.clear_points()
	beam.add_point(beam.to_local(origin))

	for i in max_reflections + 1:
		var query := PhysicsRayQueryParameters2D.create(
			origin, origin + dir * remaining, collision_mask)
		var hit := space.intersect_ray(query)

		if hit.is_empty():
			beam.add_point(beam.to_local(origin + dir * remaining))
			return
			
		var hit_pos: Vector2 = hit.position
		beam.add_point(beam.to_local(hit_pos))
		
		remaining -= origin.distance_to(hit_pos)
		if remaining <= 0.0:
			return
			
		dir = dir.bounce(hit.normal)
		origin = hit_pos + dir * 0.1
		await get_tree().create_timer(0.05).timeout
	await get_tree().create_timer(1.0).timeout
	attack()

func attack():
	$AudioStreamPlayer2D.play()
	for point in beam.points.size()-1:
		var width = 1.0
		var length = beam.points[point+1]-beam.points[point]
		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = RectangleShape2D.new()
		collision_shape.shape.size.x = length.length()
		collision_shape.shape.size.y = width
		collision_shape.global_position = beam.points[point] + length/2
		collision_shape.rotation = (beam.points[point+1]-beam.points[point]).angle()
		area.add_child(collision_shape)
	await get_tree().create_timer(0.4).timeout
	queue_free()
