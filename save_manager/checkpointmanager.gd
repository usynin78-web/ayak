extends Node

const SAVE_FILE: String = "user://checkpoint.ayk"

var last_position: Vector2 = Vector2.ZERO
var last_health: int = 225
var has_checkpoint: bool = false

# Список объектов, которые были уничтожены или подобраны
var removed_objects: Dictionary = {}

func _ready() -> void:
	load_save_data()

func load_save_data() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_FILE) == OK:
		removed_objects = config.get_value("world", "removed_objects", {})
		print("Загружены данные мира. Удаленных объектов: ", removed_objects.size())

func save_checkpoint(pos: Vector2, hp: int) -> void:
	last_position = pos
	last_health = hp
	has_checkpoint = true

	var config := ConfigFile.new()
	config.set_value("player", "x", pos.x)
	config.set_value("player", "y", pos.y)
	config.set_value("player", "hp", hp)
	config.set_value("world", "removed_objects", removed_objects)

	var err := config.save(SAVE_FILE)
	if err != OK:
		push_error("Не удалось сохранить чекпоинт на диск!")
	else:
		print("Чекпоинт сохранён: ", pos, " HP:", hp)

func get_spawn_position(default_pos: Vector2) -> Vector2:
	if has_checkpoint:
		return last_position

	var config := ConfigFile.new()
	if config.load(SAVE_FILE) == OK and _is_valid_checkpoint(config):
		var x: float = config.get_value("player", "x", default_pos.x)
		var y: float = config.get_value("player", "y", default_pos.y)
		last_position = Vector2(x, y)
		last_health = config.get_value("player", "hp", 225)
		has_checkpoint = true
		return last_position

	return default_pos

func get_saved_health(default_hp: int) -> int:
	if has_checkpoint:
		return last_health

	var config := ConfigFile.new()
	if config.load(SAVE_FILE) == OK:
		return config.get_value("player", "hp", default_hp)

	return default_hp

func has_save() -> bool:
	if has_checkpoint:
		return true
	return FileAccess.file_exists(SAVE_FILE)

func clear_save() -> void:
	# 1. Очищаем переменные в памяти (это воскресит кубики)
	last_position = Vector2.ZERO
	last_health = 225
	has_checkpoint = false
	removed_objects.clear()

	# 2. Удаляем файл с диска
	if FileAccess.file_exists(SAVE_FILE):
		var err := DirAccess.remove_absolute(SAVE_FILE)
		if err != OK:
			push_error("Не удалось удалить файл сохранения!")
	
	print("Все сохранения и данные о мире очищены.")

func _is_valid_checkpoint(config: ConfigFile) -> bool:
	return (
		config.has_section_key("player", "x") 
		and config.has_section_key("player", "y") 
		and config.has_section_key("player", "hp")
	)
