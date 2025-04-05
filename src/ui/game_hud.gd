@icon("res://addons/scaffolder2/assets/editor_icons/ScaffolderNode.svg")
class_name GameHud
extends ScaffolderHud


var ability_name_to_row: Dictionary[String, HudRow]


func _ready() -> void:
    G.hud = self

    self.visible = S.manifest.get("show_hud")


func _on_pause_pressed() -> void:
    pass


func reset() -> void:
    for child in %AbilitiesList.get_children():
        child.queue_free()
    update_depth(0)


# TODO: Call this.
func set_clippy_visible(visible: bool) -> void:
    %Clippy.visible = visible
    %ClippyTextWrapper.visible = visible


# TODO: Call this.
func set_clippy_text(text: String) -> void:
    %ClippyText.text = text


# TODO: Call this.
func update_depth(depth: int) -> void:
    %DepthRow.value = str(depth)


# TODO: Call this.
func update_abilities(abilities: Dictionary[String, int]) -> void:
    for name in abilities:
        if not ability_name_to_row.has(name):
            var row: HudRow = G.manifest.hud_row_scene.instantiate()
            row.label = name
            %AbilitiesList.add_child(row)
            ability_name_to_row[name] = row
        ability_name_to_row[name].value = str(abilities[name])
