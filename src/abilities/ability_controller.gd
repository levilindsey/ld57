class_name AbilityController
extends RefCounted


var config: Dictionary
var value: String

var start_time_sec := 0.0

var word: Ability


func start(config: Dictionary, value: String) -> void:
    self.config = config
    self.value = value

    start_time_sec = Anim.get_current_time_sec()

    _create_ability_word_from_pending_characters(value)


func is_complete() -> bool:
    return false


func _create_ability_word_from_pending_characters(value: String) -> void:
    word = G.manifest.ability_scene.instantiate()
    G.level.player_projectiles.add_child(word)

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
