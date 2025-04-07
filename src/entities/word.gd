class_name Word
extends Node2D


var _animation: AnimationJob

var _type := Character.Type.TYPED_TEXT

var text := ""
var size := Vector2.ZERO


func set_up_from_text(
        parent: Node, text: String, type: Character.Type, position: Vector2) -> void:
    if text.is_empty():
        clear()
        return

    text = text.to_upper()

    self.text = text
    self._type = type

    for letter in text:
        var layout_character: InvisibleLayoutCharacter = \
                G.manifest.invisible_layout_character_scene.instantiate()
        layout_character.text = letter
        layout_character.set_type(type)
        %ScratchCharacters.add_child(layout_character)

    await get_tree().process_frame

    if %ScratchCharacters.get_children().is_empty():
        S.log.warning(
            "Word.set_up_from_text: layout_characters were freed before characters could be created.")
        return

    self.size = %ScratchCharacters.size
    %ScratchCharacters.position = -self.size / 2

    for layout_character in %ScratchCharacters.get_children():
        var character: Character = G.manifest.character_scene.instantiate()
        character.set_text(layout_character.text)
        character.set_type(type)
        %VisibleCharacters.add_child(character)
        var text_extents: Vector2 = layout_character.size / 2
        var character_position: Vector2 = \
                layout_character.global_position + text_extents
        character.set_label_offset(-text_extents)
        character.global_position = character_position
        character.anchor_position = character_position


func set_up_from_characters(
        characters: Array[Character], type: Character.Type) -> void:
    _type = type
    text = ""

    for character in characters:
        text += character.get_text()
        character.reparent(%VisibleCharacters, true)
        character.set_type(type)

        var layout_character: InvisibleLayoutCharacter = \
                G.manifest.invisible_layout_character_scene.instantiate()
        layout_character.text = character.get_text()
        layout_character.set_type(type)
        %ScratchCharacters.add_child(layout_character)

    await get_tree().process_frame

    if %ScratchCharacters.get_children().is_empty():
        S.log.warning(
            "Word.set_up_from_characters: layout_characters were freed before size could be established.")
        return

    self.size = %ScratchCharacters.size
    %ScratchCharacters.position = -self.size / 2


func add_text(text: String, is_main_menu_text := false) -> void:
    S.utils.ensure(text != " ")

    text = text.to_upper()

    self.text += text

    var layout_character: InvisibleLayoutCharacter = \
            G.manifest.invisible_layout_character_scene.instantiate()
    layout_character.text = text
    layout_character.set_type(_type)
    %ScratchCharacters.add_child(layout_character)

    await get_tree().process_frame

    if not is_instance_valid(layout_character):
        S.log.warning(
            "Word.add_text: layout_character was freed before character could be created.")
        return

    self.size = %ScratchCharacters.size

    var character: Character = G.manifest.character_scene.instantiate()
    character.set_text(text)
    character.set_type(_type)
    %VisibleCharacters.add_child(character)
    var text_extents := layout_character.size / 2
    var character_position := \
            layout_character.global_position + text_extents
    character.set_label_offset(-text_extents)
    character.global_position = character_position
    character.anchor_position = character_position


func add_character(character: Character) -> void:
    text += character.get_text()
    character.set_type(_type)
    character.reparent(%VisibleCharacters, true)

    var layout_character: InvisibleLayoutCharacter = \
            G.manifest.invisible_layout_character_scene.instantiate()
    layout_character.text = character.get_text()
    layout_character.set_type(_type)
    %ScratchCharacters.add_child(layout_character)

    await get_tree().process_frame

    if not is_instance_valid(layout_character):
        S.log.warning(
            "Word.add_character: layout_character was freed before size could be established.")
        return

    self.size = %ScratchCharacters.size


func delete_last_character() -> bool:
    if text.is_empty():
        return false

    var was_last_character_space := text[text.length() - 1] == " "

    text = text.erase(text.length() - 1)

    var layout_characters := %ScratchCharacters.get_children()
    if (
        not layout_characters.is_empty() and
        is_instance_valid(layout_characters.back())
    ):
        layout_characters.back().queue_free()

    if not was_last_character_space:
        var characters := %VisibleCharacters.get_children()
        if (
            not characters.is_empty() and
            is_instance_valid(characters.back())
        ):
            characters.back().queue_free()

    await get_tree().process_frame

    self.size = %ScratchCharacters.size

    return true


func clear() -> void:
    text = ""
    size = Vector2.ZERO
    for layout_character in %ScratchCharacters.get_children():
        layout_character.queue_free()
    for character in %VisibleCharacters.get_children():
        character.queue_free()


func get_characters() -> Array:
    return %VisibleCharacters.get_children()


func add_space() -> void:
    text += " "

    var layout_character: InvisibleLayoutCharacter = \
            G.manifest.invisible_layout_character_scene.instantiate()
    layout_character.text = " "
    layout_character.set_type(_type)
    %ScratchCharacters.add_child(layout_character)

    await get_tree().process_frame

    if not is_instance_valid(layout_character):
        S.log.warning(
            "Word.add_space: layout_character was freed before size could be established.")
        return

    self.size = %ScratchCharacters.size


func get_last_character_size() -> Vector2:
    if %ScratchCharacters.get_children().is_empty():
        return Vector2.ZERO
    return %ScratchCharacters.get_children().back().size


func set_type(type: Character.Type) -> void:
    for character in %ScratchCharacters.get_children():
        character.set_type(type)
    for layout_character in %VisibleCharacters.get_children():
        layout_character.set_type(type)


func set_scratch_characters_offset(offset: Vector2) -> void:
    %ScratchCharacters.position = offset


func get_current_speed() -> float:
    if is_instance_valid(_animation):
        return _animation.get_current_speed()
    else:
        return 0.0


func start_animation(config: Dictionary) -> AnimationJob:
    stop_animation()
    config.node = self
    _animation = Anim.start_animation(config)
    return _animation


func stop_animation() -> void:
    Anim.stop_animation(_animation)
    _animation = null


func start_characters_animation(config: Dictionary) -> void:
    for character in %VisibleCharacters.get_children():
        config.start_speed = character.get_current_speed()
        character.start_animation(config)


func stop_characters_animation() -> void:
    for character in %VisibleCharacters.get_children():
        character.stop_animation()
