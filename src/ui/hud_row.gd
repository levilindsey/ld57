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


@export var is_highlighted := false:
    set(highlighted):
        is_highlighted = highlighted
        %Label.label_settings = (
            G.manifest.highlighted_hud_label_settings if
            is_highlighted else
            G.manifest.hud_label_settings
        )


@export var is_label_on_left := true:
    set(label_on_left):
        if label_on_left != is_label_on_left:
            is_label_on_left = label_on_left
            _update_label_on_left()


func _ready() -> void:
    %Label.text = label
    %Value.text = value
    if not is_label_on_left:
        _update_label_on_left()


func _update_label_on_left() -> void:
    var label_index := 0 if is_label_on_left else 1
    move_child(%Label, label_index)

    if is_label_on_left:
        %Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
        %Value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    else:
        %Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        %Value.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
