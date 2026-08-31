extends Node

signal player_spotted(player)
signal player_lost(player)

@export var vision_area: Area2D
@export var vision_ray: RayCast2D

# Максимальное отклонение VisionArea от исходного направления кубика.
@export var max_look_angle: float = 60.0

# Минимальное перемещение Кирчика, на которое кубик реагирует.
# Это помогает убрать мелкое дрожание взгляда.
@export var look_deadzone: float = 5.0

var default_rotation: float = 0.0
var detected_player: Node2D = null
var last_player_position: Vector2 = Vector2.ZERO

# Последнее состояние RayCast.
# Используется, чтобы не спамить Output сообщениями каждый кадр.
var last_wall_state: bool = false


func _ready() -> void:
    if vision_area == null:
        push_error("VisionArea не назначена!")
        return

    if vision_ray == null:
        push_error("VisionRayCast не назначен!")
        return

    vision_area.body_entered.connect(_on_body_entered)
    vision_area.body_exited.connect(_on_body_exited)

    # Запоминаем исходное направление поля зрения.
    default_rotation = vision_area.rotation


func _process(delta: float) -> void:
    if detected_player != null:
        var current_player_position: Vector2 = detected_player.global_position

        # Проверяем, насколько Кирчик переместился.
        var player_movement: float = current_player_position.distance_to(
            last_player_position
        )

        # RayCast проверяет, действительно ли кубик видит Кирчика.
        var player_visible: bool = can_see_player()

        # Кубик следит за Кирчиком только тогда,
        # когда между ними нет стены.
        if player_visible and player_movement >= look_deadzone:
            var direction: Vector2 = (
                current_player_position - vision_area.global_position
            )

            set_direction(direction, delta)

        # Запоминаем позицию Кирчика для следующего кадра.
        last_player_position = current_player_position

    else:
        # Кирчик потерян из VisionArea.
        # Возвращаем взгляд в исходное положение.
        var weight: float = 1.0 - exp(-2.5 * delta)

        vision_area.rotation = lerp_angle(
            vision_area.rotation,
            default_rotation,
            weight
        )


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        detected_player = body

        # Начинаем отслеживание с текущей позиции,
        # чтобы кубик не получил ложный рывок при обнаружении.
        last_player_position = body.global_position

        player_spotted.emit(body)


func _on_body_exited(body: Node2D) -> void:
    if body == detected_player:
        detected_player = null
        player_lost.emit(body)


func can_see_player() -> bool:
    if detected_player == null:
        return false

    # Направляем луч от кубика к Кирчику.
    vision_ray.target_position = vision_ray.to_local(
        detected_player.global_position
    )

    # Немедленно обновляем результат RayCast.
    vision_ray.force_raycast_update()

    var sees_wall: bool = false

    if vision_ray.is_colliding():
        var collider: Object = vision_ray.get_collider()

        # Если первым встретился не Кирчик,
        # значит между ними находится препятствие.
        if collider != detected_player:
            sees_wall = true

    # Выводим сообщение только при изменении состояния.
    if sees_wall != last_wall_state:
        if sees_wall:
            print("Вижу стену")
        else:
            print("Не вижу стену")

        last_wall_state = sees_wall

    return not sees_wall


func can_see_player_in_vision() -> bool:
    return detected_player != null


func get_player() -> Node2D:
    return detected_player
func set_direction(direction: Vector2, delta: float = 0.016) -> void:
    if direction.length_squared() > 0.0:
        # Вычисляем угол до Кирчика.
        var target_rotation: float = direction.angle() - PI / 2.0

        # Переводим максимальный угол из градусов в радианы.
        var max_angle: float = deg_to_rad(max_look_angle)

        # Определяем границы допустимого поворота
        # относительно исходного направления кубика.
        var min_rotation: float = default_rotation - max_angle
        var max_rotation: float = default_rotation + max_angle

        # Не позволяем кубику повернуть VisionArea
        # дальше установленного угла.
        target_rotation = clamp(
            target_rotation,
            min_rotation,
            max_rotation
        )

        # Плавно поворачиваем VisionArea.
        var weight: float = 1.0 - exp(-2.5 * delta)

        vision_area.rotation = lerp_angle(
            vision_area.rotation,
            target_rotation,
            weight
        )
