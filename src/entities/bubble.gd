class_name Bubble
extends Character


func set_up(position: Vector2) -> void:
    var text := (
        "o" if
        randf() < 0.5 else
        "O"
    )

    var size: Vector2 = G.player.default_character_size

    set_text(text)
    set_type(Character.Type.BUBBLE)
    set_label_offset(-size / 2.0)
    global_position = position
    anchor_global_position = position
    anchor_relative_position = position

    # Slowly float the bubble upward.
    var config := {
        node = self,
        destroys_node_when_done = false,
        is_one_shot = false,
        ease_name = "linear",

        start_speed = 2.0,

        # Upward and very slightly leftward.
        #direction_angle = -(PI / 2.0 + PI / 32.0),
        #direction_deviaton_angle_max = PI / 32.0,

        direction_angle = -PI / 2.0,

        # These can all be either a single number, or an array of two numbers.
        #duration_sec = 0.0, # If omitted, the animation won't stop.
        #end_opacity = 0.0,
        interval_sec = [2.5, 2.5], # If ommitted, duration_sec must be included.
        speed = [1.0, 4.0],
        #acceleration = [0.0, 30],
        #rotation_speed = [0, 10],
        perpendicular_oscillation_amplitude = [20.0, 20.0],
        #scale_x = [0.5, 4.0],
        #scale_y = [0.5, 4.0],
        #skew = [-PI / 16.0, PI / 16.0],
    }

    start_animation(config)
