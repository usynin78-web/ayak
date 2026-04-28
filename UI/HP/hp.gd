extends Control

# Это сама полоска HP внутри текущей сцены hp.tscn.
# Скрипт висит на Control, поэтому к TextureProgressBar обращаемся через $TextureProgressBar.
@onready var hp_bar: TextureProgressBar = $TextureProgressBar

# Здесь будет храниться HealthComponent игрока.
var health_component: Node


func _ready() -> void:
	# Ищем игрока по группе "player".
	# У тебя c3 уже находится в этой группе.
	var player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		push_error("HP: игрок не найден. Проверь, что c3 находится в группе player.")
		return
	
	# Ищем у игрока дочерний узел HealthComponent.
	health_component = player.get_node_or_null("HealthComponent")
	
	if health_component == null:
		push_error("HP: у игрока нет узла HealthComponent.")
		return
	
	# Подключаем сигнал изменения здоровья.
	# Когда здоровье изменится, вызовется _on_health_changed().
	health_component.health_changed.connect(_on_health_changed)
	
	# Подключаем сигнал смерти.
	# Когда здоровье станет 0, вызовется _on_died().
	health_component.died.connect(_on_died)
	
	# Сразу выставляем полоску в правильное состояние.
	_on_health_changed(health_component.current_health, health_component.max_health)


func _on_health_changed(current_health: int, max_health: int) -> void:
	# Максимум полоски равен максимальному HP.
	hp_bar.max_value = max_health
	
	# Текущее заполнение полоски равно текущему HP.
	hp_bar.value = current_health


func _on_died() -> void:
	# Пока просто проверка.
	# Когда всё заработает, сюда можно добавить Game Over.
	print("Кир умер")
