@icon("res://addons/scaffolder2/assets/editor_icons/ScaffolderNode.svg")
class_name GameHud
extends ScaffolderHud


func _ready() -> void:
    S.hud = self

    self.visible = S.manifest.get("show_hud")


func _on_pause_pressed() -> void:
    pass
