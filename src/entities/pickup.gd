class_name Pickup
extends Word


var ability_name: String
var ability_value: String


func set_up(name: String, value: String) -> void:
    ability_name = name
    ability_value = value

    await set_up_from_text(value, Character.Type.PICKUP)

    _set_size()


func _set_size() -> void:
    var bounds := get_visible_character_bounds()
    var padding := Vector2(5.0, 10.0)

    %CollisionShape2D.shape = %CollisionShape2D.shape.duplicate()
    %CollisionShape2D.shape.size = bounds.size + padding


func explode_pickup() -> void:
    is_active = false

    # Explode weakly.
    explode_from_point(
        global_position,
        PI,
        1.0,
        get_current_speed(),
        get_current_direction_angle())


func on_hit_with_torpedo(torpedo: TorpedoAbility) -> void:
    G.player._on_collided_with_pickup(self)


func on_hit_with_drop(drop: DropAbility) -> void:
    G.player._on_collided_with_pickup(self)
