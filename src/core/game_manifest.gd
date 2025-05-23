class_name GameManifest
extends ScaffolderManifest

enum ColorType {
    BACKGROUND,
    TEXT,
    CURSOR_OUTLINE,
    TYPED_TEXT_OUTLINE,
    ENEMY_OUTLINE,
    ABILITY_OUTLINE,
    TERRAIN_OUTLINE,
    PICKUP_OUTLINE,
    BUBBLE,
}

const PLAYER_COLLISION_LAYER := 1 << 0
const ENEMY_COLLISION_LAYER := 1 << 1
const TERRAIN_COLLISION_LAYER := 1 << 2
const PICKUP_COLLISION_LAYER := 1 << 3
const PLAYER_PROJECTILE_COLLISION_LAYER := 1 << 4
const ENEMY_PROJECTILE_COLLISION_LAYER := 1 << 5

@export var speed_up_level_state_transitions := false
@export var using_custom_fast_space := false

@export var starting_health := 3

@export var main_menu_text := "Hit Enter"

@export_group("Clippy text")
@export var clippy_intro1_text := [
    "Hi, I'm Clippy,\nI'm here to help!",
]
@export var clippy_intro1_text_duration_sec := 3.0
@export var clippy_intro2_text := [
    "Type to move\nyour cursor, and to\ntrigger abilities.",
]
@export var clippy_intro2_text_duration_sec := 5.0
@export var clippy_damage_text := [
    "Try to avoid hitting\nrocks, and animals!",
]
@export var clippy_damage_text_duration_sec := 5.0
@export var clippy_game_over_text := [
    "Oh no, you died!\nHit Enter.",
    "That's game over!\nHit Enter.",
    "Better luck next time!\nHit Enter.",
    "Try again?\nHit Enter.",
]
@export var clippy_game_over_text_duration_sec := 0.0
@export var clippy_shield_text := [
    "Type %s\nto become invincible.",
]
@export var clippy_torpedo_text := [
    "Type %s\nto launch homing\nmissile.",
]
@export var clippy_drop_text := [
    "Type %s\nto drop a word.",
]
@export var clippy_pickup_text_duration_sec := 5.0
@export_group("")

@export_group("Colors")
@export var background_color_start := Color("#f5fcfcff")
@export var background_color_end := Color("#00020aff")

@export var text_color_start := Color("#000000ff")
@export var text_color_end := Color("#e6e6e6ff")

@export var cursor_outline_color_start := Color("#03fc9010")
@export var cursor_outline_color_end := Color("#03fc9010")

@export var typed_text_outline_color_start := Color("#03fc9000")
@export var typed_text_outline_color_end := Color("#03fc9000")

@export var ability_outline_color_start := Color("#03fc9050")
@export var ability_outline_color_end := Color("#03fc9050")

@export var enemy_outline_color_start := Color("#fc980353")
@export var enemy_outline_color_end := Color("#fc980353")

@export var terrain_outline_color_start := Color("#fc900320")
@export var terrain_outline_color_end := Color("#d703fc20")

@export var pickup_outline_color_start := Color("#c2fc034d")
@export var pickup_outline_color_end := Color("#c2fc034d")

@export var bubble_color_start := Color("#0000004d")
@export var bubble_color_end := Color("#e6e6e64d")

@export var cursor_blink_in_alpha := 1.0
@export var cursor_blink_out_alpha := 0.1

@export var highlighted_hud_label_text_color := Color("#009957")
@export_group("")

@export var player_outline_size := 12.0
@export var enemy_outline_size := 12.0
@export var terrain_outline_size := 12.0
@export var pickup_outline_size := 12.0

@export var color_update_period_sec := 1.0
@export var time_to_max_darkness_sec := 120.0
@export var time_to_max_difficulty_sec := 300.0
@export var progress_to_switch_to_light_text_color := 0.5

@export var main_menu_animation_duration_sec := 2.0
@export var player_death_animation_duration_sec := 0.75
@export var level_reset_animation_duration_sec := 0.3
@export var main_menu_zoom_out_duration_sec := 0.2
@export var reset_zoom_in_duration_sec := 0.3

@export var hud_fade_in_duration_sec := 0.2
@export var hud_fade_out_duration_sec := 0.1

@export var show_clippy_duration_sec := 0.3
@export var hide_clippy_duration_sec := 0.2

@export var cancel_pending_text_delay_sec := 0.5
@export var cancel_pending_text_with_prefix_match_delay_sec := 0.8
@export var cursor_blink_period_sec := 0.5
@export var cursor_invincible_blink_period_sec := 0.06

@export var space_key_throttle_period_sec := 0.05

@export var main_menu_character_interval_sec := 0.09
@export var clippy_character_interval_sec := 0.022

@export var invincible_from_damage_cooldown_sec := 3.0
@export var invincible_from_power_up_cooldown_sec := 9.0

@export var start_enemy_spawn_interval_min_sec := 6.0
@export var start_enemy_spawn_interval_max_sec := 8.0

@export var end_enemy_spawn_interval_min_sec := 3.0
@export var end_enemy_spawn_interval_max_sec := 4.0

@export var start_bubble_spawn_interval_min_sec := 0.3
@export var start_bubble_spawn_interval_max_sec := 0.9

@export var end_bubble_spawn_interval_min_sec := 0.9
@export var end_bubble_spawn_interval_max_sec := 1.8

@export var start_scroll_speed := 70.0
@export var end_scroll_speed := 260.0

@export var main_menu_camera_zoom := 3.0
@export var gameplay_camera_zoom := 1.0

@export var main_menu_camera_offset_y := 0.0
@export var gameplay_camera_offset_y := 150.0

@export var default_font_size := 24
@export var default_cursor_scale := 0.3

@export var game_area_size := Vector2i(768, 768)
@export var game_area_padding := Vector2i(2, 2)

@export var game_area_bubble_spawn_padding := Vector2i(4, 4)
@export var game_area_enemy_spawn_padding := Vector2i(40, 40)

var initial_fragment := load("res://src/levels/fragments/level_fragment_initial.tscn")

var fragments: Array[PackedScene] = [
    load("res://src/levels/fragments/level_fragment_1.tscn"),
    load("res://src/levels/fragments/level_fragment_2.tscn"),
    load("res://src/levels/fragments/level_fragment_3.tscn"),
    load("res://src/levels/fragments/level_fragment_4.tscn"),
    load("res://src/levels/fragments/level_fragment_5.tscn"),
    load("res://src/levels/fragments/level_fragment_6.tscn"),
]

@export_group("LabelSettings")
@export var cursor_label_settings := preload("res://src/ui/styles/cursor_label_settings.tres")
@export var typed_text_label_settings := preload("res://src/ui/styles/typed_text_label_settings.tres")
@export var ability_label_settings := preload("res://src/ui/styles/ability_label_settings.tres")
@export var enemy_label_settings := preload("res://src/ui/styles/enemy_label_settings.tres")
@export var terrain_label_settings := preload("res://src/ui/styles/terrain_label_settings.tres")
@export var pickup_label_settings := preload("res://src/ui/styles/pickup_label_settings.tres")
@export var bubble_label_settings := preload("res://src/ui/styles/bubble_label_settings.tres")
@export var hud_label_settings := preload("res://src/ui/styles/hud_label_settings.tres")
@export var highlighted_hud_label_settings := preload("res://src/ui/styles/highlighted_hud_label_settings.tres")
@export_group("")

@export var hud_panel_style := preload("res://src/ui/styles/hud_panel.tres")

@export var player_scene := preload("res://src/entities/player.tscn")
@export var character_scene := preload("res://src/entities/character.tscn")
@export var invisible_layout_character_scene := preload("res://src/entities/invisible_layout_character.tscn")
@export var hud_row_scene := preload("res://src/ui/hud_row.tscn")
@export var ability_scene := preload("res://src/entities/ability.tscn")
@export var bubble_scene := preload("res://src/entities/bubble.tscn")
@export var enemy_scene := preload("res://src/entities/enemy.tscn")
@export var pickup_scene := preload("res://src/entities/pickup.tscn")

# TODO: Add more ability text alternatives!
# [{name: String, controller: Script, values: [String]}]
var abilities := [
    {
        name = "shield",
        controller = ShieldAbility,
        values = [
            "shield",
            "defend",
            "barrier",
            "guard",
            "insurmountable",
            "invulnerable",
            "impenetrable",
            "impervious",
            "indefatigable",
            "thick skin",
            "ironsides",
        ],
    },
    {
        name = "torpedo",
        controller = TorpedoAbility,
        values = [
            "torpedo",
            "harpoon",
            "shoot",
            "fire",
            "launch",
            "missile",
            "projectile",
            "attack",
            "bombard",
            "bombs away",
        ],
    },
    {
        name = "drop",
        controller = DropAbility,
        values = [
            "rock",
            "anchor",
            "dead weight",
            "drop",
            "sink",
            "plummet",
            "stone",
            "brick",
            "fall",
            "nosedive",
            "plunge",
        ],
    },
]

# TODO: Add more enemy text alternatives!
# [{name: String, controller: Script, values: [String]}]
var enemies := [
    {
        name = "small_fish",
        controller = SmallFishEnemy,
        values = [
            "guppy",
            "minnow",
            "anchovy",
            "sardine",
            "herring",
            "perch",
        ],
    },
    {
        name = "big_fish",
        controller = BigFishEnemy,
        values = [
            "tuna",
            "snapper",
            "salmon",
            "grouper",
            "cod",
            "bass",
        ],
    },
    {
        name = "shark",
        controller = SharkEnemy,
        values = [
            "shark",
            "hammerhead",
            "great white shark",
            "bull shark",
            "reef shark",
            "baracuda",
            "tiger shark",
        ],
    },
    {
        name = "squid",
        controller = SquidEnemy,
        values = [
            "squid",
            "cuttlefish",
            "giant squid",
            "kraken",
            "jellyfish",
        ],
    },
]

var debug_initial_abilities := [
    {name = "drop", value = "rock"},

    {name = "torpedo", value = "torpedo"},

    {name = "shield", value = "shield"},
]


func sanitize() -> void:
    for entry in abilities:
        for i in range(entry.values.size()):
            entry.values[i] = entry.values[i].to_upper()

    for entry in debug_initial_abilities:
        entry.value = entry.value.to_upper()


func get_start_color(type: ColorType) -> Color:
    match type:
        ColorType.BACKGROUND:
            return background_color_start
        ColorType.TEXT:
            return text_color_start
        ColorType.CURSOR_OUTLINE:
            return cursor_outline_color_start
        ColorType.TYPED_TEXT_OUTLINE:
            return typed_text_outline_color_start
        ColorType.ABILITY_OUTLINE:
            return ability_outline_color_start
        ColorType.ENEMY_OUTLINE:
            return enemy_outline_color_start
        ColorType.TERRAIN_OUTLINE:
            return terrain_outline_color_start
        ColorType.PICKUP_OUTLINE:
            return pickup_outline_color_start
        ColorType.BUBBLE:
            return bubble_color_start
    return Color.MAGENTA


func get_end_color(type: ColorType) -> Color:
    match type:
        ColorType.BACKGROUND:
            return background_color_end
        ColorType.TEXT:
            return text_color_end
        ColorType.CURSOR_OUTLINE:
            return cursor_outline_color_end
        ColorType.TYPED_TEXT_OUTLINE:
            return typed_text_outline_color_end
        ColorType.ABILITY_OUTLINE:
            return ability_outline_color_end
        ColorType.ENEMY_OUTLINE:
            return enemy_outline_color_end
        ColorType.TERRAIN_OUTLINE:
            return terrain_outline_color_end
        ColorType.PICKUP_OUTLINE:
            return pickup_outline_color_end
        ColorType.BUBBLE:
            return bubble_color_end
    return Color.MAGENTA
