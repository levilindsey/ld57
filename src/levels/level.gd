class_name Level
extends ScaffolderLevel


var start_time_sec := 0.0
var last_update_time_sec := 0.0
var current_time_sec := 0.0

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

var player: Player


func _ready() -> void:
    super._ready()

    G.level = self
    G.manifest = S.manifest

    player = G.manifest.player_scene.instantiate()
    add_child(player)

    player.main_menu_finished.connect(_on_main_menu_animation_finished)
    player.death_finished.connect(_on_game_over_animation_finished)
    player.reset_finished.connect(_on_reset_finished)

    S.log.print("Level ready")

    # TODO(Alden): Start playing music!

    _start_main_menu_animation()


func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        var key_event: InputEventKey = event
        var key_code := key_event.keycode

        match state:
            State.PLAYING:
                player.on_character_entered(OS.get_keycode_string(event.get_keycode_with_modifiers()))
            State.MAIN_MENU_FINISHED:
                if key_code == KEY_ENTER:
                    _start_game()
            State.GAME_OVER_FINISHED:
                if key_code == KEY_ENTER:
                    _game_reset()


func _process(delta: float) -> void:
    current_time_sec = Time.get_ticks_msec() / 1000
    var current_elapsed_sec := current_time_sec - last_update_time_sec

    if current_elapsed_sec > G.manifest.color_update_period_sec:
        _update_colors()


func _update_colors() -> void:
    var progress := clampf((current_time_sec - start_time_sec) / G.manifest.color_transition_duration_sec, 0, 1)
    # TODO
    pass


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
    player.on_game_started()
    # TODO:
    # - Start level scroll
    # - Start spawning enemies and other level fragments (or is that just from collision detection with scroll movement?)
    # - Start spawning bubbles
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
    player.play_reset_animation()
    # TODO:
    # - Fade-out enemies, level fragments, and background bubbles.
    # - Fade level and player colors back to starting values.
    pass


func _on_reset_finished() -> void:
    # TODO:
    # - Remove enemies, level-fragments, and background bubbles.
    # - Spawn starting level fragment, and reset player and camera position.
    _start_main_menu_animation()
