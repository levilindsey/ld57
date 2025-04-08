class_name EnemyController
extends RefCounted


var config: Dictionary
var value: String

var start_time_sec := 0.0

var word: Enemy


func start(config: Dictionary, value: String, position: Vector2) -> void:
    self.config = config
    self.value = value

    start_time_sec = Anim.get_current_time_sec()

    _create_enemy_word(value, position)


func is_complete() -> bool:
    return is_instance_valid(word)


func _create_enemy_word(value: String, position: Vector2) -> void:
    word = G.manifest.enemy_scene.instantiate()
    G.level.enemies.add_child(word)
    word.global_position = position

    word.set_up(value)

    word.stop_characters_animation()
