class_name HudRow
extends HBoxContainer


@export var label := "":
    set(text):
        label = text
        if is_instance_valid(%Label):
            %Label.text = text


@export var value := "":
    set(text):
        value = text
        if is_instance_valid(%Value):
            %Value.text = text


func _ready() -> void:
    %Label.text = label
    %Value.text = value
