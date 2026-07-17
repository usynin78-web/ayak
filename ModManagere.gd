extends Node

signal mods_loaded

const MODS_FOLDER := "mods"

var loaded_mods: Array[String] = []

func _ready() -> void:
 load_mods()


func load_mods() -> void:
 loaded_mods.clear()

 var game_dir := OS.get_executable_path().get_base_dir()
 var mods_dir := game_dir.path_join(MODS_FOLDER)

 # Создать папку mods, если её нет
 DirAccess.make_dir_recursive_absolute(mods_dir)

 var dir := DirAccess.open(mods_dir)

 if dir == null:
  push_error("Не удалось открыть папку модов: " + mods_dir)
  mods_loaded.emit()
  return

 dir.list_dir_begin()

 var file := dir.get_next()

 while file != "":
  if !dir.current_is_dir() and file.get_extension().to_lower() == "pck":
   var mod_path := mods_dir.path_join(file)

   if ProjectSettings.load_resource_pack(mod_path):
	loaded_mods.append(file)
	print("Загружен мод: ", file)
   else:
	push_warning("Не удалось загрузить мод: " + file)

  file = dir.get_next()

 dir.list_dir_end()

 print("Загружено модов: ", loaded_mods.size())

 mods_loaded.emit()
