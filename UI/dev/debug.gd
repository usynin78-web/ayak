extends Label

@onready var player = $"../../c3"
@onready var room = $"../../Node2D"


func _ready() -> void:
 add_to_group("fps_counter")
 visible = SettingsManager.show_fps


func _process(_delta) -> void:
 text = """
FPS: %d
X: %d
Y: %d
Локация: %s
""" % [
  Engine.get_frames_per_second(),
  int(player.global_position.x),
  int(player.global_position.y),
  room.location_id
 ]


func _input(event) -> void:
 if event.is_action_pressed("fps_toggle"):
  SettingsManager.show_fps = !SettingsManager.show_fps
  visible = SettingsManager.show_fps
