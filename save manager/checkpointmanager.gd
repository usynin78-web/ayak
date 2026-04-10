extends Node

var last_position: Vector2 = Vector2.ZERO
var has_checkpoint: bool = false

const SAVE_FILE := "user://checkpoint.cfg"

func save_checkpoint(pos: Vector2) -> void:
 last_position = pos
 has_checkpoint = true
 print("Чекпоинт сохранён (память):", pos)

 var config = ConfigFile.new()
 config.set_value("player", "x", pos.x)
 config.set_value("player", "y", pos.y)
 var err = config.save(SAVE_FILE)
 if err != OK:
  push_error("Не удалось сохранить чекпоинт на диск!")
 else:
  print("Чекпоинт сохранён на диск:", pos)

func get_spawn_position(default_pos: Vector2) -> Vector2:
 if has_checkpoint:
  return last_position

 var config = ConfigFile.new()
 if config.load(SAVE_FILE) == OK:
  var x = config.get_value("player", "x", default_pos.x)
  var y = config.get_value("player", "y", default_pos.y)
  last_position = Vector2(x, y)
  has_checkpoint = true
  print("Загружено с диска:", last_position)
  return last_position

 return default_pos

func has_save() -> bool:
 if has_checkpoint:
  return true

 var config = ConfigFile.new()
 if config.load(SAVE_FILE) == OK:
  return true

 return false

func clear_save() -> void:
 last_position = Vector2.ZERO
 has_checkpoint = false
 var config = ConfigFile.new()
 config.save(SAVE_FILE)
 print("Сохранение сброшено")
