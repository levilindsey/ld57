class_name Pickup
extends Word


# TODO: Assign these
var ability_name: String
var ability_value: String


func set_up(parent: Node, text: String, position: Vector2) -> void:
    set_up_from_text(
        parent,
        text,
        Character.Type.PICKUP,
        position)


func explode_pickup() -> void:
    is_active = false

    # Explode weakly.
    explode_from_point(
        global_position,
        PI,
        10)


# TODO: Implement.
