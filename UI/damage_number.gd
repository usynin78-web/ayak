extends Node2D

@onready var label: Label = $Label

func _process(_delta: float) -> void:
 z_index = 500

func setup(amount: int) -> void:
    label.text = "-" + str(amount)

    var tween := create_tween()

    # Поднимаем цифру вверх.
    tween.parallel().tween_property(
        self,
        "position:y",
        position.y - 50,
        0.7
    )

    # Постепенно исчезаем.
    tween.parallel().tween_property(
        self,
        "modulate:a",
        0.0,
        0.7
    )

    await tween.finished
    queue_free()
