class_name Enemy
extends Word


func set_up(parent: Node, text: String, position: Vector2) -> void:
    set_up_from_text(
        parent,
        text,
        Character.Type.ENEMY,
        position)


func on_hit_with_torpedo(torpedo: TorpedoAbility) -> void:
    explode_from_point(
        torpedo.global_position,
        PI,
        100)


# TODO: Implement.
