class_name Player
extends Node2D


signal main_menu_finished
signal death_finished
signal reset_finished

var _initial_font_size: float
var _initial_collision_shape_size: Vector2
var _initial_sprite_scale: Vector2

var default_character_size := Vector2.ZERO
var default_line_height := 0.0

var current_character_size := Vector2.ZERO
var current_line_height := 0.0

var is_invincible_from_power_up := false
var is_invincible_from_damage := false

var health := 0

var active_damage_collisions: Dictionary[Area2D, bool]

var main_menu_staggered_character_job: StaggeredCharacterJob

var is_active := true

var shield_controller

@onready var shape_cast: ShapeCast2D = %ShapeCast2D


func _ready() -> void:
    G.player = self
    GHack.player = self

    shape_cast.reparent(G.level)

    %Cursor.scale = G.manifest.default_cursor_scale * Vector2.ONE

    health = G.manifest.starting_health
    G.hud.update_health(health)
    is_active = true

    %InvicibleFromDamageTimer.wait_time = G.manifest.invincible_from_damage_cooldown_sec
    %CancelPendingTextTimer.wait_time = G.manifest.cancel_pending_text_delay_sec

    _update_cursor_blink_period()
    %InvicibleFromDamageTimer.connect("timeout", _on_invincible_from_damage_timeout)
    %CursorBlinkTimer.connect("timeout", _on_cursor_blink_timeout)
    %CancelPendingTextTimer.connect("timeout", _on_cancel_pending_text_timeout)

    await _initialize_sizes()

    self.position = get_start_position()
    G.level.pending_text.position = self.position


func _process(delta: float) -> void:
    if (G.level.state == Level.State.PLAYING and
            not active_damage_collisions.is_empty() and
            not is_invincible_from_damage):
        _take_damage()


func play_main_menu_animation() -> void:
    is_invincible_from_power_up = false
    is_invincible_from_damage = false

    health = G.manifest.starting_health
    G.hud.update_health(health)
    is_active = true

    active_damage_collisions.clear()

    _update_cursor_blink_period()

    %CursorWrapper.modulate.a = G.manifest.cursor_blink_in_alpha
    %CursorBlinkTimer.start()

    Anim.stop_stagger_character_job(main_menu_staggered_character_job)
    main_menu_staggered_character_job = Anim.stagger_calls_for_each_character(
            G.manifest.main_menu_text,
            G.manifest.main_menu_character_interval_sec,
            _on_main_menu_character_entered)

    await main_menu_staggered_character_job.stopped
    main_menu_staggered_character_job = null

    main_menu_finished.emit()


func on_game_started() -> void:
    # Fade-away the main-menu text.
    cancel_pending_text()


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
    G.hud.update_health(health)
    is_active = true

    %AnimationPlayer.play("resurrect")

    await get_tree().create_timer(
        G.manifest.level_reset_animation_duration_sec).timeout

    reset_finished.emit()


func activate_shield(shield_controller: ShieldAbility) -> void:
    # End any preexisting shield.
    if self.shield_controller != null:
        self.shield_controller._is_complete = true

    self.shield_controller = shield_controller

    is_invincible_from_power_up = true
    _update_cursor_blink_period()

    play_shield_activate_sound()

    await get_tree().create_timer(
        G.manifest.invincible_from_power_up_cooldown_sec).timeout

    if self.shield_controller != shield_controller:
        # A new shield was activated while this one was still active.
        return

    shield_controller._is_complete = true
    self.shield_controller = null

    play_shield_deactivate_sound()

    _on_invincible_from_power_up_timeout()


func _on_invincible_from_damage_timeout() -> void:
    is_invincible_from_damage = false
    _update_cursor_blink_period()


func _on_invincible_from_power_up_timeout() -> void:
    is_invincible_from_power_up = false
    _update_cursor_blink_period()


func _on_cursor_blink_timeout() -> void:
    %CursorWrapper.modulate.a = (
        G.manifest.cursor_blink_out_alpha
        if %CursorWrapper.modulate.a == G.manifest.cursor_blink_in_alpha
        else G.manifest.cursor_blink_in_alpha
    )


func _initialize_sizes() -> void:
    var character := G.manifest.character_scene.instantiate()
    character.modulate.a = 0.0
    character.set_text("M")
    character.set_type(Character.Type.TYPED_TEXT)
    add_child(character)

    var two_lines := G.manifest.character_scene.instantiate()
    two_lines.modulate.a = 0.0
    two_lines.set_text("M\nM")
    two_lines.set_type(Character.Type.TYPED_TEXT)
    add_child(two_lines)

    await get_tree().process_frame

    default_character_size = character.get_size()
    default_line_height = two_lines.get_size().y - default_character_size.y

    _initial_font_size = G.manifest.main_theme.default_font_size
    _initial_sprite_scale = %Cursor.scale
    _initial_collision_shape_size = %CollisionShape2D.shape.size
    shape_cast.shape.size = _initial_collision_shape_size

    set_current_text_size()

    character.queue_free()
    two_lines.queue_free()


func get_start_position() -> Vector2:
    var main_menu_offset_x := G.manifest.main_menu_text.length() * default_character_size.x / 2.0
    return Vector2(G.manifest.game_area_size.x / 2.0 - main_menu_offset_x, 0)


func set_text_color(color: Color) -> void:
    %Cursor.modulate = color


func set_current_text_size() -> void:
    # TODO: Update this if ever adding size-changing abilities.

    var current_size_ratio := 1.0

    current_character_size = default_character_size
    current_line_height = default_line_height

    var font_size := _initial_font_size * current_size_ratio
    var sprint_scale := _initial_sprite_scale * current_size_ratio
    var collision_shape_size := _initial_collision_shape_size * current_size_ratio

    %Cursor.scale = sprint_scale
    %CollisionShape2D.shape.size = collision_shape_size
    shape_cast.shape.size = collision_shape_size

    const _INITIAL_HACK_OFFSET_Y := 2.0
    var hack_offset_y := _INITIAL_HACK_OFFSET_Y * current_size_ratio
    G.level.pending_text.set_scratch_characters_offset(
            Vector2(0, -current_character_size.y / 2.0 + hack_offset_y))

    cancel_pending_text()


func _get_min_position_x() -> float:
    return G.manifest.game_area_padding.x


func _get_max_position_x() -> float:
    return G.manifest.game_area_size.x - G.manifest.game_area_padding.x


func _get_newline_position() -> Vector2:
    var previous_position := self.global_position

    shape_cast.enabled = true

    shape_cast.target_position = Vector2.ZERO

    var max_position_x := _get_max_position_x()

    var target_position := Vector2(
            _get_min_position_x() - current_character_size.x,
            self.global_position.y)

    var was_collision_detected := false

    var is_safe := false
    while not is_safe and target_position.x < max_position_x:
        target_position.x += current_character_size.x
        shape_cast.global_position = target_position
        shape_cast.force_shapecast_update()
        is_safe = not shape_cast.is_colliding()
        was_collision_detected = was_collision_detected or not is_safe

    if not S.utils.ensure(is_safe):
        target_position.x = _get_min_position_x()
    elif was_collision_detected:
        var safe_position_margin := current_character_size.x * 2
        target_position.x = minf(
            target_position.x + safe_position_margin,
            _get_max_position_x())

    shape_cast.enabled = false

    # Don't push the cursor rightward from where it was before.
    target_position.x = minf(previous_position.x, target_position.x)

    return target_position


func on_enter(is_held_key_duplicate_press: bool) -> void:
    G.level.new_line()

    self.global_position.x = _get_newline_position().x

    cancel_pending_text()

    G.level.pending_text.global_position = self.global_position

    %EnterSound.play()


func on_tab(is_held_key_duplicate_press: bool) -> void:
    pass


func on_space(is_held_key_duplicate_press: bool) -> void:
    await G.level.pending_text.add_space()

    var last_character_width := G.level.pending_text.get_last_character_size().x
    var desired_position_x := self.position.x + last_character_width

    if desired_position_x > _get_max_position_x():
        # Space failed.
        G.level.pending_text.delete_last_character()
        %FailureSound.play()
        return

    # Space entered successfully.
    self.position.x = desired_position_x
    %KeyboardSound.play()
    G.level.check_ability_text_match()
    _start_pending_text_timer()


func on_backspace(is_held_key_duplicate_press: bool) -> void:
    var last_character_width := current_character_size.x

    if not G.level.pending_text.text.is_empty():
        last_character_width = G.level.pending_text.get_last_character_size().x

    var desired_position_x := self.position.x - last_character_width

    if desired_position_x >= _get_min_position_x():
        # Backspace entered successfully.
        self.position.x = desired_position_x

        %KeyboardSound.play()
    else:
        # Backspace failed.
        %FailureSound.play()

    var was_something_deleted := \
        await G.level.pending_text.delete_last_character()

    if not was_something_deleted:
        G.level.pending_text.position = self.position

    G.level.check_ability_text_match()

    _start_pending_text_timer()


func _on_main_menu_character_entered(text: String) -> void:
    if text == " ":
        await G.level.pending_text.add_space()
    else:
        await G.level.pending_text.add_text(text, true)

    var last_character_width := G.level.pending_text.get_last_character_size().x

    self.position.x += last_character_width

    %KeyboardSound.play()


func on_character_entered(text: String, is_held_key_duplicate_press: bool) -> void:
    await G.level.pending_text.add_text(text)

    var last_character_width := G.level.pending_text.get_last_character_size().x
    var desired_position_x := self.position.x + last_character_width

    if desired_position_x > _get_max_position_x():
        # Character failed.
        G.level.pending_text.delete_last_character()
        %FailureSound.play()
        return

    # Character entered successfully.
    self.position.x = desired_position_x
    %KeyboardSound.play()
    G.level.check_ability_text_match()
    _start_pending_text_timer()


func _start_pending_text_timer() -> void:
    %CancelPendingTextTimer.wait_time = (
        G.manifest.cancel_pending_text_with_prefix_match_delay_sec if
        G.level.is_pending_text_a_prefix_match else
        G.manifest.cancel_pending_text_delay_sec
    )
    %CancelPendingTextTimer.start()


func _on_cancel_pending_text_timeout() -> void:
    cancel_pending_text()


func cancel_pending_text() -> void:
    var pending_text := G.level.pending_text.text

    %CancelPendingTextTimer.stop()

    G.level.clear_prefix_matches()

    if pending_text.is_empty():
        return

    S.log.print("Pending text canceled: %s" % pending_text)

    G.level.cancel_pending_characters()

    G.level.pending_text.position = self.position


func on_ability_triggered() -> void:
    cancel_pending_text()


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
    G.hud.update_health(health)
    G.clippy.on_damage()

    G.hud.set_clippy_text(
        G.manifest.clippy_damage_text,
        G.manifest.clippy_damage_text_duration_sec)

    if health <= 0:
        S.log.print("Player died")
        is_active = false
        G.level.game_game_over()
        %PlayerDiedSound.play()
    else:
        %PlayerDamagedSound.play()


func _update_cursor_blink_period() -> void:
    var period := (
        G.manifest.cursor_invincible_blink_period_sec
        if is_invincible_from_damage or is_invincible_from_power_up
        else G.manifest.cursor_blink_period_sec
    )
    %CursorBlinkTimer.stop()
    %CursorBlinkTimer.wait_time = period
    %CursorWrapper.modulate.a = G.manifest.cursor_blink_in_alpha
    %CursorBlinkTimer.start()


func _on_area_2d_area_entered(area: Area2D) -> void:
    if not is_active:
        return
    if area.collision_layer & GameManifest.TERRAIN_COLLISION_LAYER:
        _take_damage()
        active_damage_collisions[area] = true
    elif area.collision_layer & GameManifest.ENEMY_COLLISION_LAYER:
        if not area.get_parent().is_active:
            return
        _take_damage()
        active_damage_collisions[area] = true
    elif area.collision_layer & GameManifest.PICKUP_COLLISION_LAYER:
        _on_collided_with_pickup(area.get_parent())


func _on_area_2d_area_exited(area: Area2D) -> void:
    active_damage_collisions.erase(area)


func on_collided_with_enemy_projectile(projectile: Ability) -> void:
    if not is_active or not projectile.is_active:
        return
    _take_damage()


func _on_collided_with_pickup(pickup: Pickup) -> void:
    if not is_active or not pickup.is_active:
        return
    G.level.add_ability(pickup.ability_name, pickup.ability_value)
    pickup.explode_pickup()

    # HACK: Hardcoded pickup name check.
    var clippy_text: String = (
        G.manifest.clippy_shield_text[0] if
        pickup.ability_name == "shield" else
        G.manifest.clippy_torpedo_text[0]
    ) % pickup.ability_value
    G.hud.set_clippy_text(
        clippy_text,
        G.manifest.clippy_pickup_text_duration_sec)

    G.clippy.on_pickup()

    %PickupSound.play()


func play_torpedo_launch_sound() -> void:
    %TorpedoLaunchSound.play()


func play_torpedo_explode_sound() -> void:
    %TorpedoExplodeSound.play()


func play_shield_activate_sound() -> void:
    %ShieldActivateSound.play()


func play_shield_deactivate_sound() -> void:
    %ShieldDeactivateSonud.play()
