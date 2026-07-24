extends CharacterBody2D

@export var unique_id: String = ""
@export var speed: float = 100.0
@onready var health_component: Node = $AnimatedSprite2D/Hurtbox/HealthComponent
@onready var navigation: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var feet_marker: Marker2D = $FeetMarker

var base_scale: Vector2

func _ready() -> void:
 base_scale = sprite.scale
 add_to_group("damageable")
 add_to_group("npc")

 unique_id = str(get_path())

 if CheckpointManager.removed_objects.has(unique_id):
  queue_free()
  return
 if CheckpointManager.npc_positions.has(unique_id):
  global_position = CheckpointManager.npc_positions[unique_id]

 health_component.health_changed.connect(_on_health_changed)
 health_component.died.connect(_on_died)

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

 var offset := Vector2(
  randf_range(-15, 15),
  randf_range(-15, 15)
 )

 tween.tween_property(sprite, "position", original_pos + offset, 0.05)
 tween.tween_property(sprite, "position", original_pos, 0.08)

func _on_died() -> void:
 CheckpointManager.removed_objects[unique_id] = true
 queue_free()

func _process(_delta: float) -> void:
 z_index = int(feet_marker.global_position.y)
 update_perspective()

func _physics_process(_delta: float) -> void:
 _move()


func _move() -> void:
    # Проверяем, дошли ли мы до конца.
    if navigation.is_navigation_finished():
        velocity = Vector2.ZERO
        if sprite.animation != "idle":
            sprite.play("idle")
        # Если мы уже стоим, move_and_slide() можно не вызывать каждую секунду
        return
    # Получаем следующую точку маршрута.
    var next_point := navigation.get_next_path_position()
    # Направление к следующей точке.
    var direction := global_position.direction_to(next_point)

    # Движение.
    velocity = direction * speed

    if sprite.animation != "walk":
        sprite.play("walk")

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
