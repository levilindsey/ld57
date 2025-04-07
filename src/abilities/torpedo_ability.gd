class_name TorpedoAbility
extends WordBasedbilityController


func start(config: Dictionary, value: String) -> void:
    super.start(config, value)

    _create_ability_word_from_pending_characters(value)

    word.terrain_collided.connect(_on_terrain_collided)
    word.enemy_collided.connect(_on_enemy_collided)
    word.enemy_projectile_collided.connect(_on_enemy_projectile_collided)

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

    G.player.play_torpedo_launch_sound()


func _on_terrain_collided(area: Area2D) -> void:
    if not word.is_active:
        return
    _explode()


func _on_enemy_collided(enemy: Enemy) -> void:
    if not word.is_active or not enemy.is_active:
        return
    enemy.on_hit_with_torpedo(self)
    _explode()


func _on_enemy_projectile_collided(projectile: Ability) -> void:
    if not word.is_active or not projectile.is_active:
        return
    projectile.on_hit_with_torpedo(self)
    _explode()


func _explode() -> void:
    word.explode_from_point(
        word.global_position,
        PI,
        1.0,
        1.0,
        word.get_current_direction_angle())
    G.player.play_torpedo_explode_sound()
