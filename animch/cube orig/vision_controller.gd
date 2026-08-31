extends Node

signal player_spotted(player)
signal player_lost(player)

@export var vision_area: Area2D
@export var look_speed: float = 5.0
@export var look_distance: float = 500.0

var default_rotation: float = 0.0
var detected_player: Node2D = null

func _ready() -> void:
    if vision_area == null:
        push_error("VisionArea не назначена!")
        return

    vision_area.body_entered.connect(_on_body_entered)
    vision_area.body_exited.connect(_on_body_exited)

    # Запоминаем исходное направление поля зрения.
    # В него кубик будет возвращаться, когда Кир уйдёт.
    default_rotation = vision_area.rotation
    
    
func _process(delta: float) -> void:
    # Если Кир находится в поле зрения,
    # постепенно поворачиваем VisionArea в его сторону.
    if detected_player != null:
        var direction: Vector2 = detected_player.global_position - vision_area.global_position
        set_direction(direction, delta)

    # Если Кир вышел из поля зрения,
    # постепенно возвращаем VisionArea в исходное положение.
    else:
        var weight: float = 1.0 - exp(-5.0 * delta)

        vision_area.rotation = lerp_angle(
            vision_area.rotation,
            default_rotation,
            weight
        )

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        detected_player = body
        player_spotted.emit(body)


func _on_body_exited(body: Node2D) -> void:
    if body == detected_player:
        detected_player = null
        player_lost.emit(body)


func can_see_player() -> bool:
    return detected_player != null

func get_player() -> Node2D:
    return detected_player

func set_direction(direction: Vector2, delta: float = 0.016) -> void:
    if direction.length_squared() > 0.0:
        # Плавно поворачиваем VisionArea к заданному направлению.
        # lerp_angle корректно работает с переходом через -PI/PI.
        var target_rotation: float = direction.angle() - PI / 2.0

        # Экспоненциальное сглаживание не зависит от FPS так сильно,
        # как обычный lerp(..., 0.5).
        var weight: float = 1.0 - exp(-5.0 * delta)

        vision_area.rotation = lerp_angle(
            vision_area.rotation,
            target_rotation,
            weight
        )
