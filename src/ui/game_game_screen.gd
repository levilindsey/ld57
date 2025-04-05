class_name GameScreen
extends ScaffolderGameScreen


func _enter_tree() -> void:
    S.game_screen = self


func _ready() -> void:
    super()

    sub_viewport = %SubViewport

    await get_tree().process_frame

    # TODO: Configure different levels?
    var level_scene = (
        S.manifest.dev_mode_level
        if S.manifest.dev_mode
        else S.manifest.main_level
    )
    start(level_scene)

    get_tree().get_root().size_changed.connect(on_resized)
    on_resized()


func start(level_scene: PackedScene) -> void:
    var level_node: ScaffolderLevel = level_scene.instantiate()
    %SubViewport.add_child(level_node)
    level_node.start()


func on_level_ended() -> void:
    S.screens.open("game_over")
    S.screens.close(self)


func on_resized() -> void:
    pass
    #var viewport_size: Vector2 = get_viewport().size
    #var subviewport_size: Vector2 = min(viewport_size.x, viewport_size.y) * Vector2.ONE
    #self.size = viewport_size
    #%Control.size = viewport_size
    #%SubViewport.size = subviewport_size
    #%SubViewportContainer.position = (viewport_size - subviewport_size) / 2.0
