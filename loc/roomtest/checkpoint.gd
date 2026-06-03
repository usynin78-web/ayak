extends CharacterBody2D

@onready var feer_marker = $Marker2D

func _process(_delta: float) -> void:
 z_index = int(feer_marker.global_position.y)
