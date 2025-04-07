class_name TorpedoAbility
extends AbilityController


var word: Ability


func start(config: Dictionary, value: String) -> void:
    super.start(config, value)

    word = G.manifest.ability_scene.instantiate()
    G.level.player_projectiles.add_child(word)

    word.terrain_collided.connect(_on_terrain_collided)
    word.enemy_collided.connect(_on_enemy_collided)
    word.enemy_projectile_collided.connect(_on_enemy_projectile_collided)

    var characters: Array[Character] = G.level.pending_text.get_characters()

    var matched_characters := characters.slice(characters.size() - value.length())

    # NOTE: Do nothing with the unmatched characters, since they'll be discarded
    #       by cancel_pending_text().
    #var unmatched_characters := characters.slice(0, characters.size() - value.length())

    word.set_up(matched_characters, true)

    # FIXME: NEXT, AFTER IMPLEMENTING SIMPLE SHOOT, AND ABILITY TRACKING:
    # - Add a pre-animation, for rotating and skewing the torpedo before launching.

    # Shoot downward.
    var animation_config := {
        node = self,
        destroys_node_when_done = false,
        is_one_shot = false,
        ease_name = "linear",

        start_speed = 100.0,

        direction_angle = PI / 2,
        direction_deviaton_angle_max = PI / 64,

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
        #skew = [-PI / 16, PI / 16],
    }

    word.start_animation(animation_config)


func _on_terrain_collided(area: Area2D) -> void:
    if not word.is_active:
        return
    _explode_torpedo()


func _on_enemy_collided(enemy: Enemy) -> void:
    if not word.is_active or not enemy.is_active:
        return
    enemy.on_hit_with_torpedo(self)
    _explode_torpedo()


func _on_enemy_projectile_collided(projectile: Ability) -> void:
    if not word.is_active or not projectile.is_active:
        return
    projectile.on_hit_with_torpedo(self)
    _explode_torpedo()


func _explode_torpedo() -> void:
    word.explode_from_point(
        word.global_position,
        PI,
        100)
