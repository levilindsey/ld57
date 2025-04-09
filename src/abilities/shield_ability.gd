class_name ShieldAbility
extends SideEffectAbilityController


var _is_complete := false


func start(config: Dictionary, value: String) -> void:
    super.start(config, value)

    G.player.activate_shield(self)

    S.log.print("Started ShieldAbility: %s, %s" % [
        value,
        word.global_position,
    ])


func is_complete() -> bool:
    return _is_complete
