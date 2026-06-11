extends CharacterBody2D

const SPEED := 350
const RUN_MULTIPLIER := 2

# Время между ударами.
const ATTACK_COOLDOWN := 0.2
const ATTACK_RANGE := 230.0
const ATTACK_HALF_WIDTH := 90.0

@onready var sprite_front: Sprite2D = $c3f
@onready var sprite_back: Sprite2D = $c3b
@onready var sprite_left: Sprite2D = $c3l
@onready var sprite_right: Sprite2D = $c3r
@onready var feer_marker = $Marker2D

# Получаем доступ к системе здоровья игрока.
@onready var health_component: Node = $HealthComponent

var direction := Vector2.ZERO


# Последнее направление взгляда Кира.
var look_direction := Vector2.DOWN


var facing_direction := Vector2.DOWN
var base_scale := Vector2(1, 1)

func _process(_delta: float) -> void:
    z_index = int(feer_marker.global_position.y)

# Проверка, мёртв ли Кир.
# Если true — движение полностью остановится.
var is_dead: bool = false

# Можно ли атаковать сейчас.
var can_attack: bool = true


func _ready() -> void:
    global_position = CheckpointManager.get_spawn_position(global_position)

    hide_all_sprites()
    sprite_front.visible = true

    # Подключаем сигнал смерти.
    # Когда здоровье закончится, вызовется _on_died().
    health_component.died.connect(_on_died)


func _physics_process(_delta: float) -> void:
    # Если Кир мёртв — прекращаем обработку движения.
    if is_dead:
        velocity = Vector2.ZERO
        move_and_slide()
        return

    var input_vector := Vector2(
        Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
        Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    ).normalized()

    direction = input_vector

    # Запоминаем последнее направление движения.
    if input_vector != Vector2.ZERO:
        look_direction = input_vector

    velocity.x = direction.x * SPEED
    velocity.y = direction.y * SPEED

    if Input.is_action_pressed("ui_shift"):
        velocity *= RUN_MULTIPLIER

    # Атака по ЛКМ с кулдауном.
    if Input.is_action_just_pressed("attack") and can_attack:
        _attack()

    move_and_slide()

    if direction != Vector2.ZERO:
        hide_all_sprites()
  if abs(direction.x) > abs(direction.y):
   if direction.x > 0:
    facing_direction = Vector2.RIGHT
    sprite_right.visible = true
   else:
    facing_direction = Vector2.LEFT
    sprite_left.visible = true
  else:
   if direction.y > 0:
    facing_direction = Vector2.DOWN
    sprite_front.visible = true
   else:
    facing_direction = Vector2.UP
    sprite_back.visible = true

        if abs(direction.x) > abs(direction.y):
            if direction.x > 0:
                sprite_right.visible = true
            else:
                sprite_left.visible = true
        else:
            if direction.y > 0:
                sprite_front.visible = true
            else:
                sprite_back.visible = true

    update_perspective()


func hide_all_sprites() -> void:
    sprite_front.visible = false
    sprite_back.visible = false
    sprite_left.visible = false
    sprite_right.visible = false


func update_perspective() -> void:
    var scale_factor = 0.5 + global_position.y / 1000
    scale_factor = clamp(scale_factor, 0.5, 1.5)

    sprite_front.scale = base_scale * scale_factor
    sprite_back.scale = base_scale * scale_factor
    sprite_left.scale = base_scale * scale_factor
    sprite_right.scale = base_scale * scale_factor


func _on_died() -> void:
    # Отмечаем, что Кир умер.
    is_dead = true

    # Полностью останавливаем движение.
    velocity = Vector2.ZERO

    # Прячем направление движения.
    direction = Vector2.ZERO

    print("Кир умер. Движение остановлено.")


func _attack() -> void:

    # Запрещаем новую атаку до окончания кулдауна.
    can_attack = false

    print("Функция атаки вызвалась")

    if is_dead:
        print("Кир мёртв")
        can_attack = true
        return

    var targets = get_tree().get_nodes_in_group("damageable")

    print("Найдено целей:", targets.size())

    for target in targets:

        print("Цель:", target.name)

        # Направление от Кира к цели.
        var to_target = (target.global_position - global_position).normalized()

        # Проверяем, находится ли цель перед Киром.
        if look_direction.dot(to_target) < 0.5:
            print("Цель не перед Киром")
            continue

        var distance = global_position.distance_to(target.global_position)

        print("Дистанция:", distance)

        if distance > 250:
            print("Слишком далеко")
            continue

        var hp = target.get_node_or_null("AnimatedSprite2D/Area2D/HealthComponent")

        print("HP найден:", hp)

        if hp == null:
            continue

 var target = _find_attack_target(targets)

 if target != null:
  var hp = target.get_node_or_null("AnimatedSprite2D/Area2D/HealthComponent")

  print("Выбранная цель:", target.name)
  print("HP найден:", hp)

  if hp != null and hp.has_method("take_damage"):
   var damage := randi_range(20, 30)

   print("Кир ударил кубик")
   hp.take_damage(damage)
  elif hp == null:
   print("HP не найден")
  else:
   print("Нет метода take_damage")
 else:
  print("Нет цели в зоне удара")

        if not hp.has_method("take_damage"):
            print("Нет метода take_damage")
            continue

        var damage := randi_range(20, 30)

        print("Кир ударил кубик")

        hp.take_damage(damage)

        break

    # Ждём окончания кулдауна.
    await get_tree().create_timer(ATTACK_COOLDOWN).timeout

    # Разрешаем следующую атаку.
    can_attack = true
 # Разрешаем следующую атаку.
 can_attack = true


func _find_attack_target(targets: Array) -> Node2D:
 var attack_origin := feer_marker.global_position
 var attack_direction := facing_direction.normalized()
 var side_direction := Vector2(-attack_direction.y, attack_direction.x)
 var best_target: Node2D = null
 var best_score := INF

 for target in targets:
  if not (target is Node2D):
   continue

  var target_node := target as Node2D
  var hp = target_node.get_node_or_null("AnimatedSprite2D/Area2D/HealthComponent")

  if hp == null or not hp.has_method("take_damage"):
   print("Цель без HealthComponent или take_damage:", target_node.name)
   continue

  var target_position := _get_target_aim_position(target_node)
  var to_target := target_position - attack_origin
  var forward_distance := to_target.dot(attack_direction)
  var side_distance := abs(to_target.dot(side_direction))

  print("Цель:", target_node.name)
  print("Вперёд:", forward_distance, " Вбок:", side_distance)

  if forward_distance < 0.0:
   print("Цель позади")
   continue

  if forward_distance > ATTACK_RANGE:
   print("Слишком далеко")
   continue

  if side_distance > ATTACK_HALF_WIDTH:
   print("Слишком далеко сбоку")
   continue

  # Главный критерий — насколько цель лежит на линии удара. Дистанция вперёд
  # используется вторым весом, чтобы при равном направлении выбрать ближнего врага.
  var score := side_distance + forward_distance * 0.15

  if score < best_score:
   best_score = score
   best_target = target_node

 return best_target


func _get_target_aim_position(target: Node2D) -> Vector2:
 var target_marker := target.get_node_or_null("Marker2D") as Node2D

 if target_marker != null:
  return target_marker.global_position

 return target.global_position
