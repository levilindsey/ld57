@tool
class_name FragmentPart
extends Node2D


const _default_game_area_size := Vector2i.ONE * 768


@export var is_left := true:
    set(value):
        is_left = value
        scale.x = (
            1 if
            is_left else
            -1
        )
        var game_area_size := (
            G.manifest.game_area_size if
            not Engine.is_editor_hint() and is_instance_valid(G.manifest) else
            _default_game_area_size
        )
        position.x = (
            0 if
            is_left else
            game_area_size.x
        )


func get_bounds() -> Rect2:
    var bounds := Geometry.get_bounding_box_for_points(
        %CollisionPolygon2D.polygon)
    bounds.position += %CollisionPolygon2D.global_position
    return bounds
