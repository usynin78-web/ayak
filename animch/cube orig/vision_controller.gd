extends Node

signal player_spotted(player)
signal player_lost(player)

@export var vision_area: Area2D
@export var look_speed: float = 5.0
@export var look_distance: float = 500.0
@export var look_deadzone: float = 8.0

var default_rotation: float = 0.0
var detected_player: Node2D = null
var smoothed_direction: Vector2 = Vector2.ZERO
var last_player_position: Vector2 = Vector2.ZERO

func _ready() -> void:
    if vision_area == null:
        push_error("VisionArea не назначена!")
        return

    vision_area.body_entered.connect(_on_body_entered)
    vision_area.body_exited.connect(_on_body_exited)
    default_rotation = vision_area.rotation
   
    
func _process(delta: float) -> void:
    if detected_player != null:
        var current_player_position: Vector2 = detected_player.global_position
        var player_movement: float = current_player_position.distance_to(last_player_position)

        # Реагируем только если Кирчик переместился
        # дальше установленной мёртвой зоны.
        if player_movement >= look_deadzone:
            var direction: Vector2 = current_player_position - vision_area.global_position
            set_direction(direction, delta)

        # Обновляем позицию для следующей проверки.
        last_player_position = current_player_position

    else:
        # Кирчик потерян, поэтому постепенно возвращаем взгляд.
        var weight: float = 1.0 - exp(-3.0 * delta)

        vision_area.rotation = lerp_angle(
            vision_area.rotation,
            default_rotation,
            weight
        )
        
func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        detected_player = body
        last_player_position = body.global_position

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
        var target_rotation: float = direction.angle() - PI / 2.0
        var weight: float = 1.0 - exp(-2.5 * delta)
        vision_area.rotation = lerp_angle(
            vision_area.rotation,
            target_rotation,
            weight
        )
