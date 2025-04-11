class_name Ability
extends Word


signal terrain_collided(area: Area2D)
signal enemy_collided(enemy: Enemy)
signal enemy_projectile_collided(projectile: Ability)
signal player_collided(player: Player)
signal player_projectile_collided(projectile: Ability)
signal pickup_collided(pickup: Pickup)


var is_player_ability := true

var is_moving_to_target := false

var motion_target: Enemy

var motion_target_translation_speed := 200.0


func set_up(
        characters: Array[Character],
        spaces_count: int,
        word_position: Vector2,
        is_player_ability := true) -> void:
    global_position = word_position

    self.is_player_ability = is_player_ability

    %Area2D.collision_layer = (
        GameManifest.PLAYER_PROJECTILE_COLLISION_LAYER if
        is_player_ability else
        GameManifest.ENEMY_PROJECTILE_COLLISION_LAYER
    )

    var type := (
        Character.Type.ABILITY if
        is_player_ability else
        Character.Type.ENEMY
    )

    await set_up_from_characters(characters, spaces_count, type)

    %CollisionShape2D.shape = %CollisionShape2D.shape.duplicate()
    %CollisionShape2D.shape.size = size


func _process(delta_sec: float) -> void:
    if not is_moving_to_target:
        return

    var translation_distance := \
            motion_target_translation_speed * G.level.speed_multiplier * delta_sec
    var direction := ((
            motion_target.global_position - global_position
        ).normalized() if
        is_instance_valid(motion_target) else
        Vector2.DOWN
    )
    var translation_displacement := direction * translation_distance
    global_position += translation_displacement


func _on_area_2d_area_entered(area: Area2D) -> void:
    if area.collision_layer & GameManifest.TERRAIN_COLLISION_LAYER:
        terrain_collided.emit(area)
    elif area.collision_layer & GameManifest.ENEMY_COLLISION_LAYER:
        enemy_collided.emit(area.get_parent())
    elif area.collision_layer & GameManifest.ENEMY_PROJECTILE_COLLISION_LAYER:
        enemy_projectile_collided.emit(area.get_parent())
    elif area.collision_layer & GameManifest.PLAYER_COLLISION_LAYER:
        player_collided.emit(area.get_parent())
        if not is_player_ability and is_active and G.player.is_active:
            G.player.on_collided_with_enemy_projectile(self)
    elif area.collision_layer & GameManifest.PLAYER_PROJECTILE_COLLISION_LAYER:
        player_projectile_collided.emit(area.get_parent())
    elif area.collision_layer & GameManifest.PICKUP_COLLISION_LAYER:
        pickup_collided.emit(area.get_parent())
    else:
        S.utils.ensure(false)


func on_hit_with_torpedo(torpedo) -> void:
    if not is_player_ability:
        explode_from_point(
            torpedo.global_position,
            PI,
            1.0,
            get_current_speed(),
            get_current_direction_angle())


func on_hit_with_drop(torpedo) -> void:
    if not is_player_ability:
        explode_from_point(
            torpedo.global_position,
            PI,
            1.0,
            get_current_speed(),
            get_current_direction_angle())
