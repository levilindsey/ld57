class_name Pickup
extends Word


var ability_name: String
var ability_value: String


func set_up(name: String, value: String) -> void:
    ability_name = name
    ability_value = value
    set_up_from_text(value, Character.Type.PICKUP)


func explode_pickup() -> void:
    is_active = false

    # Explode weakly.
    explode_from_point(
        global_position,
        PI,
        1.0,
        get_current_speed(),
        get_current_direction_angle())
