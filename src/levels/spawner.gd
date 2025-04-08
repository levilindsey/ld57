class_name Spawner
extends RefCounted


var _visible_pickups: Dictionary[Pickup, bool] = {}

var _next_bubble_spawn_time_sec := 0.0
var _next_enemy_spawn_time_sec := 0.0


func update(elapsed_time_sec: float) -> void:
    _update_fragments()
    _update_visible_pickups()
    _remove_old_items()
    _handle_bubble_spawns(elapsed_time_sec)
    _handle_enemy_spawns(elapsed_time_sec)


func _handle_bubble_spawns(elapsed_time_sec: float) -> void:
    while elapsed_time_sec > _next_bubble_spawn_time_sec:
        var bubble_spawn_interval_min_sec := lerpf(
                G.manifest.start_bubble_spawn_interval_min_sec,
                G.manifest.end_bubble_spawn_interval_min_sec,
                G.level.progress_to_max_difficulty)
        var bubble_spawn_interval_max_sec := lerpf(
                G.manifest.start_bubble_spawn_interval_max_sec,
                G.manifest.end_bubble_spawn_interval_max_sec,
                G.level.progress_to_max_difficulty)
        var next_bubble_spawn_interval_sec := randf_range(
                bubble_spawn_interval_min_sec,
                bubble_spawn_interval_max_sec)
        _next_bubble_spawn_time_sec += next_bubble_spawn_interval_sec

        var bubble: Bubble = GHack.manifest.bubble_scene.instantiate()
        G.level.bubbles.add_child(bubble)
        var position := _choose_bubble_spawn_position()
        bubble.set_up(position)


func _handle_enemy_spawns(elapsed_time_sec: float) -> void:
    while elapsed_time_sec > _next_enemy_spawn_time_sec:
        var enemy_spawn_interval_min_sec := lerpf(
                G.manifest.start_enemy_spawn_interval_min_sec,
                G.manifest.end_enemy_spawn_interval_min_sec,
                G.level.progress_to_max_difficulty)
        var enemy_spawn_interval_max_sec := lerpf(
                G.manifest.start_enemy_spawn_interval_max_sec,
                G.manifest.end_enemy_spawn_interval_max_sec,
                G.level.progress_to_max_difficulty)
        var next_enemy_spawn_interval_sec := randf_range(
                enemy_spawn_interval_min_sec,
                enemy_spawn_interval_max_sec)
        _next_enemy_spawn_time_sec += next_enemy_spawn_interval_sec

        var name_and_value := _choose_enemy_ability_config()
        var config := G.level._find_enemy_config(name_and_value.name)
        var controller: EnemyController = config.controller.new()
        var position := _choose_enemy_spawn_position()
        controller.start(config, name_and_value.value, position)
        G.level.enemy_controllers.push_back(controller)


func on_game_started() -> void:
    _spawn_fragment()


func _update_visible_pickups() -> void:
    var camera_bounds := G.level.get_camera_bounds()

    # Check for newly-visible pickups.
    var next_visible_pickups: Dictionary[Pickup, bool] = {}
    for pickup in G.level.pickups.get_children():
        var pickup_bounds: Rect2 = pickup.get_bounds()
        if camera_bounds.intersects(pickup_bounds):
            next_visible_pickups[pickup as Pickup] = true
            if not _visible_pickups.has(pickup):
                G.clippy.on_pick_visible()

    _visible_pickups = next_visible_pickups


func _remove_old_items() -> void:
    var camera_bounds := G.level.get_camera_bounds()
    var camera_top_y := camera_bounds.position.y

    var items_to_remove := []

    for collection in G.level.get_collections():
        for item in collection.get_children():
            var bounds: Rect2 = item.get_bounds()
            if bounds.end.y < camera_top_y:
                items_to_remove.push_back(item)

    for item in items_to_remove:
        item.destroy()


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
    var fragment_scene := _choose_fragment_scene()
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

    # Spawn pickups.
    for child in fragment.get_children():
        if child is PickupPosition:
            var config := _choose_pickup_ability_config()
            var pickup: Pickup = G.manifest.pickup_scene.instantiate()
            G.level.pickups.add_child(pickup)
            pickup.global_position = child.global_position
            pickup.set_up(config.name, config.value)

    return fragment


func _choose_fragment_scene() -> PackedScene:
    if G.level.fragments.is_empty():
        return G.manifest.initial_fragment
    else:
        # TODO: Bias according to progress toward max-difficulty.
        var index := randi_range(0, G.manifest.fragments.size() - 1)
        return G.manifest.fragments[index]


# {name: String, value: String}
func _choose_pickup_ability_config() -> Dictionary:
    # TODO: Bias according to weights.
    #var ability_index := randi_range(0, G.manifest.abilities.size() - 1)

    # HACK: Hardcoded index weighting.
    var shield_index := 0
    var torpedo_index := 1
    var ability_index := (
        shield_index if
        randf() < 0.25 else
        torpedo_index
    )

    # {name: String, controller: Script, values: [String]}
    var ability_config: Dictionary = G.manifest.abilities[ability_index]

    # TODO: Bias according to progress toward max-difficulty.
    var value_index := randi_range(0, ability_config.values.size() - 1)

    return {
        name = ability_config.name,
        value = ability_config.values[value_index],
    }


# {name: String, value: String}
func _choose_enemy_ability_config() -> Dictionary:
    # TODO: Bias according to weights.
    var enemy_index := randi_range(0, G.manifest.enemies.size() - 1)

    # {name: String, controller: Script, values: [String]}
    var enemy_config: Dictionary = G.manifest.enemies[enemy_index]

    # TODO: Bias according to progress toward max-difficulty.
    var value_index := randi_range(0, enemy_config.values.size() - 1)

    return {
        name = enemy_config.name,
        value = enemy_config.values[value_index],
    }


func _choose_bubble_spawn_position() -> Vector2:
    var camera_bounds := G.level.get_camera_bounds()
    var x := randf_range(
            G.manifest.game_area_bubble_spawn_padding.x,
            G.manifest.game_area_size.x -
                G.manifest.game_area_bubble_spawn_padding.x)
    var y := camera_bounds.end.y + 24.0
    return Vector2(x, y)


func _choose_enemy_spawn_position() -> Vector2:
    var camera_bounds := G.level.get_camera_bounds()
    var x := randf_range(
            G.manifest.game_area_enemy_spawn_padding.x,
            G.manifest.game_area_size.x -
                G.manifest.game_area_enemy_spawn_padding.x)
    var y := camera_bounds.end.y + 24.0
    return Vector2(x, y)
