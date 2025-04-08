class_name Pickup
extends Word


var ability_name: String
var ability_value: String


func set_up(name: String, value: String) -> void:
    ability_name = name
    ability_value = value

    await set_up_from_text(value, Character.Type.PICKUP)

    # HACK: Make pickups easier to collect, AND there's a bug with their size calculation
    #var pickup_size_multiplier_x := (
        #2.0 if
        #value.contains(" ") else
        #1.0
    #)
    var pickup_size_multiplier_x := 1.0
    var pickup_size_multiplier_y := 1.1

    await get_tree().process_frame

    %CollisionShape2D.shape.size = scratch_characters.size
    %CollisionShape2D.shape.size.x *= pickup_size_multiplier_x
    %CollisionShape2D.shape.size.y *= pickup_size_multiplier_y


func explode_pickup() -> void:
    is_active = false

    # Explode weakly.
    explode_from_point(
        global_position,
        PI,
        1.0,
        get_current_speed(),
        get_current_direction_angle())
