extends Node

signal player_spotted(player)
signal player_lost(player)

@export var vision_area: Area2D

var detected_player: Node2D = null


func _ready() -> void:
	if vision_area == null:
		push_error("VisionArea не назначена!")
		return

	vision_area.body_entered.connect(_on_body_entered)
	vision_area.body_exited.connect(_on_body_exited)


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

func set_direction(direction: Vector2) -> void:
	if direction.length() > 0:
		vision_area.rotation = lerp_angle(
	vision_area.rotation,
	direction.angle() - PI / 2,
	0.50
)
