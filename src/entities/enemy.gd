class_name Enemy
extends Word


var oscillation_direction := Vector2.RIGHT
var oscillation_amplitude := 0.0
var oscillation_interval_sec := 0.0

var translation_direction := Vector2.UP
var translation_speed := 0.0

var moves_toward_player := false

var start_time_sec := 0.0

var anchor_position := Vector2.ZERO


func _process(delta_sec: float) -> void:
    # HACK: The AnimationJob system should work for this, but it's broken.

    if translation_speed != 0.0:
        var translation_distance := translation_speed * delta_sec
        var direction := (
            (G.player.global_position - global_position).normalized() if
            moves_toward_player else
            translation_direction
        )
        var translation_displacement := direction * translation_distance
        anchor_position += translation_displacement
        global_position += translation_displacement

    if oscillation_amplitude > 0.0 and oscillation_interval_sec > 0.0:
        var current_time_sec := Anim.get_current_time_sec()
        var elapsed_time_sec := current_time_sec - start_time_sec

        var progress := fmod(elapsed_time_sec, oscillation_interval_sec) / oscillation_interval_sec
        progress = sin(TAU * progress)
        var offset := (
            -oscillation_amplitude +
            oscillation_amplitude * 2 * progress
        )
        var oscillation_displacement := oscillation_direction * offset
        global_position = anchor_position + oscillation_displacement


func set_up(text: String) -> void:
    await set_up_from_text(text, Character.Type.ENEMY)

    %CollisionShape2D.shape.size = size

    start_time_sec = Anim.get_current_time_sec()
    anchor_position = global_position


func on_hit_with_torpedo(torpedo: TorpedoAbility) -> void:
    explode_from_point(
        torpedo.word.global_position,
        PI,
        1.0,
        get_current_speed(),
        get_current_direction_angle())
