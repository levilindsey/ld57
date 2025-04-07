class_name Spawner
extends RefCounted


func update(elapsed_time_sec: float) -> void:
    # FIXME: Add time-based spawning.

    _update_fragments()


func on_game_started() -> void:
    _spawn_fragment()


func _update_fragments() -> void:
    var current_fragment: LevelFragment = G.level.fragments.front()
    var last_fragment: LevelFragment = G.level.fragments.back()

    var camera_bounds := G.level.get_camera_bounds()

    var is_current_fragment_offscreen := \
            camera_bounds.position.y > current_fragment.bounds.end.y
    var is_last_fragment_onscreen := \
            camera_bounds.end.y >= last_fragment.bounds.position.y

    # Remove old fragments.
    if is_current_fragment_offscreen:
        G.level.fragments.pop_front()

    # Spawn new fragments.
    if is_last_fragment_onscreen:
        _spawn_fragment()


func _spawn_fragment() -> LevelFragment:
    var fragment_scene: PackedScene
    if G.level.fragments.is_empty():
        fragment_scene = G.manifest.initial_fragment
    else:
        # FIXME: Bias according to progress toward max-difficulty.
        var index := randi_range(0, G.manifest.fragments.size() - 1)
        fragment_scene = G.manifest.fragments[index]

    var fragment := fragment_scene.instantiate()
    G.level.fragments_container.add_child(fragment)

    if G.level.fragments.is_empty():
        fragment.global_position = Vector2(
                0.0, G.player.global_position.y)
    else:
        var last_fragment: LevelFragment = G.level.fragments.back()
        fragment.global_position = Vector2(0, last_fragment.bounds.end.y)

    G.level.fragments.push_back(fragment)

    if randf() < 0.5:
        fragment.scale.x = -1
        fragment.position.x = G.manifest.game_area_size.x

    fragment.cache_bounds()

    return fragment
