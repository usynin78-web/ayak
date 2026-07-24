extends Camera2D

# Максимальное смещение камеры от центра
@export var max_offset := 30.0

# Скорость изменения смещения
@export var offset_speed := 3.0

func _process(delta: float) -> void:
	# Центр экрана
	var center := get_viewport_rect().size * 0.5

	# Положение мыши
	var mouse := get_viewport().get_mouse_position()

	# Вектор от центра к мыши
	var target_offset := mouse - center

	# Ограничиваем максимальное смещение
	if target_offset.length() > max_offset:
		target_offset = target_offset.normalized() * max_offset

	# Плавно изменяем offset
	offset = offset.lerp(target_offset, delta * offset_speed)
