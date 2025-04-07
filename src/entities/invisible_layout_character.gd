class_name InvisibleLayoutCharacter
extends Label


func set_type(type: Character.Type) -> void:
    label_settings = Character._get_label_settings(type)
