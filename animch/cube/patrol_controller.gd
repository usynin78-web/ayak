extends Node

## Точки патруля. Просто перетащи сюда Marker2D через инспектор.
@export var patrol_points: Array[Marker2D]

## Сколько секунд NPC стоит в каждой точке.
@export var wait_time: float = 2.0

@onready var npc: CharacterBody2D = get_parent()
@onready var timer: Timer = $"../Timer"
var current_point: int = 0
var waiting: bool = false


func _ready() -> void:
 await get_tree().process_frame
 timer.wait_time = wait_time
 timer.timeout.connect(_on_timer_timeout)

 if patrol_points.is_empty():
  return

 npc.move_to(patrol_points[current_point].global_position)


func _process(_delta: float) -> void:
 if patrol_points.is_empty():
  return

 if waiting:
  return

 if npc.navigation.is_navigation_finished():
  waiting = true
  timer.start()


func _on_timer_timeout() -> void:
 waiting = false

 current_point += 1

 if current_point >= patrol_points.size():
  current_point = 0

 npc.move_to(patrol_points[current_point].global_position)
