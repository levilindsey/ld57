class_name Clippy
extends Node2D


enum Anim {
    GLANCE,
    HEAD_SCRATCH,
    HEY_YOU,
    POINT,
    CHECK,
    EXCLAMATION,
}

const _filler_anims: Array[Clippy.Anim] = [
    Anim.GLANCE,
    Anim.HEAD_SCRATCH,
]

const frame_size := Vector2i(111, 91)

@export var initial_delay_sec := 0.4

@export var pause_min_sec := 0.7
@export var pause_max_sec := 2.8

var _anim_queue: Array[Clippy.Anim] = []

@onready var pause_timer: Timer = %PauseTimer

var _has_initial_anim_played := false


func _ready() -> void:
    G.clippy = self

    pause_timer.connect("timeout", _on_pause_timeout)

    for sprite in %Sprites.get_children():
        sprite.animation_finished.connect(_on_animation_complete)


func _show_animation(anim: Clippy.Anim) -> void:
    var target_sprite := _get_sprite(anim)
    for sprite in %Sprites.get_children():
        if sprite != target_sprite:
            sprite.visible = false
            sprite.stop()
            sprite.frame = 0
    target_sprite.visible = true


func _play_animation(anim: Clippy.Anim) -> void:
    _show_animation(anim)
    pause_timer.stop()
    var sprite := _get_sprite(anim)
    sprite.frame = 0
    sprite.play()


func _get_sprite(anim: Clippy.Anim) -> AnimatedSprite2D:
    match anim:
        Anim.GLANCE:
            return %ClippyGlance
        Anim.HEAD_SCRATCH:
            return %ClippyHeadScratch
        Anim.HEY_YOU:
            return %ClippyHeyYou
        Anim.POINT:
            return %ClippyPoint
        Anim.CHECK:
            return %ClippyCheck
        Anim.EXCLAMATION:
            return %ClippyExclamation
    S.utils.ensure(false)
    return %ClippyGlance


func on_start() -> void:
    _has_initial_anim_played = false
    var anim := Anim.HEY_YOU
    _show_animation(anim)
    await get_tree().create_timer(initial_delay_sec).timeout
    _has_initial_anim_played = true
    _enqueue(anim)


func on_damage() -> void:
    _enqueue(Anim.EXCLAMATION)


func on_pickup() -> void:
    _enqueue(Anim.CHECK)


func on_pick_visible() -> void:
    _enqueue(Anim.POINT)


func _on_pause_timeout() -> void:
    if _anim_queue.is_empty():
        var index := randi_range(0, _filler_anims.size() - 1)
        var anim: Clippy.Anim = _filler_anims[index]
        _enqueue(anim)


func _on_animation_complete() -> void:
    if _anim_queue.is_empty():
        pause_timer.wait_time = randf_range(pause_min_sec, pause_max_sec)
        pause_timer.start()
    else:
        var anim: Clippy.Anim = _anim_queue.pop_front()
        _play_animation(anim)


func _enqueue(anim: Clippy.Anim) -> void:
    if not _has_initial_anim_played:
        return

    if _anim_queue.is_empty():
        _play_animation(anim)
    else:
        _anim_queue.push_back(anim)
