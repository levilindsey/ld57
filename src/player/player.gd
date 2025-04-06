class_name Player
extends Node2D


signal main_menu_finished
signal death_finished
signal reset_finished

var default_character_size := Vector2.ZERO
var default_line_height := 0.0

var is_invincible_from_power_up := false
var is_invincible_from_damage := false

var health := 0

var last_text_entered := ""

var active_damage_collisions: Dictionary[Area2D, bool]

var main_menu_staggered_character_job: StaggeredCharacterJob


func _ready() -> void:
    %Cursor.scale = G.manifest.default_cursor_scale * Vector2.ONE

    health = G.manifest.starting_health

    %InvicibleFromDamageTimer.wait_time = G.manifest.invincible_from_damage_cooldown_sec

    _update_cursor_blink_period()
    %InvicibleFromDamageTimer.connect("timeout", _on_invincible_from_damage_timeout)
    %CursorBlinkTimer.connect("timeout", _on_cursor_blink_timeout)
    %CancelPendingTextTimer.connect("timeout", _on_cancel_pending_text_timeout)

    await _initialize_sizes()

    position = get_start_position()


func _process(delta: float) -> void:
    if (G.level.state == Level.State.PLAYING and
            not active_damage_collisions.is_empty() and
            not is_invincible_from_damage):
        _take_damage()


func play_main_menu_animation() -> void:
    is_invincible_from_power_up = false
    is_invincible_from_damage = false

    health = G.manifest.starting_health

    last_text_entered = ""

    active_damage_collisions.clear()

    _update_cursor_blink_period()

    %CursorWrapper.modulate.a = G.manifest.cursor_blink_in_alpha
    %CursorBlinkTimer.start()

    G.stop_stagger_character_job(main_menu_staggered_character_job)
    main_menu_staggered_character_job = G.stagger_calls_for_each_character(
            G.manifest.main_menu_text,
            G.manifest.main_menu_character_interval_sec,
            _on_main_menu_character_entered)

    await main_menu_staggered_character_job.stopped
    main_menu_staggered_character_job = null

    main_menu_finished.emit()


func on_game_started() -> void:
    # Fade-away the main-menu text.
    _cancel_pending_text()


func play_death_animation() -> void:
    %InvicibleFromDamageTimer.stop()
    %CursorBlinkTimer.stop()
    %CancelPendingTextTimer.stop()
    %CursorWrapper.modulate.a = G.manifest.cursor_blink_in_alpha

    %AnimationPlayer.play("die")

    await get_tree().create_timer(
        G.manifest.player_death_animation_duration_sec).timeout

    death_finished.emit()


func play_reset_animation() -> void:
    health = G.manifest.starting_health

    %AnimationPlayer.play("resurrect")

    await get_tree().create_timer(
        G.manifest.level_reset_animation_duration_sec).timeout

    reset_finished.emit()


func _on_invincible_from_damage_timeout() -> void:
    is_invincible_from_damage = false
    _update_cursor_blink_period()


func _on_cursor_blink_timeout() -> void:
    %CursorWrapper.modulate.a = (
        G.manifest.cursor_blink_out_alpha
        if %CursorWrapper.modulate.a == G.manifest.cursor_blink_in_alpha
        else G.manifest.cursor_blink_in_alpha
    )


func _initialize_sizes() -> void:
    var character := await Character.create(%ScratchText, "M", Character.Type.PLAYER)
    var two_lines := await Character.create(%ScratchText, "M\nM", Character.Type.PLAYER)

    # TODO: Check if this delay is needed.
    await get_tree().process_frame

    default_character_size = character.get_size()
    default_line_height = two_lines.get_size().y - default_character_size.y

    %ScratchText.position.x = -default_character_size.x * 0.5
    %ScratchText.position.y = default_character_size.y * 0.075

    character.queue_free()


func get_start_position() -> Vector2:
    var main_menu_offset_x := G.manifest.main_menu_text.length() * default_character_size.x / 2.0
    return Vector2(G.manifest.game_area_size.x * 0.5 - main_menu_offset_x, 0)


func set_text_color(color: Color) -> void:
    %Cursor.modulate = color


func on_enter() -> void:
    self.position.x = G.manifest.game_area_padding.x

    G.level.new_line()

    _cancel_pending_text()

    # TODO(Alden): SFX
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

        # SFX
        $AudioStreamPlayer_keyboard.play()
        pass
    else:
        # Space failed.

        # SFX
        $AudioStreamPlayer_failure.play()
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

        # SFX
        $AudioStreamPlayer_keyboard.play()
        pass
    else:
        # Backspace failed.
        
        # SFX
        $AudioStreamPlayer_failure.play()
        pass

    character.queue_free()

    _cancel_pending_text()


func _on_main_menu_character_entered(text: String) -> void:
    var character := await Character.create(%ScratchText, text.to_upper(), Character.Type.PLAYER)

    # TODO: Check if this delay is needed.
    await get_tree().process_frame

    self.position.x += character.get_size().x
    last_text_entered = text.to_upper()

    if text == " " or text == "\t":
        # Remove the character.
        character.queue_free()
    else:
        # Reparent the character.
        G.level.add_pending_character(character)

    # TODO: Check if this delay is needed.
    await get_tree().process_frame

    # TODO(Alden): SFX
    pass

    # TODO: Add the character to the pending string.
    pass


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
        $AudioStreamPlayer_keyboard.play()
        print("audio")
        %CancelPendingTextTimer.start()
    else:
        # Character failed.
        character.queue_free()

        # SFX
        $AudioStreamPlayer_failure.play()
        
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

        # SFX
        $AudioStreamPlayer_word.play()
        pass
    else:
        # TODO:
        pass

        # TODO(Alden): SFX
        pass


func _on_cancel_pending_text_timeout() -> void:
    _cancel_pending_text()


func _cancel_pending_text() -> void:
    %CancelPendingTextTimer.stop()
    # TODO: Implement this.
    pass


func _consume_pending_text_for_ability() -> void:
    %CancelPendingTextTimer.stop()
    # TODO:
    # - Call this.
    # - Implement this.
    pass


func _take_damage() -> void:
    if (G.level.state != Level.State.PLAYING or
            is_invincible_from_damage or
            is_invincible_from_power_up or
            health <= 0):
        # Cannot take damage right now.
        return

    S.log.print("Player taking damage")

    health = max(health - 1, 0)
    is_invincible_from_damage = true
    %InvicibleFromDamageTimer.start()
    _update_cursor_blink_period()

    if health <= 0:
        S.log.print("Player died")
        G.level.game_game_over()
    else:
        # TODO(Alden): SFX
        pass


func _update_cursor_blink_period() -> void:
    var period := (
        G.manifest.cursor_invincible_blink_period_sec
        if is_invincible_from_damage
        else G.manifest.cursor_blink_period_sec
    )
    %CursorBlinkTimer.stop()
    %CursorBlinkTimer.wait_time = period
    %CursorWrapper.modulate.a = G.manifest.cursor_blink_in_alpha
    %CursorBlinkTimer.start()


func _on_area_2d_area_entered(area: Area2D) -> void:
    if (area.collision_layer & GameManifest.TERRAIN_COLLISION_LAYER or
            area.collision_layer & GameManifest.ENEMY_COLLISION_LAYER or
            area.collision_layer & GameManifest.ENEMY_PROJECTILE_COLLISION_LAYER):
        _take_damage()
        active_damage_collisions[area] = true
    elif area.collision_layer & GameManifest.PICKUP_COLLISION_LAYER:
        _on_collided_with_pickup(area)


func _on_area_2d_area_exited(area: Area2D) -> void:
    active_damage_collisions.erase(area)


func _on_collided_with_pickup(area: Area2D) -> void:
    # TODO:
    pass
