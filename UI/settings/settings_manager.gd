extends Node

var show_fps: bool = true
var fps_limit: int = 0


func _ready() -> void:
 Engine.max_fps = fps_limit
