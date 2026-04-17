extends Control

@onready var anim_player = $AnimationPlayer
@onready var start_button = $VBoxContainer/start
@onready var continue_button = $VBoxContainer/continue
@onready var exit_button = $VBoxContainer/exit
@onready var loading_screen: AnimatedSprite2D = $loading

var started = false

func _ready():
 start_button.visible = false
 continue_button.visible = false
 exit_button.visible = false
 loading_screen.visible = false

 start_button.pressed.connect(_on_start_pressed)
 continue_button.pressed.connect(_on_continue_pressed)
 exit_button.pressed.connect(_on_exit_pressed)

func _input(event):
 if not started and event is InputEventKey and event.pressed:
  started = true
  anim_player.play("title_up")
  start_button.visible = true
  exit_button.visible = true

  if CheckpointManager.has_save():
   continue_button.visible = true

func _on_start_pressed():
 var tree = get_tree()
 loading_screen.visible = true
 loading_screen.play()
 await _play_loading_animation_fully()

 if tree:
  if CheckpointManager.has_save():
   CheckpointManager.clear_save()  
  tree.change_scene_to_file("res://loc/roomtest/roomtest.tscn")
 else:
  push_error("SceneTree не найден")

func _on_continue_pressed():
 var tree = get_tree()
 loading_screen.visible = true
 loading_screen.play()
 await _play_loading_animation_fully()

 if tree:
  tree.change_scene_to_file("res://loc/roomtest/roomtest.tscn")
 else:
  push_error("SceneTree не найден")

func _on_exit_pressed():
 get_tree().quit()

func _play_loading_animation_fully() -> void:
 if loading_screen == null or loading_screen.sprite_frames == null:
  return

 var animation_name := loading_screen.animation
 if animation_name == "":
  return

 var frame_count := loading_screen.sprite_frames.get_frame_count(animation_name)
 var fps := loading_screen.sprite_frames.get_animation_speed(animation_name)
 var speed_scale := abs(loading_screen.speed_scale)

 if frame_count <= 0 or fps <= 0.0 or speed_scale <= 0.0:
  return

 var animation_duration := float(frame_count) / (fps * speed_scale)
 await get_tree().create_timer(animation_duration).timeout
