extends CharacterBody2D

## ------------------------------
## Основные параметры NPC
## ------------------------------

@export var run_speed: float = 90.0

## Контроллер патрулирования
@onready var patrol: Node = $PatrolController

## Навигация
@onready var navigation: NavigationAgent2D = $NavigationAgent2D

## Спрайт
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

## Для перспективы
@onready var feer_marker: Marker2D = $Marker2D

var base_scale: Vector2 = Vector2.ONE


func _ready() -> void:

	base_scale = sprite.scale

	## Передаём контроллеру путь к маркерам
	patrol.initialize(self)

	## Когда PatrolController выберет новую цель,
	## NavigationAgent автоматически построит путь.
	patrol.target_changed.connect(_on_target_changed)


func _physics_process(delta: float) -> void:

	patrol.update(delta, global_position)

	_move(delta)


func _move(_delta: float) -> void:
	print(navigation.is_navigation_finished())
	## Если путь закончился,
	## двигаться не нужно.
	if navigation.is_navigation_finished():
		velocity = Vector2.ZERO

		if sprite.animation != "idle":
			sprite.play("idle")
	
		move_and_slide()
		return

	## Следующая точка маршрута
	var next_position: Vector2 = navigation.get_next_path_position()

	var direction: Vector2 = global_position.direction_to(next_position)

	velocity = direction * run_speed

	sprite.flip_h = velocity.x < 0.0

	if sprite.animation != "walk":
		sprite.play("walk")

	move_and_slide()


func _process(_delta: float) -> void:

	z_index = int(feer_marker.global_position.y)

	update_perspective()


func update_perspective() -> void:

	var scale_factor: float = clampf(
		0.5 + global_position.y / 1000.0,
		0.5,
		1.5
	)

	sprite.scale = base_scale * scale_factor


func _on_target_changed(target: Vector2) -> void:
	print("Получил цель: ", target)
	navigation.target_position = target
