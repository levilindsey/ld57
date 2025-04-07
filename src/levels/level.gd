class_name Level
extends ScaffolderLevel

# TODO: MASTER LIST
#
# - Hook-up placeholder vfx nodes for the following.
# - MAKE A PRIORITY LIST FOR ALDEN:
#   - Background track.
#   - VFXs:
#     - Torpedo explosion
#     - Enter key (like a typewriter carriage return?)
#     - Game over
#     - FIXME: LOOK AT ALL TODOs AND MAKE THIS LIST!
#
#
#
#
# - Make pending-text last longer as long as it's a valid prefix for a current ability.
#
# - Add fragment spawning.
#
# - Add pickups.
# - Make pickups spawn longer words as you go.
# - Add enemy spawning.
# - Add bubble spawning.
#
# - Add camera-boundary exit detection, and cleanup items:
#   - AbandonedText, Fragments, Bubbles, Pickups, Enemies, EnemyProjectiles, PlayerProjectiles.
#
# - HUD
#   - Show abilities in the HUD.
#   - Highlight ability text in the HUD when the pending letters are a matching
#     prefix.
#     - Clear highlights on game over.
#   - Health bar.
#
# - Add clippy.
#
# - Add extra animations:
#   - Word animations for enemies and triggered abilities.
#   - Character-by-character animations for enemies and triggered abilities.
#
#
# - Add clippy.
# - Add more clippy text.
# - Add any missing sfx.
# - Add more enemies.
# - Add more abilities.
# - Add more word values for abilities.
# - Add more level fragments.
# - GAME NAME!!
#   - Add support for auto-typing this on a line above the "HIT ENTER"?
#
#
# Stretch:
# - Fix adjacent character horizontal overlap on Alden's machine.
# - Replace subviewport+camera with re-positioning of the level contents, for
#   sharper text.
# - Add an ability pre-animation step; e.g., rotating and skewing the torpedo before launching.
#   - This would complicate the collision shape though...
#
#
#
# >>> Stuff Alden could do: <<<
#
# - Game name!!
# - Music
# - Add Clippy GIF.
# - Add Clippy text.
#   - Say something for each new word you pickup?
#   - Say random nautical nonsense occasionally?
#   - Say something different for each type of enemy (and terrain) that can do
#     damage to you.
#   - Say some descriptive starting text.
#     - We could have him say a sequence of different messages, with a small
#       delay between them, if we want.
# - Make some level fragments.
# -


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

var previous_pressed_key_code := 0

var progress_to_max_difficulty = 0.0

var start_time_sec := 0.0
var last_color_update_time_sec := 0.0
var current_time_sec := 0.0

var last_enter_trigger_time_sec := 0.0
var last_space_trigger_time_sec := 0.0
var last_backspace_trigger_time_sec := 0.0

var scroll_speed := 0.0

var player: Player

var ability_controllers: Array[AbilityController] = []

# {value: {count: int, name: String, is_prefix_match: bool}}
var abilities: Dictionary[String, Dictionary] = {}

var pitch_effect = AudioServer.get_bus_effect(3, 0) as AudioEffectPitchShift
var keyboard_bus = AudioServer.get_bus_index("Keyboard")

@onready var bubbles: Node2D = %Bubbles
@onready var fragments: Node2D = %Fragments
@onready var abandoned_text: Node2D = %AbandonedText
@onready var pending_text: PendingText = %PendingText
@onready var pickups: Node2D = %Pickups
@onready var players: Node2D = %Players
@onready var enemies: Node2D = %Enemies
@onready var enemy_projectiles: Node2D = %EnemyProjectiles
@onready var player_projectiles: Node2D = %PlayerProjectiles


func _ready() -> void:
    super._ready()

    G.level = self
    G.manifest = S.manifest
    GHack.level = self
    GHack.manifest = S.manifest

    G.manifest.sanitize()

    player = G.manifest.player_scene.instantiate()
    add_child(player)

    # Have the background color extend beyond the viewport a smidge.
    %BackgroundColor.size = G.manifest.game_area_size * 2 + Vector2i.ONE * 2
    %BackgroundColor.position = - (G.manifest.game_area_size / 2 + Vector2i.ONE)
    %BackgroundColor.color = G.manifest.get_start_color(GameManifest.ColorType.BACKGROUND)

    # Start zoomed in.
    %Camera2D.zoom = G.manifest.main_menu_camera_zoom * Vector2.ONE
    %Camera2D.offset.y = G.manifest.main_menu_camera_offset_y
    %Camera2D.position = Vector2(G.manifest.game_area_size.x * 0.5, 0)

    G.hud.modulate.a = 0.0

    _update_colors()

    player.main_menu_finished.connect(_on_main_menu_animation_finished)
    player.death_finished.connect(_on_game_over_animation_finished)
    player.reset_finished.connect(_on_reset_finished)

    S.log.print("Level ready")

    await get_tree().create_timer(0.1).timeout

    _start_main_menu_animation()


func _input(event: InputEvent) -> void:
    if event is InputEventKey:
        var key_event: InputEventKey = event
        var key_code := key_event.keycode
        var is_held_key_duplicate_press := false

        match key_code:
            KEY_SPACE:
                is_held_key_duplicate_press = is_space_pressed and event.pressed
                is_space_pressed = event.pressed
                if not is_space_pressed:
                    last_space_trigger_time_sec = 0.0
            KEY_BACKSPACE, KEY_DELETE:
                is_held_key_duplicate_press = is_backspace_pressed and event.pressed
                is_backspace_pressed = event.pressed
                if not is_backspace_pressed:
                    last_backspace_trigger_time_sec = 0.0
            KEY_ENTER:
                is_held_key_duplicate_press = is_enter_pressed and event.pressed
                is_enter_pressed = event.pressed
                if not is_enter_pressed:
                    last_enter_trigger_time_sec = 0.0

        if not event.pressed:
            previous_pressed_key_code = 0


        if previous_pressed_key_code == 0 and not is_held_key_duplicate_press:
            #pitch_effect.pitch_scale = 1.0
            AudioServer.set_bus_volume_db(keyboard_bus, 0.0)
            #print("pitch reset: ", pitch_effect.pitch_scale, " db:", AudioServer.get_bus_volume_db(keyboard_bus))
        else:
            var current_db = AudioServer.get_bus_volume_db(keyboard_bus)
            var new_db = clamp(current_db + .5, -80.0, 10.0)
            #pitch_effect.pitch_scale += 0.001
            AudioServer.set_bus_volume_db(keyboard_bus, new_db)
            #print("pitch up: ", pitch_effect.pitch_scale, " db:", new_db)


        if event.pressed:
            match state:
                State.PLAYING:
                    match key_code:
                        KEY_SPACE:
                            # We call this separately with our own custom throttle period, so we
                            # don't have to tolerate the initial delay before repeated key entries
                            # are fired.
                            if not G.manifest.using_custom_fast_space or last_space_trigger_time_sec == 0.0:
                                _trigger_space(is_held_key_duplicate_press)
                            #player.on_space(false)
                        KEY_BACKSPACE, KEY_DELETE:
                            # We call this separately with our own custom throttle period, so we
                            # don't have to tolerate the initial delay before repeated key entries
                            # are fired.
                            if not G.manifest.using_custom_fast_space or last_backspace_trigger_time_sec == 0.0:
                                _trigger_backspace(is_held_key_duplicate_press)
                            #player.on_backspace(false)
                        KEY_ENTER:
                            # We call this separately with our own custom throttle period, so we
                            # don't have to tolerate the initial delay before repeated key entries
                            # are fired.
                            if not G.manifest.using_custom_fast_space or last_enter_trigger_time_sec == 0.0:
                                _trigger_enter(is_held_key_duplicate_press)
                            #player.on_enter(false)
                        KEY_TAB:
                            player.on_tab(false)
                        _:
                            if event.unicode > 0:
                                is_held_key_duplicate_press = previous_pressed_key_code == event.keycode
                                previous_pressed_key_code = event.keycode
                                player.on_character_entered(String.chr(event.unicode), is_held_key_duplicate_press)
                            # This key_code range corresponds to visual characters.
                            #if key_code >= KEY_EXCLAM and key_code <= KEY_SECTION:
                                #player.on_character_entered(OS.get_keycode_string(event.get_keycode_with_modifiers()))
                                #player.on_character_entered(OS.get_keycode_string(event.key_label))
                                #player.on_character_entered(String.chr(event.unicode))
                State.MAIN_MENU_FINISHED:
                    if key_code == KEY_ENTER:
                        _start_game()
                        _trigger_enter(false)
                State.GAME_OVER_FINISHED:
                    if key_code == KEY_ENTER:
                        _game_reset()


func _process(delta: float) -> void:
    current_time_sec = Anim.get_current_time_sec()

    progress_to_max_difficulty = clampf(
        (current_time_sec - start_time_sec) / G.manifest.time_to_max_difficulty_sec,
        0,
        1
    )

    if state == State.PLAYING:
        if G.manifest.using_custom_fast_space:
            if is_space_pressed and current_time_sec >= last_space_trigger_time_sec + G.manifest.space_key_throttle_period_sec:
                _trigger_space(true)
            if is_backspace_pressed and current_time_sec >= last_backspace_trigger_time_sec + G.manifest.space_key_throttle_period_sec:
                _trigger_backspace(true)
            if is_enter_pressed and current_time_sec >= last_enter_trigger_time_sec + G.manifest.space_key_throttle_period_sec:
                _trigger_enter(true)

        if current_time_sec >= last_color_update_time_sec + G.manifest.color_update_period_sec:
            _update_colors()

        # Scroll.
        scroll_speed = lerpf(G.manifest.start_scroll_speed, G.manifest.end_scroll_speed, progress_to_max_difficulty)
        var vertical_movement := scroll_speed * delta
        _add_scroll(vertical_movement)

    # Remove references to AbilityControllers after they're done.
    for index in range(ability_controllers.size()):
        var reverse_index := ability_controllers.size() - 1 - index
        var controller := ability_controllers[reverse_index]
        if controller.is_complete():
            ability_controllers.remove_at(reverse_index)


func _trigger_space(is_held_key_duplicate_press := false) -> void:
    last_space_trigger_time_sec = current_time_sec
    player.on_space(is_held_key_duplicate_press)


func _trigger_backspace(is_held_key_duplicate_press := false) -> void:
    last_backspace_trigger_time_sec = current_time_sec
    player.on_backspace(is_held_key_duplicate_press)


func _trigger_enter(is_held_key_duplicate_press := false) -> void:
    last_enter_trigger_time_sec = current_time_sec
    player.on_enter(is_held_key_duplicate_press)


func new_line() -> void:
    _add_scroll(player.default_line_height)


func _add_scroll(increment: float) -> void:
    player.position.y += increment
    pending_text.position.y += increment
    %Camera2D.position.y += increment

    var depth := floori(player.position.y / player.default_line_height)
    G.hud.update_depth(depth)


func _update_colors() -> void:
    var background_color := get_color(GameManifest.ColorType.BACKGROUND)
    var text_color := get_color(GameManifest.ColorType.TEXT)
    var cursor_outline_color := get_color(GameManifest.ColorType.CURSOR_OUTLINE)
    var typed_text_outline_color := get_color(GameManifest.ColorType.TYPED_TEXT_OUTLINE)
    var ability_outline_color := get_color(GameManifest.ColorType.ABILITY_OUTLINE)
    var enemy_outline_color := get_color(GameManifest.ColorType.ENEMY_OUTLINE)
    var terrain_outline_color := get_color(GameManifest.ColorType.TERRAIN_OUTLINE)
    var pickup_outline_color := get_color(GameManifest.ColorType.PICKUP_OUTLINE)
    var bubble_color := get_color(GameManifest.ColorType.BUBBLE)

    %BackgroundColor.color = background_color
    var hud_panel_style_alpha := G.manifest.hud_panel_style.bg_color.a
    G.manifest.hud_panel_style.bg_color = background_color
    G.manifest.hud_panel_style.bg_color.a = hud_panel_style_alpha

    player.set_text_color(text_color)

    G.manifest.cursor_label_settings.font_color = text_color
    G.manifest.typed_text_label_settings.font_color = text_color
    G.manifest.ability_label_settings.font_color = text_color
    G.manifest.enemy_label_settings.font_color = text_color
    G.manifest.pickup_label_settings.font_color = text_color
    G.manifest.terrain_label_settings.font_color = text_color
    G.manifest.hud_label_settings.font_color = text_color

    G.manifest.cursor_label_settings.outline_color = cursor_outline_color
    G.manifest.typed_text_label_settings.outline_color = typed_text_outline_color
    G.manifest.ability_label_settings.outline_color = ability_outline_color
    G.manifest.enemy_label_settings.outline_color = enemy_outline_color
    G.manifest.terrain_label_settings.outline_color = terrain_outline_color
    G.manifest.pickup_label_settings.outline_color = pickup_outline_color

    G.manifest.bubble_label_settings.font_color = bubble_color


func get_color(type: GameManifest.ColorType) -> Color:
    if type == GameManifest.ColorType.TEXT:
        var using_light_text_color: bool = (
            progress_to_max_difficulty >=
                G.manifest.progress_to_switch_to_light_text_color
        )
        if using_light_text_color:
            return G.manifest.get_end_color(type)
        else:
            return G.manifest.get_start_color(type)

    var start_color := G.manifest.get_start_color(type)
    var end_color := G.manifest.get_end_color(type)
    return lerp(start_color, end_color, progress_to_max_difficulty)


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
    await get_tree().create_timer(0.1).timeout
    _transition_out_of_state([State.LEVEL_LOADING, State.RESETTING_LEVEL])
    player.play_main_menu_animation()


func _on_main_menu_animation_finished() -> void:
    _transition_out_of_state(State.MAIN_MENU_PLAYING)
    # Now we wait for the player to hit Enter.


func _start_game() -> void:
    _transition_out_of_state(State.MAIN_MENU_FINISHED)

    _set_zoom(false)
    player.on_game_started()

    # Fade-in items.
    var tween := get_tree().create_tween()
    tween.tween_method(
        _interpolate_fade_opacity, 0.0, 1.0, G.manifest.hud_fade_out_duration_sec
    ).set_delay(G.manifest.main_menu_zoom_out_duration_sec)

    # TODO: SPAWNING
    # - Start spawning enemies and other level fragments (or is that just from collision detection with scroll movement?)
    # - Start spawning bubbles

    for entry in G.manifest.debug_initial_abilities:
        add_ability(entry.name, entry.value)

    await get_tree().create_timer(
        G.manifest.main_menu_zoom_out_duration_sec + 0.4).timeout

    G.hud.set_clippy_visible(true)

    await get_tree().create_timer(
        G.manifest.show_clippy_duration_sec + 0.2).timeout

    G.hud.set_clippy_text(
        G.manifest.clippy_intro_text,
        G.manifest.clippy_intro_text_duration_sec)


func game_game_over() -> void:
    _transition_out_of_state(State.PLAYING)
    player.play_death_animation()

    cancel_pending_characters()

    G.hud.set_clippy_text(
        G.manifest.clippy_game_over_text,
        G.manifest.clippy_game_over_text_duration_sec)


func _on_game_over_animation_finished() -> void:
    _transition_out_of_state(State.GAME_OVER_PLAYING)
    # Now we wait for the player to hit Enter.


func _game_reset() -> void:
    _transition_out_of_state(State.GAME_OVER_FINISHED)

    progress_to_max_difficulty = 0.0
    start_time_sec = Anim.get_current_time_sec()
    current_time_sec = Anim.get_current_time_sec()
    last_space_trigger_time_sec = 0.0
    last_backspace_trigger_time_sec = 0.0
    last_enter_trigger_time_sec = 0.0
    last_color_update_time_sec = 0.0
    scroll_speed = 0.0
    abilities.clear()
    ability_controllers.clear()

    _update_colors()
    _set_zoom(true)
    player.play_reset_animation()

    G.hud.set_clippy_visible(false)

    # Fade-out items.
    var tween := get_tree().create_tween()
    tween.tween_method(
        _interpolate_fade_opacity, 1.0, 0.0, G.manifest.hud_fade_out_duration_sec
    )

    # Transition colors.
    tween.tween_method(
        _interpolate_colors, progress_to_max_difficulty, 0.0, G.manifest.hud_fade_out_duration_sec)

    # Reposition the player.
    var player_translate_duration := G.manifest.reset_zoom_in_duration_sec / 6.0
    tween.tween_property(
        player, "position:x", player.get_start_position().x, player_translate_duration)
    pending_text.position.x = player.get_start_position().x


func _on_reset_finished() -> void:
    G.hud.reset()

    # Remove items.
    for collection in _get_collections():
        for child in collection.get_children():
            child.queue_free()

    # TODO: Spawn starting level fragment.
    pass

    await get_tree().create_timer(0.1).timeout

    _start_main_menu_animation()


func _interpolate_colors(progress: float) -> void:
    progress_to_max_difficulty = progress
    _update_colors()


func _interpolate_fade_opacity(opacity: float) -> void:
    G.hud.modulate.a = opacity
    for collection in _get_collections():
        collection.modulate.a = opacity


func _get_collections() -> Array[Node2D]:
    return [
        bubbles,
        fragments,
        abandoned_text,
        pickups,
        enemies,
        enemy_projectiles,
        player_projectiles,
    ]


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
    if G.manifest.speed_up_level_state_transitions:
        duration *= 0.1

    var tween := get_tree().create_tween()
    tween.tween_property(%Camera2D, "zoom", zoom, duration)
    tween.tween_property(%Camera2D, "offset:y", offset_y, duration)


func cancel_pending_characters() -> void:
    const HACK_SCROLL_SPEED_MULTIPLIER := 1 / 60.0

    for character in pending_text.get_characters():
        character.reparent(abandoned_text, true)

        # Wobble the character upward.
        var config := {
            node = character,
            destroys_node_when_done = true,
            is_one_shot = true,
            ease_name = "ease_in_out",

            start_speed = character.get_current_speed() - scroll_speed * HACK_SCROLL_SPEED_MULTIPLIER,

            # Upward and very slightly leftward.
            #direction_angle = - (PI / 2.0 + PI / 16.0),
            direction_angle = - PI / 2.0,
            direction_deviaton_angle_max = PI / 32.0,

            # These can all be either a single number, or an array of two numbers.
            duration_sec = [1.0, 3.0], # If omitted, the animation won't stop.
            end_opacity = 0.0,
            #interval_sec = [0.3, 2.0], # If ommitted, duration_sec must be included.
            speed = [0, 0.5],
            acceleration = [30, 0.0],
            rotation_speed = [0.01, 0.5],
            perpendicular_oscillation_amplitude = [0, 100.0],
            #scale_x = [0.5, 4.0],
            #scale_y = [0.5, 4.0],
            skew = [-PI, PI],
        }

        Anim.start_animation(config)

    pending_text.clear()


func _find_ability_config(ability_name: String) -> Dictionary:
    for ability in G.manifest.abilities:
        if ability.name == ability_name:
            return ability
    return {}


func add_ability(ability_name: String, ability_value: String) -> void:
    S.log.print("Adding ability: name=%s, value=%s" %
            [ability_name, ability_value])

    # {value: {count: int, name: String, is_prefix_match: bool}}
    if not abilities.has(ability_value):
        abilities[ability_value] = {
            count = 1,
            name = ability_name,
            is_prefix_match = false,
        }
    else:
        abilities[ability_value].count += 1


func trigger_ability(ability_name: String, ability_value: String) -> void:
    var config := _find_ability_config(ability_name)
    if not S.utils.ensure(not config.is_empty()):
        return

    if not S.utils.ensure(abilities.has(ability_value)):
        return

    S.log.print("Triggering ability: name=%s, value=%s" %
            [ability_name, ability_value])

    # {value: {count: int, name: String, is_prefix_match: bool}}
    var entry := abilities[ability_value]
    entry.count -= 1
    if entry.count <= 0:
        abilities.erase(ability_value)

    var controller: AbilityController = config.controller.new()
    controller.start(config, ability_value)
    ability_controllers.push_back(controller)

    player.on_ability_triggered()


func check_ability_text_match() -> void:
    var matching_ability_name := ""
    var matching_ability_value := ""

    # {value: {count: int, name: String, is_prefix_match: false}}
    for ability_value in abilities:
        var ability_entry := abilities[ability_value]

        # Check for a full match.
        if pending_text.text.ends_with(ability_value):
            matching_ability_value = ability_value
            matching_ability_name = ability_entry.name
            break

        # Check for a prefix match.
        ability_entry.is_prefix_match = false
        for i in range(ability_value.length()):
            if pending_text.text.ends_with(ability_value.substr(0, i + 1)):
                ability_entry.is_prefix_match = true
                break

    if not matching_ability_name.is_empty():
        trigger_ability(matching_ability_name, matching_ability_value)
