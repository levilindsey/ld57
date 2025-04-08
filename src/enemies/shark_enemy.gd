class_name SharkEnemy
extends EnemyController


func start(config: Dictionary, value: String, position: Vector2) -> void:
    super.start(config, value, position)

    word.oscillation_direction = Vector2.RIGHT
    word.oscillation_amplitude = 0.0
    word.oscillation_interval_sec = 0.0

    word.translation_direction = Vector2.RIGHT
    word.translation_speed = randf_range(40.0, 120.0)

    word.moves_toward_player = true
