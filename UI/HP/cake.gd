extends Area2D

# Сколько здоровья восстанавливает торт.
@export var heal_amount: int = 25

# Если true — торт исчезнет после использования.
@export var destroy_after_heal: bool = true


func _on_body_entered(body: Node2D) -> void:
 # Проверяем, что торт коснулся именно игрока.
 if not body.is_in_group("player"):
  return
 
 # Ищем HealthComponent внутри игрока.
 var health_component = body.get_node_or_null("HealthComponent")
 
 if health_component == null:
  return
 
 # Восстанавливаем здоровье.
 health_component.heal(heal_amount)
 
 # Удаляем торт, если он одноразовый.
 if destroy_after_heal:
  queue_free()
