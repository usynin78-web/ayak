extends Control

const ScreenSettings = preload(
    "res://UI/settings/screen_settings.gd"
)

@onready var settings_list: VBoxContainer = $RightPanel/ScrollContainer/SettingsList

@onready var screen_button: Button = $LeftPanel/screen
@onready var graphic_button: Button = $LeftPanel/graphic
@onready var exit_button: Button = $LeftPanel/exit_to_menu

var screen_settings: RefCounted


func _ready() -> void:
    screen_settings = ScreenSettings.new(settings_list)

    screen_button.pressed.connect(_show_screen_settings)
    graphic_button.pressed.connect(_show_graphic_settings)
    exit_button.pressed.connect(_show_exit_settings)

    _show_screen_settings()


func _show_screen_settings() -> void:
    screen_settings.show_settings()


func _show_graphic_settings() -> void:
    for child in settings_list.get_children():
        child.queue_free()

    var title := Label.new()
    title.text = "ГРАФИКА"

    settings_list.add_child(title)


func _show_exit_settings() -> void:
    get_tree().change_scene_to_file(
        "res://UI/main menu/main menu.tscn"
    )
