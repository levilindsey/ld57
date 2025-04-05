class_name LevelFragment
extends Node2D


var height := 0.0


func _ready() -> void:
    if !S.utils.ensure(is_instance_valid($FragmentBottom),
            "Each Fragment must have a FragmentBottom node that defines how tall the fragment is."):
        return

    height = $FragmentBottom.position.y
