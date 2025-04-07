class_name Ability
extends Word


signal terrain_collided(area: Area2D)
signal enemy_collided(enemy: Enemy)
signal enemy_projectile_collided(projectile: Ability)
signal player_collided(player: Player)
signal player_projectile_collided(projectile: Ability)
signal pickup_collided(pickup: Pickup)


var is_player_ability := true


func set_up(characters: Array[Character], is_player_ability := true) -> void:
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

    await set_up_from_characters(characters, type)

    %CollisionShape2D.shape.size = size


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
