class_name GameScreen
extends ScaffolderGameScreen


func _enter_tree() -> void:
    S.game_screen = self


func _ready() -> void:
    super()

    await get_tree().process_frame

    get_tree().get_root().size_changed.connect(on_resized)
    on_resized()


func start(level_scene: PackedScene) -> void:
    var level_node: ScaffolderLevel = level_scene.instantiate()
    #self.add_child(level_node)
    %SubViewport.add_child(level_node)
    level_node.start()


func on_level_ended() -> void:
    S.screens.open("game_over")
    S.screens.close(self)


func on_resized() -> void:
    var target_size := Vector2.ONE * 768
    var viewport_size: Vector2 = get_viewport().size
    var subviewport_size: Vector2 = min(viewport_size.x, viewport_size.y) * Vector2.ONE

    self.size = viewport_size
    %SubViewport.size = subviewport_size
    %SubViewport.size_2d_override = target_size
