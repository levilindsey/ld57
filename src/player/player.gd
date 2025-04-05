class_name Player
extends Node2D


signal main_menu_finished
signal death_finished
signal reset_finished

@export var default_cursor_margin := 1.0

var is_invincible_from_damage_cooldown := false
var is_invincible_from_power_up := false

var health := 0

var last_text_time_sec := 0.0
var last_text_entered := ""


func _ready() -> void:
    %Cursor.scale = G.manifest.default_cursor_scale * Vector2.ONE

    health = G.manifest.starting_health

    _set_scratch_text_position()

    %CursorBlinkTimer.wait_time = G.manifest.cursor_blink_period_sec
    %CursorBlinkTimer.connect("timeout", _on_cursor_blink_timeout)


func _process(delta: float) -> void:
    var current_time_sec := Time.get_ticks_msec() / 1000.0
    if (last_text_time_sec > 0.0 and
            current_time_sec > last_text_time_sec + G.manifest.cancel_pending_text_delay_sec):
        _cancel_pending_text()


func play_main_menu_animation() -> void:
    %CursorWrapper.modulate.a = G.manifest.cursor_blink_in_alpha
    %CursorBlinkTimer.start()

    # TODO: Play the main-menu typing animation.

    await get_tree().create_timer(
        G.manifest.main_menu_animation_duration_sec).timeout

    main_menu_finished.emit()


func on_game_started() -> void:
    pass


func play_death_animation() -> void:
    %CursorBlinkTimer.stop()
    %CursorWrapper.modulate.a = G.manifest.cursor_blink_in_alpha

    # TODO: Animate cursor rotation sideways and float upward (use an animation tree?).

    await get_tree().create_timer(
        G.manifest.player_death_animation_duration_sec).timeout

    death_finished.emit()


func play_reset_animation() -> void:
    health = G.manifest.starting_health

    # TODO: Rotate player back to starting orientation (use an animation tree?).

    await get_tree().create_timer(
        G.manifest.level_reset_animation_duration_sec).timeout

    reset_finished.emit()


func _on_cursor_blink_timeout() -> void:
    %CursorWrapper.modulate.a = (
        G.manifest.cursor_blink_out_alpha
        if %CursorWrapper.modulate.a == G.manifest.cursor_blink_in_alpha
        else G.manifest.cursor_blink_in_alpha
    )


func _set_scratch_text_position() -> void:
    var character := await Character.create(%ScratchText, "M", Character.Type.PLAYER)

    # TODO: Check if this delay is needed.
    await get_tree().process_frame

    %ScratchText.position.x = -character.get_size().x * 0.5
    %ScratchText.position.y = character.get_size().y * 0.075

    character.queue_free()


func on_enter() -> void:
    pass


func on_tab() -> void:
    pass


func on_space() -> void:
    var character := await Character.create(%ScratchText, "M", Character.Type.PLAYER)

    # TODO: Check if this delay is needed.
    await get_tree().process_frame

    var desired_position_x := self.position.x + character.get_size().x
    var max_position_x := G.manifest.game_area_size.x - G.manifest.game_area_padding.x

    if desired_position_x <= max_position_x:
        # Space entered successfully.
        self.position.x = desired_position_x
    else:
        # Space failed.

        # TODO(Alden): SFX
        pass

    character.queue_free()

    _cancel_pending_text()


func on_backspace() -> void:
    var character := await Character.create(%ScratchText, "M", Character.Type.PLAYER)

    # TODO: Check if this delay is needed.
    await get_tree().process_frame

    var desired_position_x := self.position.x - character.get_size().x
    var min_position_x := G.manifest.game_area_padding.x

    if desired_position_x >= min_position_x:
        # Backspace entered successfully.
        self.position.x = desired_position_x
    else:
        # Backspace failed.

        # TODO(Alden): SFX
        pass

    character.queue_free()

    _cancel_pending_text()


func on_character_entered(text: String) -> void:
    var character := await Character.create(%ScratchText, text.to_upper(), Character.Type.PLAYER)

    # TODO: Check if this delay is needed.
    await get_tree().process_frame

    var desired_position_x := self.position.x + character.get_size().x
    var max_position_x := G.manifest.game_area_size.x - G.manifest.game_area_padding.x

    if desired_position_x <= max_position_x:
        # Character entered successfully.
        self.position.x = desired_position_x
        last_text_entered = text.to_upper()
        last_text_time_sec = Time.get_ticks_msec() / 1000.0
    else:
        # Character failed.
        character.queue_free()

        # TODO(Alden): SFX
        pass

        return

    if text == " " or text == "\t":
        # Remove the character.
        character.queue_free()
    else:
        # Reparent the character.
        G.level.add_pending_character(character)

    # TODO: Check if this delay is needed.
    await get_tree().process_frame

    # TODO: Add the character to the pending string.

    # TODO:
    var is_ability_word_completed := false

    if is_ability_word_completed:
        # TODO:
        pass

        # TODO(Alden): SFX
        pass
    else:
        # TODO:
        pass

        # TODO(Alden): SFX
        pass


func _cancel_pending_text() -> void:
    last_text_time_sec = 0.0
    # TODO: Implement this.
    pass


func _consume_pending_text_for_ability() -> void:
    # TODO:
    # - Call this.
    # - Implement this.
    pass


func _take_damage() -> void:
    if is_invincible_from_damage_cooldown or is_invincible_from_power_up or health <= 0:
        # Cannot take damage right now.
        return

    health = max(health - 1, 0)

    if health <= 0:
        G.level.game_game_over()
    else:
        # TODO(Alden): SFX
        pass


func _on_area_2d_area_entered(area: Area2D) -> void:
    if area.collision_layer & GameManifest.TERRAIN_COLLISION_LAYER:
        _on_collided_with_terrain(area)
    elif area.collision_layer & GameManifest.ENEMY_COLLISION_LAYER:
        _on_collided_with_enemy(area)
    elif area.collision_layer & GameManifest.PICKUP_COLLISION_LAYER:
        _on_collided_with_pickup(area)
    elif area.collision_layer & GameManifest.ENEMY_PROJECTILE_COLLISION_LAYER:
        _on_collided_with_enemy_projectile(area)


func _on_collided_with_terrain(area: Area2D) -> void:
    _take_damage()


func _on_collided_with_enemy(area: Area2D) -> void:
    _take_damage()


func _on_collided_with_enemy_projectile(area: Area2D) -> void:
    _take_damage()


func _on_collided_with_pickup(area: Area2D) -> void:
    # TODO:
    pass
