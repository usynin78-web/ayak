extends Node

var settings_list: VBoxContainer

var fps_limits: Array[int] = [
 30,
 60,
 120,
 144,
 0
]

var current_fps_index: int = 1


func setup(list: VBoxContainer) -> void:
 settings_list = list


func show_settings() -> void:
 _clear_settings()

 var fps_button := _add_setting(
  "Отображение FPS",
  _get_fps_visibility_name()
 )

 fps_button.pressed.connect(
  func():
   _toggle_fps_visibility(fps_button)
 )

 var limit_button := _add_setting(
  "Ограничение FPS",
  _get_fps_limit_name()
 )

 limit_button.pressed.connect(
  func():
   _toggle_fps_limit(limit_button)
 )


func _clear_settings() -> void:
 for child in settings_list.get_children():
  child.queue_free()


func _add_setting(label_text: String, button_text: String) -> Button:
 var label := Label.new()
 label.text = label_text

 var button := Button.new()
 button.text = button_text

 settings_list.add_child(label)
 settings_list.add_child(button)

 return button


func _toggle_fps_visibility(button: Button) -> void:
 SettingsManager.show_fps = !SettingsManager.show_fps

 button.text = _get_fps_visibility_name()


func _get_fps_visibility_name() -> String:
 if SettingsManager.show_fps:
  return "Вкл."

 return "Выкл."


func _toggle_fps_limit(button: Button) -> void:
 current_fps_index += 1

 if current_fps_index >= fps_limits.size():
  current_fps_index = 0

 SettingsManager.fps_limit = fps_limits[current_fps_index]
 Engine.max_fps = SettingsManager.fps_limit

 button.text = _get_fps_limit_name()


func _get_fps_limit_name() -> String:
 var limit: int = SettingsManager.fps_limit

 if limit == 0:
  return "Без ограничений"

 return str(limit)
