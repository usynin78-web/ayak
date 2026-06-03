extends Area2D

@onready var health_component = $HealthComponent

func _ready() -> void:
 health_component.health_changed.connect(_on_health_changed)
 health_component.died.connect(_on_died)


func _on_health_changed(current: int, max_hp: int) -> void:
 print("Кубик HP:", current, "/", max_hp)

 # Эффект получения удара.
 hit_effect()

 var damage_scene = preload("res://UI/damage_number.tscn")
 var damage = damage_scene.instantiate()

 damage.global_position = global_position

 get_tree().current_scene.add_child(damage)

 damage.setup(25)


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
 print("Кубик погиб")
 get_parent().queue_free()
