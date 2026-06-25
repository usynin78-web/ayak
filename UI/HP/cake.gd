extends Area2D

@onready var feer_marker = $"../Marker2D"

# Уникальный ID предмета для сохранения
var unique_id := ""

func _ready():
    # Получаем путь до объекта как временный уникальный ID
    unique_id = str(_get_pickup_root().get_path())

    print("cake", unique_id)
    print("словарь", CheckpointManager.removed_objects)
    if CheckpointManager.removed_objects.has(unique_id):
        _get_pickup_root().queue_free()
        return

func _process(_delta: float) -> void:
    z_index = int(feer_marker.global_position.y)

# Сколько здоровья восстанавливает торт.
@export var heal_amount: int = 25

# Если true — торт исчезнет после использования.
@export var destroy_after_heal: bool = true

var _is_used: bool = false

func _on_body_entered(body: Node2D) -> void:
    # Проверяем, что торт коснулся именно игрока.
    if _is_used or not body.is_in_group("player"):
        return

    # Ищем компонент здоровья у игрока.
    var health_component := _find_health_component(body)

    if health_component == null or not health_component.has_method("heal"):
        return

    # Если HP уже полное, не тратим торт
    var health_before = health_component.get("current_health")

    health_component.heal(heal_amount)

    var health_after = health_component.get("current_health")

    if health_before != null and health_after != null and health_after <= health_before:
        return

    print("Кир восстановил ", heal_amount, " HP")

    # Удаляем весь торт, а не только Area2D с этим скриптом.
    if destroy_after_heal:
        _is_used = true

        # Запоминаем, что этот торт уже был подобран
        CheckpointManager.removed_objects[unique_id] = true

        print("Сохранён торт:", unique_id)

        _get_pickup_root().queue_free()

func _find_health_component(body: Node2D) -> Node:
    var health_component := body.get_node_or_null("HealthComponent")

    if health_component != null:
        return health_component

    # Запасной вариант: компонент HP может быть переименован
    for child in body.get_children():
        if child.is_in_group("hp") and child.has_method("heal"):
            return child

    return null

func _get_pickup_root() -> Node:
    if get_parent() != null:
        return get_parent()

    return self
