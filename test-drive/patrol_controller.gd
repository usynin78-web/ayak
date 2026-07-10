extends Node

@export var cube: CharacterBody2D
@export var points: Array[Marker2D]

var current := 0

func _ready() -> void:
 # Ждём, пока куб полностью инициализируется.
 await cube.ready

 # Получаем NavigationAgent2D напрямую, а не через переменную navigation.
 var agent: NavigationAgent2D = cube.get_node("NavigationAgent2D")

 # Подключаем сигнал.
 agent.navigation_finished.connect(_on_navigation_finished)

 # Даём NavigationServer один физический кадр.
 await get_tree().physics_frame

 # Отправляем кубик к первой точке.
 _send_to_next_point()

func _send_to_next_point():
    if points.is_empty():
        return
    cube.move_to(points[current].global_position)

func _on_navigation_finished():
    current += 1
    if current >= points.size():
        current = 0
        
    print("Следующая точка:", current)
    _send_to_next_point()
