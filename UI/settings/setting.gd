extends Control

const ScreenSettings = preload(
 "res://UI/settings/screen_settings.gd"
)

const GraphicSettings = preload(
 "res://UI/settings/graphic_settings.gd"
)

@onready var settings_list: VBoxContainer = $RightPanel/ScrollContainer/SettingsList

@onready var screen_button: Button = $LeftPanel/screen
@onready var graphic_button: Button = $LeftPanel/graphic
@onready var exit_button: Button = $LeftPanel/exit_to_menu

var screen_settings: RefCounted
var graphic_settings: Node


func _ready() -> void:
 screen_settings = ScreenSettings.new(settings_list)

 graphic_settings = GraphicSettings.new()
 graphic_settings.setup(settings_list)

 screen_button.pressed.connect(_show_screen_settings)
 graphic_button.pressed.connect(_show_graphic_settings)
 exit_button.pressed.connect(_show_exit_settings)

 _show_screen_settings()


func _show_screen_settings() -> void:
 screen_settings.show_settings()


func _show_graphic_settings() -> void:
 graphic_settings.show_settings()


func _show_exit_settings() -> void:
 get_tree().change_scene_to_file(
  "res://UI/main menu/main menu.tscn"
 )
