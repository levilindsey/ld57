class_name Character
extends Node2D


enum Type {
    TYPED_TEXT,
    ABILITY,
    ENEMY,
    TERRAIN,
    PICKUP,
    BUBBLE,
}

var _animation: AnimationJob

var _type := Type.TYPED_TEXT

var anchor_position := Vector2.ZERO


static func _get_label_settings(type: Type) -> LabelSettings:
    match type:
        Type.TYPED_TEXT:
            return G.manifest.typed_text_label_settings
        Type.ABILITY:
            return G.manifest.ability_label_settings
        Type.ENEMY:
            return G.manifest.enemy_label_settings
        Type.TERRAIN:
            return G.manifest.terrain_label_settings
        Type.PICKUP:
            return G.manifest.pickup_label_settings
        Type.BUBBLE:
            return G.manifest.bubble_label_settings
    return G.manifest.player_label_settings


func set_type(type: Type) -> void:
    _type = type
    var label_settings := _get_label_settings(type)
    %Label.label_settings = label_settings


func set_text(text: String) -> void:
    %Label.text = text


func get_text() -> String:
    return %Label.text


func get_size() -> Vector2:
    return %Label.size


func set_label_offset(offset: Vector2) -> void:
    %Label.position = offset


func start_animation(config: Dictionary) -> AnimationJob:
    stop_animation()
    config.node = self
    _animation = Anim.start_animation(config)
    return _animation


func stop_animation() -> void:
    Anim.stop_animation(_animation)
    _animation = null
