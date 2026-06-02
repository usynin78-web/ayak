extends Area2D

@export var e_icon: TextureRect
@export var save_label: Label
@export var offset_icon: Vector2 = Vector2(0, -50)

var player: CharacterBody2D = null
var player_inside: bool = false

func _ready() -> void:
	if not e_icon:
		push_error("E_icon не назначен!")
	else:
		e_icon.visible = false

	if not save_label:
		push_error("SaveLabel не назначен!")
	else:
		save_label.visible = false

	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _process(delta: float) -> void:
	if player_inside and player and e_icon:
		var world_pos = player.global_position + offset_icon
		var screen_pos = get_viewport().get_canvas_transform() * world_pos
		e_icon.position = screen_pos

	if player_inside and Input.is_action_just_pressed("interact"):
		_activate_checkpoint()

func _on_body_entered(body: Node) -> void:
	if not player:
		player = _find_player(body)
	if body == player:
		player_inside = true
		if e_icon:
			e_icon.visible = true

func _on_body_exited(body: Node) -> void:
	if body == player:
		player_inside = false
		if e_icon:
			e_icon.visible = false

func _activate_checkpoint() -> void:
	if player and CheckpointManager:
		var health_component = player.get_node_or_null("HealthComponent")

		if health_component:
			CheckpointManager.save_checkpoint(
				player.global_position,
				health_component.current_health
			)

		print("Чекпоинт сохранён:", player.global_position)

		if save_label:
			_show_save_label()

func _show_save_label() -> void:
	save_label.visible = true
	save_label.text = "Сохранение успешно выполнено"
	await get_tree().create_timer(2.0).timeout
	save_label.visible = false

func _find_player(body: Node) -> CharacterBody2D:
	if body.is_in_group("player"):
		return body as CharacterBody2D

	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0] as CharacterBody2D

	return null
