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
 await _play_loading_full_animation()

 if tree:
  if CheckpointManager.has_save():
   CheckpointManager.clear_save()
  tree.change_scene_to_file("res://loc/roomtest/roomtest.tscn")
 else:
  push_error("SceneTree не найден")

func _on_continue_pressed():
 var tree = get_tree()
 await _play_loading_full_animation()

 if tree:
  tree.change_scene_to_file("res://loc/roomtest/roomtest.tscn")
 else:
  push_error("SceneTree не найден")

func _play_loading_full_animation():
 loading_screen.visible = true
 loading_screen.play()

 var duration = _get_loading_animation_duration()
 if duration > 0.0:
  await get_tree().create_timer(duration).timeout
 else:
  await get_tree().process_frame

func _get_loading_animation_duration() -> float:
 if loading_screen.sprite_frames == null:
  return 0.0

 var animation_name = loading_screen.animation
 if animation_name == &"":
  return 0.0

 var frame_count = loading_screen.sprite_frames.get_frame_count(animation_name)
 if frame_count <= 0:
  return 0.0

 var total_frame_duration = 0.0
 for frame in frame_count:
  total_frame_duration += loading_screen.sprite_frames.get_frame_duration(animation_name, frame)

 var playback_speed = loading_screen.sprite_frames.get_animation_speed(animation_name) * absf(loading_screen.speed_scale)
 if playback_speed <= 0.0:
  return 0.0

 return total_frame_duration / playback_speed

func _on_exit_pressed():
 get_tree().quit()
