extends Node2D

@export var unique_id := ""

# Скорость движения NPC.
@export var run_speed := 90.0

# Время ожидания в каждой точке.
@export var min_wait_time := 1.0
@export var max_wait_time := 3.0

# Узел, внутри которого лежат Marker2D.
@export var path: NodePath

@onready var health_component = $AnimatedSprite2D/Hurtbox/HealthComponent
@onready var feer_marker = $Marker2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Все точки маршрута.
var patrol_points: Array[Marker2D] = []

# Индекс текущей точки.
var current_point := 0

# Текущая цель.
var target_position := Vector2.ZERO

# Таймер ожидания.
var wait_timer := 0.0

var base_scale := Vector2.ONE


func _draw():
    draw_line(
        Vector2.ZERO,
        to_local(target_position),
        Color.RED,
        2
    )


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

    # Получаем все маркеры маршрута.
    var path_node = get_node(path)

    for child in path_node.get_children():
        if child is Marker2D:
            patrol_points.append(child)

    # Если маршрут пустой - прекращаем работу.
    if patrol_points.is_empty():
        push_warning("Маршрут не содержит Marker2D")
        return

    # Первая цель.
    _set_target()

    # Стартовая анимация.
    sprite.play("idle")

    health_component.health_changed.connect(_on_health_changed)
    health_component.died.connect(_on_died)


func _process(delta: float) -> void:
    queue_redraw()
    z_index = int(feer_marker.global_position.y)
    _run_patrol(delta)


func _run_patrol(delta: float) -> void:

    # Ожидание.
    if wait_timer > 0.0:

        # Включаем idle только если ещё не играет.
        if sprite.animation != "idle":
            sprite.play("idle")

        wait_timer -= delta

        if wait_timer <= 0.0:
            _next_point()

        return

    var direction := target_position - global_position

    # Дошли до точки.
    if direction.length() <= run_speed * delta:

        global_position = target_position

        wait_timer = randf_range(
            min_wait_time,
            max_wait_time
        )

        return

    # Включаем ходьбу только если ещё не играет.
    if sprite.animation != "walk":
        sprite.play("walk")

    global_position += direction.normalized() * run_speed * delta

    sprite.flip_h = direction.x < 0.0

func _on_vision_area_body_entered(body):
    if body.is_in_group("player"):
        _next_point()

func _on_vision_area_body_exited(body):
    if body.is_in_group("player"):
        _next_point()
        
# Следующая точка маршрута.
func _next_point() -> void:

    var next_point := current_point

    while next_point == current_point:
        next_point = randi() % patrol_points.size()

    current_point = next_point

    _set_target()


# Устанавливает новую цель.
func _set_target() -> void:

    target_position = (
        patrol_points[current_point].global_position
        +
        Vector2(
            randf_range(-20, 20),
            randf_range(-20, 20)
        )
    )


func _on_health_changed(current: int, max_hp: int, damage_taken: int) -> void:

    print("Кубик HP:", current, "/", max_hp)

    hit_effect()

    var damage_scene = preload("res://UI/damage_number.tscn")
    var damage = damage_scene.instantiate()

    damage.global_position = global_position

    get_tree().current_scene.add_child(damage)

    damage.setup(damage_taken)


func hit_effect() -> void:

    var original_position := sprite.position

    var random_offset := Vector2(
        randf_range(-15, 15),
        randf_range(-15, 15)
    )

    var tween := create_tween()

    tween.tween_property(
        sprite,
        "position",
        original_position + random_offset,
        0.05
    )

    tween.tween_property(
        sprite,
        "position",
        original_position,
        0.08
    )


func _on_died() -> void:

    print("cube", unique_id)
    print("словарь", CheckpointManager.removed_objects)

    CheckpointManager.removed_objects[unique_id] = true

    print("Кубик погиб")

    queue_free()
