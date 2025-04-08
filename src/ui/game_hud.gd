@icon("res://addons/scaffolder2/assets/editor_icons/ScaffolderNode.svg")
class_name GameHud
extends ScaffolderHud


var ability_name_to_row: Dictionary[String, HudRow] = {}

var current_clippy_staggered_character_job: StaggeredCharacterJob


func _ready() -> void:
    G.hud = self
    GHack.hud = self

    self.visible = S.manifest.get("show_hud")

    %ClippyTextClearTimer.connect("timeout", _on_clippy_text_clear_timeout)

    %AbilitiesListWrapper.visible = false


func _on_pause_pressed() -> void:
    pass


func reset() -> void:
    for child in %AbilitiesList.get_children():
        child.queue_free()

    update_depth(0)

    %AbilitiesListWrapper.visible = false

    for ability_value in ability_name_to_row:
        if is_instance_valid(ability_name_to_row[ability_value]):
            ability_name_to_row[ability_value].queue_free()
    ability_name_to_row.clear()


func set_clippy_visible(visible: bool) -> void:
    G.hud.set_clippy_text("", 0.0)
    %Clippy.visible = visible
    %ClippyTextWrapper.visible = visible


func set_clippy_text(text_or_text_options: Variant, duration_sec: float) -> void:
    %ClippyTextClearTimer.stop()

    var text: String
    if text_or_text_options is Array:
        var index: int = randi_range(0, text_or_text_options.size() - 1)
        text = text_or_text_options[index]
    else:
        text = text_or_text_options

    if text.is_empty():
        %ClippyText.text = ""
        %ClippyTextWrapper.visible = false
        return

    %ClippyTextWrapper.visible = true

    Anim.stop_stagger_character_job(current_clippy_staggered_character_job)
    current_clippy_staggered_character_job = Anim.stagger_calls_for_each_character(
            text,
            G.manifest.clippy_character_interval_sec,
            %ClippyText)

    if duration_sec > 0.0:
        %ClippyTextClearTimer.wait_time = duration_sec
        %ClippyTextClearTimer.start()


func update_depth(depth: int) -> void:
    %DepthRow.value = " %d" % depth


func update_health(health: int) -> void:
    %HealthRow.value = " x%d" % health


func update_abilities() -> void:
    # {value: {count: int, name: String, is_prefix_match: false}}

    # Add new values.
    for ability_value in G.level.abilities:
        # Add a new row if it doesn't exist yet.
        if not ability_name_to_row.has(ability_value):
            var row: HudRow = G.manifest.hud_row_scene.instantiate()
            row.is_label_on_left = false
            row.label = ability_value
            %AbilitiesList.add_child(row)
            ability_name_to_row[ability_value] = row

        var ability_state: Dictionary = G.level.abilities[ability_value]
        var row: HudRow = ability_name_to_row[ability_value]

        # Set an optional count string.
        row.value = (
            ("(x%d) " % ability_state.count) if
            ability_state.count > 1 else
            ""
        )

        # Set highlight.
        row.is_highlighted = ability_state.is_prefix_match

    # Remove old values.
    var values := ability_name_to_row.keys()
    for ability_value in values:
        if not G.level.abilities.has(ability_value):
            if is_instance_valid(ability_name_to_row[ability_value]):
                ability_name_to_row[ability_value].queue_free()
            ability_name_to_row.erase(ability_value)

    %AbilitiesListWrapper.visible = not ability_name_to_row.is_empty()


func _on_clippy_text_clear_timeout() -> void:
    set_clippy_text("", 0.0)
