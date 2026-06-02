extends Node

var last_position: Vector2 = Vector2.ZERO
var last_health: int = 225
var has_checkpoint: bool = false

const SAVE_FILE := "user://checkpoint.cfg"

func save_checkpoint(pos: Vector2, hp: int) -> void:
	last_position = pos
	last_health = hp
	has_checkpoint = true

	print("Чекпоинт сохранён (память):", pos, " HP:", hp)

	var config = ConfigFile.new()
	config.set_value("player", "x", pos.x)
	config.set_value("player", "y", pos.y)
	config.set_value("player", "hp", hp)

	var err = config.save(SAVE_FILE)
	if err != OK:
		push_error("Не удалось сохранить чекпоинт на диск!")
	else:
		print("Чекпоинт сохранён на диск:", pos, " HP:", hp)

func get_spawn_position(default_pos: Vector2) -> Vector2:
	if has_checkpoint:
		return last_position

	var config = ConfigFile.new()
	if config.load(SAVE_FILE) == OK and _is_valid_checkpoint(config):
		var x = config.get_value("player", "x", default_pos.x)
		var y = config.get_value("player", "y", default_pos.y)
		last_position = Vector2(x, y)
		last_health = config.get_value("player", "hp", 225)
		has_checkpoint = true
		print("Загружено с диска:", last_position)
		return last_position

	return default_pos

func get_saved_health(default_hp: int) -> int:
	if has_checkpoint:
		return last_health

	var config = ConfigFile.new()

	if config.load(SAVE_FILE) == OK:
		return config.get_value("player", "hp", default_hp)

	return default_hp

func has_save() -> bool:
	if has_checkpoint:
		return true

	var config = ConfigFile.new()
	if config.load(SAVE_FILE) == OK and _is_valid_checkpoint(config):
		return true

	return false

func clear_save() -> void:
	last_position = Vector2.ZERO
	last_health = 225
	has_checkpoint = false

	var save_path := ProjectSettings.globalize_path(SAVE_FILE)
	if FileAccess.file_exists(SAVE_FILE):
		var err = DirAccess.remove_absolute(save_path)
		if err != OK:
			push_error("Не удалось удалить файл сохранения!")

	print("Сохранение сброшено")

func _is_valid_checkpoint(config: ConfigFile) -> bool:
	return (
		config.has_section_key("player", "x")
		and config.has_section_key("player", "y")
		and config.has_section_key("player", "hp")
	)