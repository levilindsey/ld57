class_name SideEffectAbilityController
extends AbilityController


func _create_ability_word_from_pending_characters(value: String) -> void:
    super._create_ability_word_from_pending_characters(value)

    word.is_active = false

    var slide_to_baseline_duration_sec := 0.1
    word.slide_characters_to_baseline(slide_to_baseline_duration_sec)

    await word.get_tree().create_timer(
        slide_to_baseline_duration_sec + 0.01).timeout

    if is_complete():
        return

    word.explode_from_point(
        word.global_position,
        PI,
        0.2,
        1.0,
        PI / 2.0)


func is_complete() -> bool:
    return not is_instance_valid(word)
