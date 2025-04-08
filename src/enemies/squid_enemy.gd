class_name SquidEnemy
extends EnemyController


func start(config: Dictionary, value: String, position: Vector2) -> void:
    super.start(config, value, position)

    word.oscillation_direction = Vector2.UP
    word.oscillation_amplitude = randf_range(30.0, 60.0)
    word.oscillation_interval_sec = randf_range(3.0, 8.0)

    word.translation_direction = Vector2.UP
    word.translation_speed = randf_range(10.0, 50.0)

    word.moves_toward_player = false
