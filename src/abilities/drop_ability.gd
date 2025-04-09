class_name DropAbility
extends PlayerProjectileAbility


func start(config: Dictionary, value: String) -> void:
    super.start(config, value)

    # Shoot downward.
    var animation_config := {
        node = self,
        destroys_node_when_done = false,
        is_one_shot = false,
        ease_name = "linear",

        start_speed = 10.0,

        direction_angle = PI / 2.0,
        direction_deviaton_angle_max = PI / 64.0,

        # These can all be either a single number, or an array of two numbers.
        duration_sec = 0.0, # If omitted, the animation won't stop.
        #end_opacity = 0.0,
        interval_sec = 100.0, # If ommitted, duration_sec must be included.
        speed = 100.0,
        #acceleration = [2, 0.0],
        #rotation_speed = [0.001, 0.05],
        #perpendicular_oscillation_amplitude = [0, 100.0],
        #scale_x = [0.5, 4.0],
        #scale_y = [0.5, 4.0],
        #skew = [-PI / 16.0, PI / 16.0],
    }

    word.start_animation(animation_config)

    G.player.play_drop_sound()


func _on_terrain_collided(area: Area2D) -> void:
    super._on_terrain_collided(area)


func _on_enemy_collided(enemy: Enemy) -> void:
    super._on_enemy_collided(enemy)
    if not enemy.is_active:
        return
    enemy.on_hit_with_drop(self)


func _on_enemy_projectile_collided(projectile: Ability) -> void:
    super._on_enemy_projectile_collided(projectile)
    if not projectile.is_active:
        return
    projectile.on_hit_with_drop(self)


func _on_pickup_collided(pickup: Pickup) -> void:
    super._on_pickup_collided(pickup)
    if not pickup.is_active:
        return
    pickup.on_hit_with_drop(self)


func _explode() -> void:
    word.explode_from_point(
        word.global_position + Vector2.DOWN * 100.0,
        PI / 3,
        0.4,
        0.3,
        PI / 2)
    G.player.play_drop_landed_sound()
