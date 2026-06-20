extends Node2D

@export var unique_id := ""
@onready var health_component = $AnimatedSprite2D/Area2D/HealthComponent
@onready var feer_marker = $Marker2D

func _process(_delta: float) -> void:
 z_index = int(feer_marker.global_position.y)

func _ready() -> void:
 unique_id = str(get_path())
 print(unique_id)
 if CheckpointManager.removed_objects.has(unique_id):
  print("Куб уже был уничтожен:", unique_id)
  queue_free()
  return

 health_component.health_changed.connect(_on_health_changed)
 health_component.died.connect(_on_died)

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
 # Получаем спрайт кубика.
 var sprite := get_parent() as AnimatedSprite2D

 if sprite == null:
  return

 # Запоминаем исходную позицию.
 var original_position := sprite.position

 # Случайное направление удара.
 var random_offset := Vector2(
  randf_range(-15, 15),
  randf_range(-15, 15)
 )

 var tween := create_tween()

 # Отталкиваем спрайт.
 tween.tween_property(
  sprite,
  "position",
  original_position + random_offset,
  0.05
 )


func _on_died() -> void:
 print("cube", unique_id)
 print("словарь", CheckpointManager.removed_objects)
 CheckpointManager.removed_objects[unique_id] = true
 print("Кубик погиб")
 queue_free()
