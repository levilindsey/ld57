class_name WordBasedbilityController
extends AbilityController


var word: Ability


func _create_ability_word_from_pending_characters(value: String) -> void:
    word = G.manifest.ability_scene.instantiate()
    G.level.player_projectiles.add_child(word)

    var position := G.level.pending_text.get_center()

    var characters := G.level.pending_text.get_characters()

    var matched_characters := characters.slice(characters.size() - value.length())

    # NOTE: Do nothing with the unmatched characters, since they'll be discarded
    #       by cancel_pending_text().
    #var unmatched_characters := characters.slice(0, characters.size() - value.length())

    word.set_up(matched_characters, position, true)

    word.stop_characters_animation()


func _explode() -> void:
    word.explode_from_point(
        word.global_position,
        PI,
        1.0,
        1.0,
        word.get_current_direction_angle())


func is_complete() -> bool:
    return not is_instance_valid(word)
