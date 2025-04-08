class_name BigFishEnemy
extends EnemyController


func start(config: Dictionary, value: String, position: Vector2) -> void:
    super.start(config, value, position)

    word.oscillation_direction = Vector2.RIGHT
    word.oscillation_amplitude = randf_range(100.0, 200.0)
    word.oscillation_interval_sec = randf_range(8.0, 12.0)

    word.translation_direction = Vector2.RIGHT
    word.translation_speed = 0.0

    word.moves_toward_player = false
