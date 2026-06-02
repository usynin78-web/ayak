extends Area2D

@onready var health_component = $HealthComponent

func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)

func _on_health_changed(current: int, max_hp: int) -> void:
	print("Кубик HP:", current, "/", max_hp)

func _on_died() -> void:
	print("Кубик погиб")
	queue_free()
