extends Node2D

@export var unique_id := ""
@export var run_speed := 90.0
@export var run_radius := 220.0
@export var min_wait_time := 0.2
@export var max_wait_time := 0.8

@onready var health_component = $AnimatedSprite2D/Area2D/HealthComponent
@onready var feer_marker = $Marker2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var start_position := Vector2.ZERO
var target_position := Vector2.ZERO
var wait_timer := 0.0
var base_scale := Vector2.ONE

func update_perspective() -> void:
 var scale_factor = 0.5 + global_position.y / 1000
 scale_factor = clamp(scale_factor, 0.5, 1.5)

 sprite.scale = base_scale * scale_factor

func _ready() -> void:
 unique_id = str(get_path())
 print(unique_id)
 if CheckpointManager.removed_objects.has(unique_id):
  print("Куб уже был уничтожен:", unique_id)
  queue_free()
  return

 start_position = global_position
 _pick_random_target()
 sprite.play()

 health_component.health_changed.connect(_on_health_changed)
 health_component.died.connect(_on_died)


func _process(delta: float) -> void:
 z_index = int(feer_marker.global_position.y)
 _run_randomly(delta)


func _run_randomly(delta: float) -> void:
 if wait_timer > 0.0:
  wait_timer -= delta
  return

 var direction := target_position - global_position
 if direction.length() <= run_speed * delta:
  global_position = target_position
  wait_timer = randf_range(min_wait_time, max_wait_time)
  _pick_random_target()
  return

 global_position += direction.normalized() * run_speed * delta
 sprite.flip_h = direction.x < 0.0


func _pick_random_target() -> void:
 target_position = start_position + Vector2.RIGHT.rotated(randf() * TAU) * randf_range(0.0, run_radius)


func _on_health_changed(current: int, max_hp: int, damage_taken: int) -> void:
 print("Кубик HP:", current, "/", max_hp)

 # Эффект получения удара.
 hit_effect()

 var damage_scene = preload("res://UI/damage_number.tscn")
 var damage = damage_scene.instantiate()

 damage.global_position = global_position

 get_tree().current_scene.add_child(damage)

 damage.setup(damage_taken)


func hit_effect() -> void:
 # Запоминаем исходную позицию.
 var original_position := sprite.position

 # Случайное направление удара.
 var random_offset := Vector2(
  randf_range(-15, 15),
  randf_range(-15, 15)
 )

 var tween := create_tween()

 # Отталкиваем спрайт и возвращаем его назад.
 tween.tween_property(
  sprite,
  "position",
  original_position + random_offset,
  0.05
 )
 tween.tween_property(sprite, "position", original_position, 0.08)


func _on_died() -> void:
 print("cube", unique_id)
 print("словарь", CheckpointManager.removed_objects)
 CheckpointManager.removed_objects[unique_id] = true
 print("Кубик погиб")
 queue_free()
