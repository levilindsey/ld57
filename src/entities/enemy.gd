class_name Enemy
extends Word


func set_up(text: String) -> void:
    set_up_from_text(text, Character.Type.ENEMY)


func on_hit_with_torpedo(torpedo: TorpedoAbility) -> void:
    explode_from_point(
        torpedo.global_position,
        PI,
        1.0,
        get_current_speed(),
        get_current_direction_angle())


# TODO: Implement.
