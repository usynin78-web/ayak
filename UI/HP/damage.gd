extends Area2D

@export var damage: int = 25
@export var damage_interval: float = 1.0

var player_inside: Node2D = null
var can_damage: bool = true


func _on_body_entered(body: Node2D) -> void:
 if body.is_in_group("player"):
  player_inside = body
  _damage_player()


func _on_body_exited(body: Node2D) -> void:
 if body == player_inside:
  player_inside = null


func _damage_player() -> void:
 if player_inside == null:
  return
 
 if not can_damage:
  return
 
 var health_component = player_inside.get_node_or_null("HealthComponent")
 if health_component == null:
  return
 
 health_component.take_damage(damage)
 print("Кир ранен на ", damage, " HP")
 
 can_damage = false
 
 await get_tree().create_timer(damage_interval).timeout
 
 can_damage = true
 
 if player_inside != null:
  _damage_player()
 
