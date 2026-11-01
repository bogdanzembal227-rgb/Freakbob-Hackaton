# attack_director.gd  (autoload: AttacksManager)
extends Node2D

@export var projectile_scene: PackedScene = preload("uid://dne4yjqby1dfj")
@export var homing_scene: PackedScene = preload("uid://dwkxb77go1rf4")
@export var beam_scene: PackedScene = preload("uid://c0dumodt4uek6")
@export var saw_scene: PackedScene = preload("uid://cyi72qgi1cifo")

const ARENA := Vector2(750, 750)
const MARGIN := 50.0
const MIN_PLAYER_DIST := 200.0

const OPPOSITE := {
	"top": "bottom",
	"bottom": "top",
	"left_wall": "right_wall",
	"right_wall": "left_wall",
}

signal next_wave

var running := false
var run_id := 0
var wave := 0
var last_kind := -1
var bag: Array = []

var effect_waves_left := 0
var effect_pool: Dictionary = {}
var win_added := false


func start() -> void:
	
	if running:
		return
	running = true
	run_id += 1
	_loop(run_id)
	_saw_loop(run_id)

func stop() -> void:
	running = false
	run_id += 1                      # every old loop and timer callback becomes invalid
	get_tree().call_group("attack_node", "queue_free")
	for c in get_children():
		c.queue_free()
	bag.clear()
	last_kind = -1

func _alive(id: int) -> bool:
	return running and id == run_id

func _loop(id: int) -> void:
	await get_tree().create_timer(1.0).timeout
	while _alive(id):
		wave += 1
		_tick_effect()
		next_wave.emit()
		var kind := _next_kind()
		var wait := _launch(kind, id)
		var pause := maxf(0.5, 1.5 - wave * 0.1)
		await get_tree().create_timer(wait + pause).timeout

func _tick_effect() -> void:
	if effect_waves_left > 0:
		effect_waves_left -= 1
		if effect_waves_left == 0:
			Engine.time_scale = 1.0

# The saw runs independently: long life, short gap, then comes back.
func _saw_loop(id: int) -> void:
	while _alive(id) and wave < 2:
		await get_tree().create_timer(0.5).timeout
	while _alive(id):
		var life := randf_range(20.0, 30.0)
		_spawn_saw(life)
		await get_tree().create_timer(life + 5.0).timeout

# 0 = projectile wall, 1 = homing, 2 = beam
func _next_kind() -> int:
	if bag.is_empty():
		bag = [0, 1, 2]
		bag.shuffle()
		if bag.back() == last_kind:
			bag.reverse()
	last_kind = bag.pop_back()
	return last_kind

func _launch(kind: int, id: int) -> float:
	match kind:
		0:
			var side: String = ["top", "bottom", "left_wall", "right_wall"].pick_random()
			_spawn_wall(side)
			var double_chance := clampf((wave - 3) * 0.12, 0.0, 0.6)
			if randf() < double_chance:
				_spawn_wall(OPPOSITE[side])
			return 4.5
		1:
			var h := homing_scene.instantiate()
			h.amount = mini(2 + wave, 9)
			h.global_position = _random_point()
			_add(h, 16.0)
			return 4.0
		_:
			var count := 1 + int(wave / 6.0)
			for i in count:
				get_tree().create_timer(i * 1.4).timeout.connect(_spawn_beam.bind(id))
			return 3.0 + (count - 1) * 1.4

func _spawn_wall(side: String) -> void:
	var horizontal := side == "top" or side == "bottom"
	var variation: String = (["LR", "RL"] if horizontal else ["TB", "BT"]).pick_random()
	var wall := projectile_scene.instantiate()
	wall.setup(side, variation)
	_add(wall, 8.0)

func _spawn_beam(id: int) -> void:
	if not _alive(id):
		return
	for i in randi_range(1, 3):
		var b := beam_scene.instantiate()
		b.position = _random_point()
		_add(b, 6.0)

func _spawn_saw(life: float) -> void:
	var curve := Curve2D.new()
	for p in [Vector2.ZERO, Vector2(ARENA.x, 0), ARENA, Vector2(0, ARENA.y), Vector2.ZERO]:
		curve.add_point(p)
	var path := Path2D.new()
	path.curve = curve
	path.add_child(saw_scene.instantiate())
	_add(path, life)

func _random_point() -> Vector2:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var p := Vector2.ZERO
	for i in 10:
		p = Vector2(
			randf_range(MARGIN, ARENA.x - MARGIN),
			randf_range(MARGIN, ARENA.y - MARGIN))
		if player == null or to_global(p).distance_to(player.global_position) > MIN_PLAYER_DIST:
			break
	return p

func _add(n: Node, free_after: float) -> void:
	n.add_to_group("attack_node")
	add_child(n)
	get_tree().create_timer(free_after).timeout.connect(func():
		if is_instance_valid(n):
			n.queue_free())

func full_reload() -> void:
	stop()
	Engine.time_scale = 1.0
	get_tree().paused = false
	wave = 0
	effect_waves_left = 0
	effect_pool.clear()
	win_added = false

	get_tree().reload_current_scene()
	await get_tree().process_frame     # scene swap is deferred, wait for the new one
	await get_tree().process_frame
	start()
