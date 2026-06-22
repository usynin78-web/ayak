extends Label

@onready var player = $"../../c3"
@onready var room = $"../../room"

func _process(_delta):
	text = """
FPS: %d
X: %d
Y: %d
Локация: %s
""" % [
	Engine.get_frames_per_second(),
	int(player.global_position.x),
	int(player.global_position.y),
	room.location_id
]

func _input(event):
	if event.is_action_pressed("fps_toggle"):
		visible = !visible
