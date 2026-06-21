extends Control

func _ready():
 $VBoxContainer/windowed.pressed.connect(_on_windowed_pressed)
 $VBoxContainer/fullscreen.pressed.connect(_on_fullscreen_pressed)
 $VBoxContainer/exit_to_menu.pressed.connect(_on_exit_to_menu_pressed)

func _on_windowed_pressed():
 DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_fullscreen_pressed():
 DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_exit_to_menu_pressed():
 get_tree().change_scene_to_file("res://UI/main menu/main menu.tscn")
