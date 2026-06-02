extends Node

# Сообщает интерфейсу, что здоровье изменилось.
signal health_changed(current_health: int, max_health: int)

# Сообщает другим узлам, что игрок умер.
signal died

# Максимальное здоровье игрока.
@export var max_health: int = 225

# Текущее здоровье игрока.
var current_health: int


func _ready() -> void:
	# Загружаем HP из сохранения или используем максимум.
	current_health = CheckpointManager.get_saved_health(max_health)

	# Сразу отправляем сигнал, чтобы HP-бар обновился.
	health_changed.emit(current_health, max_health)


func take_damage(amount: int) -> void:
	# amount — сколько урона получил игрок.
	if amount <= 0:
		return

	# Уменьшаем HP, но не даём ему уйти ниже 0.
	current_health = clamp(current_health - amount, 0, max_health)

	# Сообщаем интерфейсу новое значение.
	health_changed.emit(current_health, max_health)

	# Если HP закончилось — смерть.
	if current_health <= 0:
		died.emit()


func heal(amount: int) -> void:
	# amount — сколько HP восстановить.
	if amount <= 0:
		return

	# Лечим, но не выше максимального здоровья.
	current_health = clamp(current_health + amount, 0, max_health)

	# Сообщаем интерфейсу новое значение.
	health_changed.emit(current_health, max_health)