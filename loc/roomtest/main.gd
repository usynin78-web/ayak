extends Node2D

@onready var fade_anim: AnimationPlayer = $FadeLayer/AnimationPlayer
@onready var player: Node = $c3  # ссылка на игрока, чтобы остановить управление

func _process(_delta):
	# Ловим ESC через InputMap (ui_cancel)
	if Input.is_action_just_pressed("ui_cancel"):
		start_exit_to_menu()
	if Input.is_action_pressed("restart_game"):
		get_tree().reload_current_scene()


func start_exit_to_menu():
	# Останавливаем игрока
	if player:
		player.set_physics_process(false)
	# Запускаем анимацию fade out
	if fade_anim:
		fade_anim.play("fade_out")

# Эта функция должна быть подключена к сигналу animation_finished AnimationPlayer
func _on_FadeLayer_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_out":
		get_tree().change_scene_to_file("res://UI/main menu/main menu.tscn")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		get_tree().change_scene_to_file("res://UI/main menu/main menu.tscn")
