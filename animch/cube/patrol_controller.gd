extends Node

@export var patrol_group: String = "point"
@export var wait_time: float = 2.0

var patrol_points: Array[Marker2D] = []

@onready var npc: CharacterBody2D = get_parent()
@onready var timer: Timer = $"../Timer"

var current_point: int = 0
var waiting: bool = false


func _ready() -> void:
 await get_tree().process_frame

 timer.wait_time = wait_time
 timer.timeout.connect(_on_timer_timeout)

 for node in get_tree().get_nodes_in_group(patrol_group):
  if node is Marker2D:
   patrol_points.append(node)

 if patrol_points.is_empty():
  push_warning("Не найдено ни одной точки патруля группы: " + patrol_group)
  return

 npc.move_to(patrol_points[current_point].global_position)


func _process(_delta: float) -> void:
 if waiting or patrol_points.is_empty():
  return

 if npc.navigation.is_navigation_finished():
  waiting = true
  timer.start()


func _on_timer_timeout() -> void:
 waiting = false

 current_point = (current_point + 1) % patrol_points.size()

 npc.move_to(patrol_points[current_point].global_position)

 set_process(true)
