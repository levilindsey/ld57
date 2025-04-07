class_name PendingText
extends Word


func add_text(text: String, is_main_menu_text := false) -> void:
    await super.add_text(text, is_main_menu_text)

    if is_main_menu_text:
        return

    if get_characters().is_empty():
        S.log.warning(
            "PendingText.add_text: characters were freed before animation could be started.")
        return

    var character: Character = get_characters().back()

    # Very slowly float the character upward.
    var config := {
        node = character,
        destroys_node_when_done = false,
        is_one_shot = false,
        ease_name = "linear",

        start_speed = character.get_current_speed(),

        # Upward and very slightly leftward.
        direction_angle = -(PI / 2.0 + PI / 32.0),
        direction_deviaton_angle_max = PI / 32.0,

        # These can all be either a single number, or an array of two numbers.
        duration_sec = 0.0, # If omitted, the animation won't stop.
        #end_opacity = 0.0,
        interval_sec = 100.0, # If ommitted, duration_sec must be included.
        speed = [0.1, 0.2],
        acceleration = [2, 0.0],
        rotation_speed = [0.001, 0.05],
        #perpendicular_oscillation_amplitude = [0, 100.0],
        #scale_x = [0.5, 4.0],
        #scale_y = [0.5, 4.0],
        skew = [-PI / 16.0, PI / 16.0],
    }

    character.start_animation(config)
