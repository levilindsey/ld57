class_name WordBasedbilityController
extends AbilityController


var word: Ability


func _create_ability_word_from_pending_characters(value: String) -> void:
    word = G.manifest.ability_scene.instantiate()
    G.level.player_projectiles.add_child(word)

    # FIXME: This should only use the center of the MATCHED SUBSTRING!

    # HACK: This only supports monospace fonts.
    var character_size := G.player.current_character_size
    var matched_substring_size := Vector2(
        character_size.x * value.length(), character_size.y)

    var top_left := G.level.pending_text.get_top_left()
    var size := G.level.pending_text.size
    var middle_right := top_left + Vector2(size.x, size.y / 2.0)

    var matched_substring_center := \
            middle_right - Vector2(matched_substring_size.x / 2.0, 0)

    var characters := G.level.pending_text.get_characters()

    var matched_characters := characters.slice(characters.size() - value.length())

    # NOTE: Do nothing with the unmatched characters, since they'll be discarded
    #       by cancel_pending_text().
    #var unmatched_characters := characters.slice(0, characters.size() - value.length())

    word.set_up(matched_characters, matched_substring_center, true)

    word.stop_characters_animation()

    word.slide_characters_to_baseline()


func _explode() -> void:
    word.explode_from_point(
        word.global_position,
        PI,
        1.0,
        1.0,
        word.get_current_direction_angle())


func is_complete() -> bool:
    return not is_instance_valid(word)
