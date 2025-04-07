@tool
class_name LevelFragment
extends Node2D


var bounds: Rect2


func cache_bounds() -> void:
    bounds = _calculate_bounds()


func _calculate_bounds() -> Rect2:
    var bounds := Rect2(global_position, Vector2.ZERO)

    for child in get_children():
        if child is FragmentPart:
            bounds = bounds.merge(child.get_bounds())
        elif child is FragmentBottom:
            bounds = bounds.expand(child.global_position)

    # Include a one-line margin.
    bounds.size.y += G.player.default_line_height

    return bounds
