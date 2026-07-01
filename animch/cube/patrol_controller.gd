extends Node

## ----------------------------------------
## PatrolController
##
## Отвечает только за патрулирование NPC.
## Он НЕ двигает персонажа.
## Он только выбирает следующую цель.
## ----------------------------------------

class_name PatrolController

## Путь до узла, в котором находятся маркеры патруля.
@export_node_path("Node")
var patrol_path: NodePath

## Сколько ждать на точке.
@export var min_wait_time: float = 1.0
@export var max_wait_time: float = 3.0

## Радиус случайного смещения цели.
@export var random_offset: float = 60.0

## Сигналы
signal target_changed(target: Vector2)
signal patrol_finished()

## Приватные переменные
var patrol_points: Array[Marker2D] = []

var current_point: int = -1
var target_position: Vector2 = Vector2.ZERO

var wait_timer: float = 0.0


func initialize(owner: Node2D) -> void:

	patrol_points.clear()

	var path_node = owner.get_node_or_null(patrol_path)

	if path_node == null:
		push_warning("Patrol path not found.")
		return

	for child: Node in path_node.get_children():

		if child is Marker2D:
			patrol_points.append(child)

	_choose_next_point()


func update(delta: float, npc_position: Vector2) -> void:

	if patrol_points.is_empty():
		return

	## Ждём на точке
	if wait_timer > 0.0:

		wait_timer -= delta

		if wait_timer <= 0.0:
			_choose_next_point()

		return

	## Пришли к цели
	if npc_position.distance_to(target_position) < 10.0:

		wait_timer = randf_range(
			min_wait_time,
			max_wait_time
		)


func get_target_position() -> Vector2:
	return target_position


func _choose_next_point() -> void:

	if patrol_points.is_empty():
		patrol_finished.emit()
		return

	var next: int = randi() % patrol_points.size()

	## Не выбираем ту же самую точку,
	## если есть выбор.
	if patrol_points.size() > 1:

		while next == current_point:
			next = randi() % patrol_points.size()

	current_point = next

	var offset: Vector2 = Vector2(
		randf_range(-random_offset, random_offset),
		randf_range(-random_offset, random_offset)
	)

	target_position = patrol_points[current_point].global_position + offset

	target_changed.emit(target_position)
	print("Новая цель: ", target_position)
