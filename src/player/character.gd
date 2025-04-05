class_name Character
extends Node2D


enum Type {
    PLAYER,
    ENEMY,
    TERRAIN,
    PICKUP,
    BUBBLE,
}


static func create(parent: Node, text: String, type: Type) -> Character:
    var character: Character = G.manifest.character_scene.instantiate()
    character.set_type(type)
    parent.add_child(character)
    await character.set_text(text)
    return character


func set_type(type: Type) -> void:
    var label_settings := _get_label_settings(type)
    %Label.label_settings = label_settings


#func set_color(color: Color) -> void:
    #%Label.add_theme_color_override("font_color", color)
#
#
#func set_outline_color(color: Color) -> void:
    #%Label.add_theme_color_override("font_outline_color", color)
#
#
#func set_font_size(size: int) -> void:
    #%Label.add_theme_font_size_override("font_size", size)


func set_text(text: String) -> void:
    %Label.text = text
    # TODO: Check if this delay is needed.
    await get_tree().process_frame
    var size := get_size()
    %Label.position = - size / 2.0


func get_size() -> Vector2:
    return %Label.size


func _get_label_settings(type: Type) -> LabelSettings:
    match type:
        Type.PLAYER:
            return G.manifest.player_label_settings
        Type.ENEMY:
            return G.manifest.enemy_label_settings
        Type.TERRAIN:
            return G.manifest.terrain_label_settings
        Type.PICKUP:
            return G.manifest.pickup_label_settings
        Type.BUBBLE:
            return G.manifest.bubble_label_settings
    return G.manifest.player_label_settings
