@icon("res://addons/scaffolder2/assets/editor_icons/ScaffolderNode.svg")
class_name Main
extends Container


@export var manifest: ScaffolderManifest


func _ready() -> void:
    randomize()

    G.main = self
    GHack.main = self

    S.set_up(manifest)
