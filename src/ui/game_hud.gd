@icon("res://addons/scaffolder2/assets/editor_icons/ScaffolderNode.svg")
class_name GameHud
extends ScaffolderHud


var ability_name_to_row: Dictionary[String, HudRow]

var current_clippy_staggered_character_job: StaggeredCharacterJob


func _ready() -> void:
    G.hud = self

    self.visible = S.manifest.get("show_hud")

    %ClippyTextClearTimer.connect("timeout", _on_clippy_text_clear_timeout)


func _on_pause_pressed() -> void:
    pass


func reset() -> void:
    for child in %AbilitiesList.get_children():
        child.queue_free()
    update_depth(0)


func set_clippy_visible(visible: bool) -> void:
    G.hud.set_clippy_text("", 0.0)
    %Clippy.visible = visible
    %ClippyTextWrapper.visible = visible


func set_clippy_text(text: String, duration_sec: float) -> void:
    %ClippyTextClearTimer.stop()

    if text.is_empty():
        %ClippyText.text = ""
        %ClippyTextWrapper.visible = false
        return

    %ClippyTextWrapper.visible = true

    G.stop_stagger_character_job(current_clippy_staggered_character_job)
    current_clippy_staggered_character_job = G.stagger_calls_for_each_character(
            text,
            G.manifest.clippy_character_interval_sec,
            %ClippyText)

    if duration_sec > 0.0:
        %ClippyTextClearTimer.wait_time = duration_sec
        %ClippyTextClearTimer.start()


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


func _on_clippy_text_clear_timeout() -> void:
    set_clippy_text("", 0.0)
