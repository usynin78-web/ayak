extends CharacterBody2D

@export var unique_id: String = ""
@export var run_speed: float = 90.0
@export var min_wait_time: float = 1.0
@export var max_wait_time: float = 3.0
@export var path: NodePath

@onready var health_component: Node = $AnimatedSprite2D/Hurtbox/HealthComponent
@onready var feer_marker: Marker2D = $Marker2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var patrol_points: Array[Marker2D] = []
var current_point: int = 0
var target_position: Vector2 = Vector2.ZERO
var wait_timer: float = 0.0
var base_scale: Vector2 = Vector2.ONE

# Таймер для предотвращения застревания
var stuck_timer: float = 0.0

# Радиус, в котором NPC начинают расходиться.
@export var separation_radius: float = 45.0

# Сила отталкивания.
@export var separation_strength: float = 2.5

func _ready() -> void:
    add_to_group("damageable")
    add_to_group("npc")
    unique_id = str(get_path())
    
    if CheckpointManager.removed_objects.has(unique_id):
        queue_free()
        return

    var path_node := get_node_or_null(path)
    if path_node:
        for child in path_node.get_children():
            if child is Marker2D:
                patrol_points.append(child)

    if patrol_points.is_empty():
        set_physics_process(false)
        return

    _set_target()
    sprite.play("idle")
    health_component.health_changed.connect(_on_health_changed)
    health_component.died.connect(_on_died)

func _physics_process(delta: float) -> void:
    _run_patrol(delta)

func _run_patrol(delta: float) -> void:
    # Состояние ожидания
    if wait_timer > 0.0:
        velocity = Vector2.ZERO
        wait_timer -= delta
        if sprite.animation != "idle": sprite.play("idle")
        if wait_timer <= 0.0:
            _next_point()
        move_and_slide()
        return

    var dist := global_position.distance_to(target_position)

    # Условие "Дошли до точки" или "Застряли"
    # Если мы не можем дойти до точки за 5 секунд (stuck_timer), меняем её
    if dist <= 10.0 or stuck_timer > 5.0:
        stuck_timer = 0.0
        velocity = Vector2.ZERO
        wait_timer = randf_range(min_wait_time, max_wait_time)
        move_and_slide()
        return

    # Логика движения
    if sprite.animation != "walk": 
        sprite.play("walk")
    
    var dir := global_position.direction_to(target_position)

    # Отталкивание от других NPC.
    var separation := get_separation_force()

    # Небольшая случайность, чтобы NPC выглядели живее.
    var wander := Vector2(
        randf_range(-0.15, 0.15),
        randf_range(-0.15, 0.15)
    )

    var final_dir := dir + separation + wander

    if final_dir.length() > 0.01:
        final_dir = final_dir.normalized()

    velocity = final_dir * run_speed
    
    # Если мы двигаемся, но позиция почти не меняется (уперлись в стену)
    if velocity.length() > 0 and get_real_velocity().length() < 1.0:
        stuck_timer += delta
    else:
        stuck_timer = 0.0

    sprite.flip_h = velocity.x < 0.0
    move_and_slide()

func _next_point() -> void:
    if patrol_points.size() < 2:
        # Если точка одна, просто обновляем смещение (offset) для имитации движения
        _set_target()
        return
    
    var next_point := current_point
    # Безопасный выбор новой точки (не зацикливается)
    while next_point == current_point:
        next_point = randi() % patrol_points.size()
    
    current_point = next_point
    _set_target()

func _set_target() -> void:
    if patrol_points.is_empty(): return
    # Случайное смещение, чтобы кубы не стояли в одной точке
    var offset := Vector2(randf_range(-60, 60), randf_range(-60, 60))
    target_position = patrol_points[current_point].global_position + offset
    stuck_timer = 0.0

# Остальные функции (perspective, health, death) остаются без изменений
func get_separation_force() -> Vector2:
    var force := Vector2.ZERO

    for body in get_tree().get_nodes_in_group("npc"):

        if body == self:
            continue

        if not body is CharacterBody2D:
            continue

        var dist := global_position.distance_to(body.global_position)

        if dist <= 0.0 or dist > separation_radius:
            continue

        var away: Vector2 = (global_position - body.global_position).normalized()

        force += away * ((separation_radius - dist) / separation_radius)

    if force.length() > 1.0:
        force = force.normalized()

    return force * separation_strength


func _process(_delta: float) -> void:
    queue_redraw()
    z_index = int(feer_marker.global_position.y)
    update_perspective()

func update_perspective() -> void:
    var scale_factor: float = clamp(0.5 + global_position.y / 1000.0, 0.5, 1.5)
    sprite.scale = base_scale * scale_factor

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
    var offset := Vector2(randf_range(-15, 15), randf_range(-15, 15))
    tween.tween_property(sprite, "position", original_pos + offset, 0.05)
    tween.tween_property(sprite, "position", original_pos, 0.08)

func _on_died() -> void:
    CheckpointManager.removed_objects[unique_id] = true
    queue_free()
