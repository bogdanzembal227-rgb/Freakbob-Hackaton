extends Node2D
@export var button_scene: PackedScene = preload("uid://btroej48kbh8k")

@export_flags_2d_physics var surface_mask: int = 1
const ARENA := Vector2(750, 750)
const MIN_BUTTON_DIST := 100.0

var button_positions: Array[Vector2] = []

var effects: Dictionary[String,Dictionary]={
	"shield":{"Color":Color.VIOLET},
	"gravity":{"Color":Color.RED},
	"time_speed_up":{"Color": Color.ORANGE},
	"time_slow_down":{"Color": Color.BLUE},
	"blindness":{"Color":Color.GREEN},
	"ПЕРЕМОГА":{"Color":Color.YELLOW}
	}
var this_run_mix:Array[Color]
@onready var timer: Timer = $Timer
var i:float =0.0
func _ready() -> void:
	for key in effects:
		for k in effects[key]:
			this_run_mix.append( effects[key][k])
	this_run_mix.shuffle()
	AttacksManager.next_wave.connect(on_wave_changed)

func on_wave_changed():
	if AttacksManager.wave %3 ==0:
		spawn_button()
		


func spawn_button() -> void:
	var hit := _find_surface()
	if hit.is_empty() or i>=this_run_mix.size():
		return
	var button = button_scene.instantiate()
	button.color = this_run_mix[i]
	i += 1
	add_child(button)
	button.global_position = hit.position
	button.rotation = hit.normal.angle() + PI / 2.0
	button_positions.append(hit.position)

func _find_surface() -> Dictionary:
	var space := get_world_2d().direct_space_state
	for attempt in 30:
		var origin := global_position + Vector2(
			randf_range(30.0, ARENA.x - 30.0),
			randf_range(30.0, ARENA.y - 30.0))

		var point_query := PhysicsPointQueryParameters2D.new()
		point_query.position = origin
		point_query.collision_mask = surface_mask
		if not space.intersect_point(point_query, 1).is_empty():
			continue

		var dir := Vector2.from_angle(randf() * TAU)
		var ray := PhysicsRayQueryParameters2D.create(origin, origin + dir * 1000.0, surface_mask)
		var hit := space.intersect_ray(ray)
		if hit.is_empty():
			continue

		var too_close := false
		for p in button_positions:
			if p.distance_to(hit.position) < MIN_BUTTON_DIST:
				too_close = true
				break
		if too_close:
			continue

		return hit
	return {}

const EDGE_MARGIN := 40  

func _is_away_from_edge(hit: Dictionary, space: PhysicsDirectSpaceState2D) -> bool:
	var normal: Vector2 = hit.normal
	var tangent := normal.orthogonal()
	for side in [-1.0, 1.0]:
	
		var from: Vector2 = hit.position + tangent * side * EDGE_MARGIN + normal * 4.0
		var to: Vector2 = from - normal * 8.0
		var q := PhysicsRayQueryParameters2D.create(from, to, surface_mask)
		var h := space.intersect_ray(q)
		if h.is_empty():
			return false
		
		if h.normal.dot(normal) < 0.95:
			return false
	return true
