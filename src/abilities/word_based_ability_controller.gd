class_name WordBasedAbilityController
extends AbilityController


func _create_ability_word_from_pending_characters(value: String) -> void:
    super._create_ability_word_from_pending_characters(value)

    word.slide_characters_to_baseline(0.15)


func _explode() -> void:
    word.explode_from_point(
        word.global_position,
        PI,
        1.0,
        1.0,
        word.get_current_direction_angle())


func is_complete() -> bool:
    return not is_instance_valid(word)
