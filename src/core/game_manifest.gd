class_name GameManifest
extends ScaffolderManifest

enum ColorType {
    BACKGROUND,
    TEXT,
    PLAYER_OUTLINE,
    ENEMY_OUTLINE,
    TERRAIN_OUTLINE,
    PICKUP_OUTLINE,
    BUBBLE_OUTLINE,
}

const PLAYER_COLLISION_LAYER := 1 << 0
const ENEMY_COLLISION_LAYER := 1 << 1
const TERRAIN_COLLISION_LAYER := 1 << 2
const PICKUP_COLLISION_LAYER := 1 << 3
const PLAYER_PROJECTILE_COLLISION_LAYER := 1 << 4
const ENEMY_PROJECTILE_COLLISION_LAYER := 1 << 5

@export var starting_health := 3

@export_group("Colors")
@export var background_color_start := Color("#f5fcfcff")
@export var background_color_end := Color("#00020aff")

@export var text_color_start := Color("#000000ff")
@export var text_color_end := Color("#e6e6e6ff")

@export var player_outline_color_start := Color("#03fc904d")
@export var player_outline_color_end := Color("#03fc904d")

@export var enemy_outline_color_start := Color("#fc980333")
@export var enemy_outline_color_end := Color("#fc980333")

@export var terrain_outline_color_start := Color("#fc90030d")
@export var terrain_outline_color_end := Color("#d703fc0d")

@export var pickup_outline_color_start := Color("#c2fc034d")
@export var pickup_outline_color_end := Color("#c2fc034d")

@export var background_bubble_color_start := Color("#0000004d")
@export var background_bubble_color_end := Color("#0000004d")

@export var cursor_blink_in_alpha := 1.0
@export var cursor_blink_out_alpha := 0.1
@export_group("")

@export var player_outline_size := 12.0
@export var enemy_outline_size := 12.0
@export var terrain_outline_size := 12.0
@export var pickup_outline_size := 12.0

@export var color_update_period_sec := 1.0
@export var color_transition_duration_sec := 120.0

@export var main_menu_animation_duration_sec := 2.0
@export var player_death_animation_duration_sec := 4.0
@export var level_reset_animation_duration_sec := 1.0
@export var main_menu_zoom_out_duration_sec := 0.5
@export var reset_zoom_in_duration_sec := 1.0

@export var cancel_pending_text_delay_sec := 0.8
@export var cursor_blink_period_sec := 0.5

@export var space_key_throttle_period_sec := 0.05

@export var main_menu_camera_zoom := 3.0
@export var gameplay_camera_zoom := 1.0

@export var main_menu_camera_offset_y := 0.0
@export var gameplay_camera_offset_y := 150.0

@export var default_font_size := 24
@export var default_cursor_scale := 0.3

@export var game_area_size := Vector2i(768, 768)
@export var game_area_padding := Vector2i(0, 0)
#@export var game_area_padding := Vector2i(12, 12)

@export var fragments: Array[PackedScene] = [
    preload("res://src/levels/level_fragment_1.tscn"),
]

@export_group("LabelSettings")
@export var player_label_settings := preload("res://src/ui/player_label_settings.tres")
@export var enemy_label_settings := preload("res://src/ui/enemy_label_settings.tres")
@export var terrain_label_settings := preload("res://src/ui/terrain_label_settings.tres")
@export var pickup_label_settings := preload("res://src/ui/pickup_label_settings.tres")
@export var bubble_label_settings := preload("res://src/ui/bubble_label_settings.tres")
@export_group("")

@export var player_scene := preload("res://src/player/player.tscn")
@export var character_scene := preload("res://src/player/character.tscn")


func get_start_color(type: ColorType) -> Color:
    match type:
        ColorType.BACKGROUND:
            return background_color_start
        ColorType.TEXT:
            return text_color_start
        ColorType.PLAYER_OUTLINE:
            return player_outline_color_start
        ColorType.ENEMY_OUTLINE:
            return enemy_outline_color_start
        ColorType.TERRAIN_OUTLINE:
            return terrain_outline_color_start
        ColorType.PICKUP_OUTLINE:
            return pickup_outline_color_start
        ColorType.BUBBLE_OUTLINE:
            return background_bubble_color_start
    return Color.MAGENTA


func get_end_color(type: ColorType) -> Color:
    match type:
        ColorType.BACKGROUND:
            return background_color_end
        ColorType.TEXT:
            return text_color_end
        ColorType.PLAYER_OUTLINE:
            return player_outline_color_end
        ColorType.ENEMY_OUTLINE:
            return enemy_outline_color_end
        ColorType.TERRAIN_OUTLINE:
            return terrain_outline_color_end
        ColorType.PICKUP_OUTLINE:
            return pickup_outline_color_end
        ColorType.BUBBLE_OUTLINE:
            return background_bubble_color_end
    return Color.MAGENTA
