class_name Level
extends ScaffolderLevel


enum State {
    LEVEL_LOADING,
    MAIN_MENU_PLAYING,
    MAIN_MENU_FINISHED,
    PLAYING,
    GAME_OVER_PLAYING,
    GAME_OVER_FINISHED,
    RESETTING_LEVEL,
}

var state := State.LEVEL_LOADING

var is_enter_pressed := false
var is_space_pressed := false
var is_backspace_pressed := false

var start_time_sec := 0.0
var last_color_update_time_sec := 0.0
var current_time_sec := 0.0

var last_enter_trigger_time_sec := 0.0
var last_space_trigger_time_sec := 0.0
var last_backspace_trigger_time_sec := 0.0

var player: Player


func _ready() -> void:
    super._ready()

    G.level = self
    G.manifest = S.manifest

    # Start zoomed in.
    %Camera2D.zoom = G.manifest.main_menu_camera_zoom * Vector2.ONE
    %Camera2D.offset.y = G.manifest.main_menu_camera_offset_y
    %Camera2D.position = Vector2(G.manifest.game_area_size.x * 0.5, 0)

    player = G.manifest.player_scene.instantiate()
    #player.position = Vector2(G.manifest.game_area_padding.x * 2.0, 0)
    player.position = %Camera2D.position
    add_child(player)

    player.main_menu_finished.connect(_on_main_menu_animation_finished)
    player.death_finished.connect(_on_game_over_animation_finished)
    player.reset_finished.connect(_on_reset_finished)

    S.log.print("Level ready")

    # TODO(Alden): Start playing music!

    _start_main_menu_animation()


func _input(event: InputEvent) -> void:
    if event is InputEventKey:
        var key_event: InputEventKey = event
        var key_code := key_event.keycode

        match key_code:
            KEY_SPACE:
                is_space_pressed = event.pressed
                if not is_space_pressed:
                    last_space_trigger_time_sec = 0.0
            KEY_BACKSPACE, KEY_DELETE:
                is_backspace_pressed = event.pressed
                if not is_backspace_pressed:
                    last_backspace_trigger_time_sec = 0.0
            KEY_ENTER:
                is_enter_pressed = event.pressed
                if not is_enter_pressed:
                    last_enter_trigger_time_sec = 0.0

        if event.pressed:
            match state:
                State.PLAYING:
                    match key_code:
                        KEY_SPACE:
                            # We call this separately with our own custom throttle period, so we
                            # don't have to tolerate the initial delay before repeated key entries
                            # are fired.
                            if last_space_trigger_time_sec == 0.0:
                                _trigger_space()
                            #player.on_space()
                        KEY_BACKSPACE, KEY_DELETE:
                            # We call this separately with our own custom throttle period, so we
                            # don't have to tolerate the initial delay before repeated key entries
                            # are fired.
                            if last_backspace_trigger_time_sec == 0.0:
                                _trigger_backspace()
                            #player.on_backspace()
                        KEY_ENTER:
                            # We call this separately with our own custom throttle period, so we
                            # don't have to tolerate the initial delay before repeated key entries
                            # are fired.
                            if last_enter_trigger_time_sec == 0.0:
                                _trigger_enter()
                            #player.on_enter()
                        KEY_TAB:
                            player.on_tab()
                        _:
                            # This key_code range corresponds to visual characters.
                            if event.unicode > 0:
                                player.on_character_entered(String.chr(event.unicode))
                            #if key_code >= KEY_EXCLAM and key_code <= KEY_SECTION:
                                #player.on_character_entered(OS.get_keycode_string(event.get_keycode_with_modifiers()))
                                #player.on_character_entered(OS.get_keycode_string(event.key_label))
                                #player.on_character_entered(String.chr(event.unicode))
                State.MAIN_MENU_FINISHED:
                    if key_code == KEY_ENTER:
                        _start_game()
                State.GAME_OVER_FINISHED:
                    if key_code == KEY_ENTER:
                        _game_reset()


func _process(delta: float) -> void:
    current_time_sec = Time.get_ticks_msec() / 1000.0

    if state == State.PLAYING:
        if is_space_pressed and current_time_sec >= last_space_trigger_time_sec + G.manifest.space_key_throttle_period_sec:
            _trigger_space()
        if is_backspace_pressed and current_time_sec >= last_backspace_trigger_time_sec + G.manifest.space_key_throttle_period_sec:
            _trigger_backspace()
        if is_enter_pressed and current_time_sec >= last_enter_trigger_time_sec + G.manifest.space_key_throttle_period_sec:
            _trigger_enter()

        if current_time_sec >= last_color_update_time_sec + G.manifest.color_update_period_sec:
            _update_colors()


func _trigger_space() -> void:
    last_space_trigger_time_sec = current_time_sec
    player.on_space()


func _trigger_backspace() -> void:
    last_backspace_trigger_time_sec = current_time_sec
    player.on_backspace()


func _trigger_enter() -> void:
    last_enter_trigger_time_sec = current_time_sec
    player.on_enter()


func _update_colors() -> void:
    var background_color := get_color(GameManifest.ColorType.BACKGROUND)
    var text_color := get_color(GameManifest.ColorType.TEXT)
    var player_outline_color := get_color(GameManifest.ColorType.PLAYER_OUTLINE)
    var enemy_outline_color := get_color(GameManifest.ColorType.ENEMY_OUTLINE)
    var terrain_outline_color := get_color(GameManifest.ColorType.TERRAIN_OUTLINE)
    var pickup_outline_color := get_color(GameManifest.ColorType.PICKUP_OUTLINE)
    var bubble_outline_color := get_color(GameManifest.ColorType.BUBBLE_OUTLINE)

    # TODO
    pass


func get_color(type: GameManifest.ColorType) -> Color:
    var start_color := G.manifest.get_start_color(type)
    var end_color := G.manifest.get_end_color(type)
    var progress := clampf((current_time_sec - start_time_sec) / G.manifest.color_transition_duration_sec, 0, 1)
    return lerp(start_color, end_color, progress)


func _transition_out_of_state(expected_old_state: Variant) -> void:
    # Ensure we're leaving the expected state.
    if expected_old_state is int:
        S.utils.ensure(state == expected_old_state)
    elif expected_old_state is Array:
        S.utils.ensure(expected_old_state.has(state))
    else:
        S.utils.ensure(false)

    var previous_state := state

    match state:
        State.LEVEL_LOADING:
            state = State.MAIN_MENU_PLAYING
        State.MAIN_MENU_PLAYING:
            state = State.MAIN_MENU_FINISHED
        State.MAIN_MENU_FINISHED:
            state = State.PLAYING
        State.PLAYING:
            state = State.GAME_OVER_PLAYING
        State.GAME_OVER_PLAYING:
            state = State.GAME_OVER_FINISHED
        State.GAME_OVER_FINISHED:
            state = State.RESETTING_LEVEL
        State.RESETTING_LEVEL:
            state = State.MAIN_MENU_PLAYING

    S.log.print("Transitioned level state: %s => %s" % [
        State.find_key(previous_state),
        State.find_key(state),
    ])


func _start_main_menu_animation() -> void:
    _transition_out_of_state([State.LEVEL_LOADING, State.RESETTING_LEVEL])
    player.play_main_menu_animation()


func _on_main_menu_animation_finished() -> void:
    _transition_out_of_state(State.MAIN_MENU_PLAYING)
    # Now we wait for the player to hit Enter.


func _start_game() -> void:
    _transition_out_of_state(State.MAIN_MENU_FINISHED)

    start_time_sec = Time.get_ticks_msec() / 1000
    current_time_sec = Time.get_ticks_msec() / 1000
    last_space_trigger_time_sec = 0.0
    last_backspace_trigger_time_sec = 0.0
    last_enter_trigger_time_sec = 0.0
    last_color_update_time_sec = 0.0

    _set_zoom(false)
    player.on_game_started()

    # TODO:
    # - Start level scroll
    # - Start spawning enemies and other level fragments (or is that just from collision detection with scroll movement?)
    # - Start spawning bubbles
    # - Fade-in HUD.
    pass


func game_game_over() -> void:
    _transition_out_of_state(State.PLAYING)
    player.play_death_animation()
    # TODO:
    # - Stop scrolling.
    # - Show game-over text (from clippy)
    pass

    # TODO(Alden): SFX
    pass


func _on_game_over_animation_finished() -> void:
    _transition_out_of_state(State.GAME_OVER_PLAYING)
    # Now we wait for the player to hit Enter.


func _game_reset() -> void:
    _transition_out_of_state(State.GAME_OVER_FINISHED)
    _set_zoom(true)
    player.play_reset_animation()
    G.hud.reset()
    # TODO:
    # - Fade-out enemies, level fragments, and background bubbles.
    # - Fade level and player colors back to starting values.
    # - Fade-out HUD.
    pass


func _on_reset_finished() -> void:
    # TODO:
    # - Remove enemies, level-fragments, and background bubbles.
    # - Spawn starting level fragment, and reset player and camera position.
    _start_main_menu_animation()


func _set_zoom(zoomed_in: bool) -> void:
    var zoom := (
        G.manifest.main_menu_camera_zoom
        if zoomed_in
        else G.manifest.gameplay_camera_zoom
    ) * Vector2.ONE
    var offset_y := (
        G.manifest.main_menu_camera_offset_y
        if zoomed_in
        else G.manifest.gameplay_camera_offset_y
    )
    var duration := (
        G.manifest.reset_zoom_in_duration_sec
        if zoomed_in
        else G.manifest.main_menu_zoom_out_duration_sec
    )

    var tween := get_tree().create_tween()
    tween.tween_property(%Camera2D, "zoom", zoom, duration)
    tween.tween_property(%Camera2D, "offset:y", offset_y, duration)


func add_pending_character(character: Character) -> void:
    character.reparent(%PendingText, true)
