extends Area2D

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

	# Если у компонента есть текущее здоровье, не тратим торт впустую при полном HP.
	var health_before = health_component.get("current_health")
	health_component.heal(heal_amount)
	var health_after = health_component.get("current_health")
	if health_before != null and health_after != null and health_after <= health_before:
		return

	print("Кир восстановил ", heal_amount, " HP")

	# Удаляем весь торт, а не только Area2D с этим скриптом.
	if destroy_after_heal:
		_is_used = true
		_get_pickup_root().queue_free()


func _find_health_component(body: Node2D) -> Node:
	var health_component := body.get_node_or_null("HealthComponent")
	if health_component != null:
		return health_component

	# Запасной вариант: компонент HP может быть переименован, но состоять в группе "hp".
	for child in body.get_children():
		if child.is_in_group("hp") and child.has_method("heal"):
			return child

	return null


func _get_pickup_root() -> Node:
	if get_parent() != null:
		return get_parent()

	return self
