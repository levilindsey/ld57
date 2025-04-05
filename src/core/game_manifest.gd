class_name GameManifest
extends ScaffolderManifest

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

@export var main_menu_camera_zoom := 8.0
@export var gameplay_camera_zoom := 1.0

@export var player_scene: PackedScene

@export var fragments: Array[PackedScene] = [
    preload("res://src/levels/level_fragment_1.tscn"),
]
