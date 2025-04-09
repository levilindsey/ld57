class_name TorpedoAbility
extends PlayerProjectileAbility


func start(config: Dictionary, value: String) -> void:
    super.start(config, value)

    word.is_moving_to_target = true
    word.motion_target = _get_nearest_enemy()

    G.player.play_torpedo_launch_sound()

    S.log.print("Started TorpedoAbility: %s, %s" % [
        value,
        word.global_position,
    ])


func _get_nearest_enemy() -> Enemy:
    var closest_enemy: Enemy = null
    var closest_enemy_distance_squared := INF
    for enemy in G.level.enemies.get_children():
        var current_distance_squared := \
                word.global_position.distance_squared_to(enemy.global_position)
        if current_distance_squared < closest_enemy_distance_squared:
            closest_enemy = enemy
            closest_enemy_distance_squared = current_distance_squared
    return closest_enemy


func _on_terrain_collided(area: Area2D) -> void:
    super._on_terrain_collided(area)


func _on_enemy_collided(enemy: Enemy) -> void:
    super._on_enemy_collided(enemy)
    if not enemy.is_active:
        return
    enemy.on_hit_with_torpedo(self)


func _on_enemy_projectile_collided(projectile: Ability) -> void:
    super._on_enemy_projectile_collided(projectile)
    if not projectile.is_active:
        return
    projectile.on_hit_with_torpedo(self)


func _on_pickup_collided(pickup: Pickup) -> void:
    super._on_pickup_collided(pickup)
    if not pickup.is_active:
        return
    pickup.on_hit_with_torpedo(self)


func _explode() -> void:
    word.explode_from_point(
        word.global_position,
        PI,
        1.0,
        1.0,
        word.get_current_direction_angle())
    G.player.play_torpedo_explode_sound()
