extends Node2D

func _draw():
	var markers := []

	for child in get_children():
		if child is Marker2D:
			markers.append(child)

	for i in range(markers.size() - 1):
		draw_line(
			markers[i].position,
			markers[i + 1].position,
			Color.GREEN,
			2
		)

	# Соединить последний и первый маркер.
	if markers.size() > 1:
		draw_line(
			markers[-1].position,
			markers[0].position,
			Color.GREEN,
			2
		)


func _process(_delta):
	queue_redraw()
