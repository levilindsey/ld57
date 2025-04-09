class_name PlayerProjectileAbility
extends WordBasedAbilityController


func start(config: Dictionary, value: String) -> void:
    super.start(config, value)

    word.terrain_collided.connect(_on_terrain_collided)
    word.enemy_collided.connect(_on_enemy_collided)
    word.enemy_projectile_collided.connect(_on_enemy_projectile_collided)
    word.pickup_collided.connect(_on_pickup_collided)


func _on_terrain_collided(area: Area2D) -> void:
    if not word.is_active:
        return
    _explode()


func _on_enemy_collided(enemy: Enemy) -> void:
    if not word.is_active or not enemy.is_active:
        return
    _explode()


func _on_enemy_projectile_collided(projectile: Ability) -> void:
    if not word.is_active or not projectile.is_active:
        return
    _explode()


func _on_pickup_collided(pickup: Pickup) -> void:
    if not word.is_active or not pickup.is_active:
        return
    _explode()


func _explode() -> void:
    pass
