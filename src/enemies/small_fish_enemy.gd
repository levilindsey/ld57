class_name SmallFishEnemy
extends EnemyController


func start(config: Dictionary, value: String, position: Vector2) -> void:
    super.start(config, value, position)

    word.oscillation_direction = Vector2.RIGHT
    word.oscillation_amplitude = randf_range(30.0, 60.0)
    word.oscillation_interval_sec = randf_range(3.0, 6.0)

    var is_position_left_of_center := \
            position < G.manifest.game_area_size / 2.0

    word.translation_direction = Vector2.RIGHT
    word.translation_speed = randf_range(20.0, 60.0) * (1 if is_position_left_of_center else -1)

    word.moves_toward_player = false
