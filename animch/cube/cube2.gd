extends CharacterBody2D

@export var speed: float = 100.0

@onready var navigation: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var feet_marker: Marker2D = $FeetMarker

var base_scale: Vector2

func _ready() -> void:
 base_scale = sprite.scale
 print(navigation)
 print(sprite)
 print(feet_marker)

func _physics_process(_delta: float) -> void:
 _move()

func _process(_delta: float) -> void:
 z_index = int(feet_marker.global_position.y)
 update_perspective()

func _move() -> void:
 # Если путь закончился, просто стоим.
 if navigation.is_navigation_finished():
  velocity = Vector2.ZERO

  if sprite.animation != "idle":
   sprite.play("idle")

  return

 # Следующая точка пути.
 var next_point := navigation.get_next_path_position()

 # Направление до неё.
 var direction := global_position.direction_to(next_point)

 # Скорость.
 velocity = direction * speed

 # Двигаемся.
 move_and_slide()

func move_to(target: Vector2) -> void:
 navigation.target_position = target

func update_perspective() -> void:
 var scale_factor := clampf(
  0.5 + global_position.y / 1000.0,
  0.5,
  1.5
 )

 sprite.scale = base_scale * scale_factor
