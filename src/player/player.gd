class_name Player
extends Node2D


signal main_menu_finished
signal death_finished
signal reset_finished


func _ready() -> void:
    # Start zoomed in.
    %Camera2D.zoom = G.manifest.main_menu_camera_zoom * Vector2.ONE


func play_main_menu_animation() -> void:
    # TODO: Play the main-menu typing animation.

    await get_tree().create_timer(
        G.manifest.main_menu_animation_duration_sec).timeout

    main_menu_finished.emit()


func on_game_started() -> void:
    _set_zoom(false)


func play_death_animation() -> void:
    # TODO: Animate cursor rotation sideways and float upward (use an animation tree?).

    await get_tree().create_timer(
        G.manifest.player_death_animation_duration_sec).timeout

    death_finished.emit()


func play_reset_animation() -> void:
    # TODO: Rotate player back to starting orientation (use an animation tree?).

    _set_zoom(true)

    await get_tree().create_timer(
        G.manifest.level_reset_animation_duration_sec).timeout

    reset_finished.emit()


func _set_zoom(zoomed_in: bool) -> void:
    var zoom := (
        G.manifest.main_menu_camera_zoom
        if zoomed_in
        else G.manifest.gameplay_camera_zoom
    )
    var duration := (
        G.manifest.reset_zoom_in_duration_sec
        if zoomed_in
        else G.manifest.main_menu_zoom_out_duration_sec
    )

    var tween := get_tree().create_tween()
    tween.tween_property(%Camera2D, "zoom", zoom, duration)


func on_character_entered(character: String) -> void:
    %ScratchLabel.text = character
    await get_tree().process_frame
    var character_size: Vector2 = %ScratchLabel.size
    # TODO: Add the character to the pending string.
