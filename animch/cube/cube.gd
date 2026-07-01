extends CharacterBody2D

@export var unique_id: String = ""
@export var run_speed: float = 90.0
@export var min_wait_time: float = 1.0
@export var max_wait_time: float = 3.0
@export var path: NodePath

@onready var health_component: Node = $AnimatedSprite2D/Hurtbox/HealthComponent
@onready var feer_marker: Marker2D = $Marker2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

static var reserved_patrol_points: Dictionary = {}

var patrol_points: Array[Marker2D] = []
var current_point: int = -1
var reserved_point_key: String = ""
var target_position: Vector2 = Vector2.ZERO
var wait_timer: float = 0.0
var base_scale: Vector2 = Vector2.ONE

# Таймер для предотвращения застревания
var stuck_timer: float = 0.0

# Радиус, в котором NPC начинают расходиться.
@export var separation_radius: float = 45.0

# Сила отталкивания.
@export var separation_strength: float = 2.5

func _ready() -> void:
	add_to_group("damageable")
	add_to_group("npc")
	unique_id = str(get_path())
	
	if CheckpointManager.removed_objects.has(unique_id):
		queue_free()
		return

	var path_node := get_node_or_null(path)
	if path_node:
		for child in path_node.get_children():
			if child is Marker2D:
				patrol_points.append(child)

	if patrol_points.is_empty():
		set_physics_process(false)
		return

	_choose_next_free_target()
	sprite.play("idle")
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)

func _exit_tree() -> void:
	_release_reserved_target()

func _physics_process(delta: float) -> void:
	_run_patrol(delta)

func _run_patrol(delta: float) -> void:
	# Если свободных точек нет, NPC ждёт и периодически пробует забронировать цель.
	if reserved_point_key.is_empty():
		velocity = Vector2.ZERO
		stuck_timer = 0.0
		wait_timer -= delta
		if sprite.animation != "idle": sprite.play("idle")
		if wait_timer <= 0.0:
			_choose_next_free_target()
		move_and_slide()
		return

	# Состояние ожидания на забронированной точке.
	if wait_timer > 0.0:
		velocity = Vector2.ZERO
		wait_timer -= delta
		if sprite.animation != "idle": sprite.play("idle")
		if wait_timer <= 0.0:
			_choose_next_free_target()
		move_and_slide()
		return

	var dist := global_position.distance_to(target_position)

	# Условие "Дошли до точки" или "Застряли"
	# Если мы не можем дойти до точки за 5 секунд (stuck_timer), меняем её
	if dist <= 10.0:
		stuck_timer = 0.0
		velocity = Vector2.ZERO
		wait_timer = randf_range(min_wait_time, max_wait_time)
		move_and_slide()
		return
	elif stuck_timer > 5.0:
		_choose_next_free_target()
		move_and_slide()
		return

	# Логика движения
	if sprite.animation != "walk": 
		sprite.play("walk")
	
	var dir := global_position.direction_to(target_position)

	# Отталкивание от других NPC остаётся вспомогательной визуальной коррекцией,
	# а не основным способом развести NPC по разным целям.
	var separation := get_separation_force()

	# Небольшая случайность, чтобы NPC выглядели живее.
	var wander := Vector2(
		randf_range(-0.15, 0.15),
		randf_range(-0.15, 0.15)
	)

	var final_dir := dir + separation + wander

	if final_dir.length() > 0.01:
		final_dir = final_dir.normalized()

	velocity = final_dir * run_speed
	
	# Если мы двигаемся, но позиция почти не меняется (уперлись в стену)
	if velocity.length() > 0 and get_real_velocity().length() < 1.0:
		stuck_timer += delta
	else:
		stuck_timer = 0.0

	sprite.flip_h = velocity.x < 0.0
	move_and_slide()

func _choose_next_free_target() -> void:
	if patrol_points.is_empty():
		_release_reserved_target()
		return

	var previous_point := current_point
	_release_reserved_target()

	var next_point := _get_random_free_point_index(previous_point)
	if next_point == -1:
		current_point = previous_point
		wait_timer = randf_range(min_wait_time, max_wait_time)
		velocity = Vector2.ZERO
		return

	current_point = next_point
	_reserve_current_point()
	_set_target()

func _get_random_free_point_index(excluded_point: int) -> int:
	_cleanup_stale_reservations()

	var free_points: Array[int] = []
	for index in range(patrol_points.size()):
		if index == excluded_point and patrol_points.size() > 1:
			continue

		var point := patrol_points[index]
		if not is_instance_valid(point):
			continue

		if not _is_point_reserved_by_other(point):
			free_points.append(index)

	if free_points.is_empty() and patrol_points.size() == 1 and excluded_point == 0:
		var current_marker := patrol_points[excluded_point]
		if is_instance_valid(current_marker) and not _is_point_reserved_by_other(current_marker):
			free_points.append(excluded_point)

	if free_points.is_empty():
		return -1

	return free_points[randi() % free_points.size()]

func _reserve_current_point() -> void:
	if current_point < 0 or current_point >= patrol_points.size():
		reserved_point_key = ""
		return

	var point := patrol_points[current_point]
	if not is_instance_valid(point):
		reserved_point_key = ""
		return

	reserved_point_key = _get_point_key(point)
	reserved_patrol_points[reserved_point_key] = get_instance_id()

func _release_reserved_target() -> void:
	if reserved_point_key.is_empty():
		return

	if reserved_patrol_points.get(reserved_point_key) == get_instance_id():
		reserved_patrol_points.erase(reserved_point_key)

	reserved_point_key = ""

func _is_point_reserved_by_other(point: Marker2D) -> bool:
	var point_key := _get_point_key(point)
	if not reserved_patrol_points.has(point_key):
		return false

	var owner_id: int = reserved_patrol_points[point_key]
	if owner_id == get_instance_id():
		return false

	if not is_instance_id_valid(owner_id):
		reserved_patrol_points.erase(point_key)
		return false

	return true

func _cleanup_stale_reservations() -> void:
	for point_key in reserved_patrol_points.keys():
		var owner_id: int = reserved_patrol_points[point_key]
		if not is_instance_id_valid(owner_id):
			reserved_patrol_points.erase(point_key)

func _get_point_key(point: Marker2D) -> String:
	return str(point.get_path())

func _set_target() -> void:
	if patrol_points.is_empty() or current_point < 0: return
	# Случайное смещение, чтобы кубы не стояли в одной точке
	var offset := Vector2(randf_range(-60, 60), randf_range(-60, 60))
	target_position = patrol_points[current_point].global_position + offset
	stuck_timer = 0.0

# Остальные функции (perspective, health, death) остаются без изменений
func get_separation_force() -> Vector2:
	var force := Vector2.ZERO

	for body in get_tree().get_nodes_in_group("npc"):

		if body == self:
			continue

		if not body is CharacterBody2D:
			continue

		var dist := global_position.distance_to(body.global_position)

		if dist <= 0.0 or dist > separation_radius:
			continue

		var away: Vector2 = (global_position - body.global_position).normalized()

		force += away * ((separation_radius - dist) / separation_radius)

	if force.length() > 1.0:
		force = force.normalized()

	return force * separation_strength


func _process(_delta: float) -> void:
	queue_redraw()
	z_index = int(feer_marker.global_position.y)
	update_perspective()

func update_perspective() -> void:
	var scale_factor: float = clamp(0.5 + global_position.y / 1000.0, 0.5, 1.5)
	sprite.scale = base_scale * scale_factor

func _on_health_changed(_cur, _max, damage_taken) -> void:
	hit_effect()
	var damage_scene = preload("res://UI/damage_number.tscn")
	var damage = damage_scene.instantiate()
	damage.global_position = global_position
	get_tree().current_scene.add_child(damage)
	damage.setup(damage_taken)

func hit_effect() -> void:
	var original_pos := sprite.position
	var tween := create_tween()
	var offset := Vector2(randf_range(-15, 15), randf_range(-15, 15))
	tween.tween_property(sprite, "position", original_pos + offset, 0.05)
	tween.tween_property(sprite, "position", original_pos, 0.08)

func _on_died() -> void:
	_release_reserved_target()
	CheckpointManager.removed_objects[unique_id] = true
	queue_free()
