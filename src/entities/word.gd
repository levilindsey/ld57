class_name Word
extends Node2D


var _animation: AnimationJob

var _type := Character.Type.TYPED_TEXT

var text := ""
var size := Vector2.ZERO

var is_active := true

@onready var scratch_characters: HBoxContainer = %ScratchCharacters
@onready var visible_characters: Node2D = %VisibleCharacters


func set_up_from_text(text: String, type: Character.Type) -> void:
    if text.is_empty():
        clear()
        return

    text = text.to_upper()

    self.text = text
    self._type = type

    for letter in text:
        var layout_character: InvisibleLayoutCharacter = \
                GHack.manifest.invisible_layout_character_scene.instantiate()
        layout_character.text = letter
        layout_character.set_type(type)
        scratch_characters.add_child(layout_character)

    await get_tree().process_frame

    if scratch_characters.get_children().is_empty():
        S.log.warning(
            "Word.set_up_from_text: layout_characters were freed before characters could be created.")
        return

    # HACK: For some reason, the HBoxContainer size was sometimes half what it should be.
    #self.size = scratch_characters.size
    var character_size: Vector2i = scratch_characters.get_children()[0].size
    self.size = Vector2i(
            character_size.x * text.length(),
            character_size.y)

    scratch_characters.position = - self.size / 2.0

    for layout_character in scratch_characters.get_children():
        var character: Character = GHack.manifest.character_scene.instantiate()
        character.set_text(layout_character.text)
        character.set_type(type)
        visible_characters.add_child(character)
        var text_extents: Vector2 = layout_character.size / 2.0
        var character_position: Vector2 = \
                layout_character.global_position + text_extents
        character.set_label_offset(-text_extents)
        character.global_position = character_position
        character.anchor_global_position = character_position
        character.anchor_relative_position = layout_character.position


func set_up_from_characters(
        characters: Array[Character],
        type: Character.Type) -> void:
    _type = type
    text = ""

    for character in characters:
        text += character.get_text()
        character.reparent(visible_characters, true)
        character.set_type(type)

        var layout_character: InvisibleLayoutCharacter = \
                GHack.manifest.invisible_layout_character_scene.instantiate()
        layout_character.text = character.get_text()
        layout_character.set_type(type)
        scratch_characters.add_child(layout_character)

    await get_tree().process_frame

    if scratch_characters.get_children().is_empty():
        S.log.warning(
            "Word.set_up_from_characters: layout_characters were freed before size could be established.")
        return

    self.size = scratch_characters.size
    scratch_characters.position = - self.size / 2.0


func add_text(text: String, is_main_menu_text := false) -> void:
    S.utils.ensure(text != " ")

    text = text.to_upper()

    self.text += text

    var layout_character: InvisibleLayoutCharacter = \
            GHack.manifest.invisible_layout_character_scene.instantiate()
    layout_character.text = text
    layout_character.set_type(_type)
    scratch_characters.add_child(layout_character)

    await get_tree().process_frame

    if not is_instance_valid(layout_character):
        S.log.warning(
            "Word.add_text: layout_character was freed before character could be created.")
        return

    self.size = scratch_characters.size

    var character: Character = GHack.manifest.character_scene.instantiate()
    character.set_text(text)
    character.set_type(_type)
    visible_characters.add_child(character)
    var text_extents := layout_character.size / 2.0
    var character_position := \
            layout_character.global_position + text_extents
    character.set_label_offset(-text_extents)
    character.global_position = character_position
    character.anchor_global_position = character_position
    character.anchor_relative_position = layout_character.position


func add_character(character: Character) -> void:
    text += character.get_text()
    character.set_type(_type)
    character.reparent(visible_characters, true)

    var layout_character: InvisibleLayoutCharacter = \
            GHack.manifest.invisible_layout_character_scene.instantiate()
    layout_character.text = character.get_text()
    layout_character.set_type(_type)
    scratch_characters.add_child(layout_character)

    await get_tree().process_frame

    if not is_instance_valid(layout_character):
        S.log.warning(
            "Word.add_character: layout_character was freed before size could be established.")
        return

    self.size = scratch_characters.size


func delete_last_character() -> bool:
    if text.is_empty():
        return false

    var was_last_character_space := text[text.length() - 1] == " "

    text = text.erase(text.length() - 1)

    var layout_characters := scratch_characters.get_children()
    if (
        not layout_characters.is_empty() and
        is_instance_valid(layout_characters.back())
    ):
        layout_characters.back().queue_free()

    if not was_last_character_space:
        var characters := visible_characters.get_children()
        if (
            not characters.is_empty() and
            is_instance_valid(characters.back())
        ):
            characters.back().queue_free()

    await get_tree().process_frame

    self.size = scratch_characters.size

    return true


func clear() -> void:
    text = ""
    size = Vector2.ZERO
    for layout_character in scratch_characters.get_children():
        layout_character.queue_free()
    for character in visible_characters.get_children():
        character.queue_free()


func destroy() -> void:
    stop_animation()
    stop_characters_animation()
    clear()
    queue_free()


func get_characters() -> Array[Character]:
    var nodes := visible_characters.get_children()
    var characters: Array[Character]
    characters.assign(nodes)
    return characters


func add_space() -> void:
    text += " "

    var layout_character: InvisibleLayoutCharacter = \
            GHack.manifest.invisible_layout_character_scene.instantiate()
    layout_character.text = " "
    layout_character.set_type(_type)
    scratch_characters.add_child(layout_character)

    await get_tree().process_frame

    if not is_instance_valid(layout_character):
        S.log.warning(
            "Word.add_space: layout_character was freed before size could be established.")
        return

    self.size = scratch_characters.size


func get_last_character_size() -> Vector2:
    if scratch_characters.get_children().is_empty():
        return Vector2.ZERO
    return scratch_characters.get_children().back().size


func get_center() -> Vector2:
    return scratch_characters.global_position + scratch_characters.size / 2.0


func get_top_left() -> Vector2:
    return scratch_characters.global_position


func get_bounds() -> Rect2:
    return Rect2(get_top_left(), size)


func get_visible_character_bounds() -> Rect2:
    var characters := visible_characters.get_children()
    if characters.is_empty():
        return Rect2()

    var bounds: Rect2 = characters[0].get_bounds()
    for index in range(1, characters.size()):
        bounds = bounds.merge(characters[index].get_bounds())

    return bounds


func set_type(type: Character.Type) -> void:
    for character in scratch_characters.get_children():
        character.set_type(type)
    for layout_character in visible_characters.get_children():
        layout_character.set_type(type)


func set_scratch_characters_offset(offset: Vector2) -> void:
    scratch_characters.position = offset


func get_current_speed() -> float:
    if is_instance_valid(_animation):
        return _animation.get_current_speed()
    else:
        return 0.0


func get_current_direction_angle() -> float:
    if is_instance_valid(_animation):
        return _animation.get_current_direction_angle()
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
    for character in visible_characters.get_children():
        config.start_speed = character.get_current_speed()
        character.start_animation(config)


func stop_characters_animation() -> void:
    for character in visible_characters.get_children():
        character.stop_animation()


func explode_from_point(
        impact_point: Vector2,
        spread_angle: float,
        strength: float,
        new_word_speed: float,
        new_word_direction_angle: float) -> void:
    is_active = false

    # - Sort characters by distance to impact point.
    # - Closer characters more directly away from the impact, while more distant
    #   characters move more orthogonally.
    var characters := get_characters().duplicate()
    characters.sort_custom(func(a: Character, b: Character):
        return (a.global_position.distance_squared_to(impact_point) <
                b.global_position.distance_squared_to(impact_point)))

    var direction_angle_offset := 0
    var direction_angle_delta := spread_angle / maxf(characters.size() - 1, 1)

    var duration_sec := 1.0

    for character in characters:
        var base_direction_angle: float = \
                (character.global_position - impact_point).angle()
        var offset := direction_angle_offset * (1 if randf() < 0.5 else -1)
        var direction_angle := base_direction_angle + offset

        direction_angle_offset += direction_angle_delta

        # Push outward.
        var config := {
            node = character,
            destroys_node_when_done = true,
            is_one_shot = true,
            ease_name = "ease_out",

            start_speed = 6.0 * strength,

            direction_angle = direction_angle,
            #direction_deviaton_angle_max = PI / 128.0,

            # These can all be either a single number, or an array of two numbers.
            duration_sec = duration_sec, # If omitted, the animation won't stop.
            end_opacity = 0.0,
            #interval_sec = 100.0, # If ommitted, duration_sec must be included.
            # Slow to a stop.
            speed = 0.0,
            #acceleration = -2,
            rotation_speed = [0.01 * strength, 15.0 * strength],
            #perpendicular_oscillation_amplitude = [0, 100.0],
            #scale_x = [0.5, 4.0],
            #scale_y = [0.5, 4.0],
            skew = [-PI * strength, PI * strength],
        }

        character.start_animation(config)

    stop_animation()

    if new_word_speed == 0.0:
        await get_tree().create_timer(duration_sec).timeout
        destroy()
    else:
        # Slide straight.
        var config := {
            node = self,
            destroys_node_when_done = true,
            is_one_shot = true,
            ease_name = "ease_out",

            start_speed = new_word_speed,

            direction_angle = new_word_direction_angle,
            #direction_deviaton_angle_max = PI / 128.0,

            # These can all be either a single number, or an array of two numbers.
            duration_sec = duration_sec, # If omitted, the animation won't stop.
            #end_opacity = 0.0,
            #interval_sec = 100.0, # If ommitted, duration_sec must be included.
            # Slow to a stop.
            speed = 0.0,
            #acceleration = -2,
            #rotation_speed = [0.01, 0.5],
            #perpendicular_oscillation_amplitude = [0, 100.0],
            #scale_x = [0.5, 4.0],
            #scale_y = [0.5, 4.0],
            #skew = [-PI, PI],
        }
        start_animation(config)


func slide_characters_to_baseline(duration_sec: float) -> void:
    for character in get_characters():
        var config := {
            node = character,
            destroys_node_when_done = false,
            is_one_shot = true,
            ease_name = "ease_in",

            #start_speed = 6.0 * strength,

            #direction_angle = direction_angle,
            #direction_deviaton_angle_max = PI / 128.0,

            # These can all be either a single number, or an array of two numbers.
            duration_sec = duration_sec, # If omitted, the animation won't stop.
            #end_opacity = 0.0,
            #interval_sec = 100.0, # If ommitted, duration_sec must be included.
            # Slow to a stop.
            #speed = 0.0,
            #acceleration = -2,
            #rotation_speed = [0.01, 15.0],
            #perpendicular_oscillation_amplitude = [0, 100.0],
            scale_x = 1,
            scale_y = 1,
            skew = 0,
            # HACK: Not sure why anchor_relative_position isn't working.
            position_x = character.position.x,
            #position_x = character.anchor_relative_position.x,
            position_y = 0,
        }

        character.start_animation(config)
