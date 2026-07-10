extends CharacterBody2D

@export var speed := 100.0

@onready var navigation: NavigationAgent2D = $NavigationAgent2D

func _physics_process(_delta):

 if navigation.is_navigation_finished():
  velocity = Vector2.ZERO
  move_and_slide()
  return

 var next := navigation.get_next_path_position()

 velocity = global_position.direction_to(next) * speed

 move_and_slide()

func move_to(target: Vector2):
 navigation.target_position = target
