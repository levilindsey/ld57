class_name AnimationJob
extends RefCounted


signal stopped


var node: Node2D

var is_one_shot: bool

var start_time_sec := 0.0

var duration_sec := 0.0
var end_opacity := -1.0

var anchor_position: Vector2

var interval_min_sec := 0.0
var interval_max_sec := 0.0

var intervals: Dictionary[String, DimensionInterval] = {}

const _job_keys := [
    "duration_sec",
    "end_opacity",
]

const _interval_keys := [
    "direction",
    "speed",
    "acceleration",
    "rotation_speed",
    "perpendicular_offset",
    "scale_x",
    "scale_y",
    "skew",
]


# AnimationJob.new({
#     node: node,
#
#     # If recurring, then interval_sec must be included.
#     is_one_shot: false,
#
#     direction?: away,
#     direction_deviaton_angle_max?: PI / 8,
#
#     # These can all be either a single number, or an array of two numbers.
#     duration_sec?: [3.0, 4.0], # If omitted, the animation won't stop.
#     end_opacity?: [0.0, 0.0],
#     interval_sec?: [0.3, 2.0], # If ommitted, duration_sec must be included.
#     speed?: [50, 90],
#     acceleration?: [-10, 0.0],
#     rotation_speed?: [0.01, 0.5],
#     perpendicular_oscillation_amplitude?: [0, 10.0],
#     scale_x?: [0.9, 1.1],
#     scale_y?: [0.9, 1.1],
#     skew?: [0, PI / 8],
# })
func _init(config: Dictionary) -> void:
    S.utils.ensure(config.has("node"))
    S.utils.ensure(config.has("is_one_shot"))

    node = config.node
    is_one_shot = config.is_one_shot

    anchor_position = node.position

    for key in _job_keys:
        if config.has(key):
            if config[key] is float or config[key] is int:
                self[key] = config[key]
            else:
                S.utils.ensure(config[key] is Array and config[key].size() == 2)
                self[key] = randf_range(config[key][0], config[key][1])

    if not is_one_shot:
        S.utils.ensure(config.has("interval_sec"))

        interval_min_sec = config.interval_sec[0]
        interval_max_sec = config.interval_sec[1]

    if interval_min_sec == 0.0:
        S.utils.ensure(config.has("duration_sec"))

    if config.has("direction"):
        var interval := DimensionInterval.new()
        intervals["direction"] = interval

        var target_direction_angle: float = config.direction.angle()
        var direction_deviaton_angle_max: float = (
            config.direction_deviaton_angle_max
            if config.has("direction_deviaton_angle_max")
            else 0.0
        )
        interval.set_range(
            "direction",
            target_direction_angle - direction_deviaton_angle_max,
            target_direction_angle + direction_deviaton_angle_max)

    for key in _interval_keys:
        if config.has(key):
            var interval := DimensionInterval.new()
            intervals[key] = interval

            if config[key] is float or config[key] is int:
                interval.set_value(key, config[key])
            else:
                S.utils.ensure(config[key] is Array and config[key].size() == 2)
                interval.set_range(key, config[key][0], config[key][1])


func start() -> void:
    start_time_sec = Anim.get_current_time_sec()
    for key in _interval_keys:
        if not intervals.has(key):
            continue
        var interval := intervals[key]

        interval.current_time_sec = start_time_sec
        interval.current_value = _get_initial_value(interval)
        _trigger(interval, start_time_sec)


func update(current_time_sec: float) -> void:
    for key in _interval_keys:
        if not intervals.has(key):
            continue
        var interval := intervals[key]

        while current_time_sec > interval.end_time_sec:
            var elapsed_sec := interval.end_time_sec - interval.current_time_sec
            interval.current_time_sec = interval.end_time_sec
            interval.current_value = interval.end_value
            _apply_value_to_node(interval, elapsed_sec)

            _trigger(interval, interval.end_time_sec)

        var elapsed_sec := current_time_sec - interval.current_time_sec
        interval.current_time_sec = current_time_sec
        var progress := (
            (interval.current_time_sec - interval.start_time_sec) /
            (interval.end_time_sec - interval.start_time_sec)
        )
        interval.current_value = lerpf(
            interval.start_value, interval.end_value, progress)
        _apply_value_to_node(interval, elapsed_sec)

    # FIXME: LEFT OFF HERE:
    # - Use end_opacity.


func _trigger(interval: DimensionInterval, current_time_sec: float) -> void:
    interval.start_value = interval.current_value
    interval.end_value = randf_range(interval.min, interval.max)
    interval.start_time_sec = current_time_sec
    var interval_duration_sec := (
        randf_range(interval_min_sec, interval_max_sec)
        if interval_min_sec > 0.0
        else duration_sec
    )
    interval.end_time_sec = interval.start_time_sec + interval_duration_sec


func is_complete(current_time_sec: float) -> bool:
    return duration_sec > 0 and current_time_sec >= start_time_sec + duration_sec


# FIXME: LEFT OFF HERE
# - Add easing.
# - A single job-level value.
# - Applied to progress calculation in update.
# - Applied to end_opacity calculation.


func _apply_value_to_node(interval: DimensionInterval, elapsed_sec: float) -> void:
    match interval.key:
        "direction":
            # Do nothing on the node directly.
            # Other dimensions will use this.
            pass
        "perpendicular_oscillation_amplitude":
            var progress := (
                (interval.current_time_sec - interval.start_time_sec) /
                (interval.end_time_sec - interval.start_time_sec)
            )
            # Use interval.current_value as the current anchor_amplitude for the
            # oscillation calculation.
            var perpendicular_offset := interval.current_value * sin(progress * PI)
            var direction := Vector2.from_angle(intervals.direction.current_value)
            var displacement := direction.orthogonal() * perpendicular_offset
            node.position = anchor_position + displacement
        "speed":
            var direction := Vector2.from_angle(intervals.direction.current_value)
            var displacement := direction * interval.current_value
            anchor_position += displacement
            node.position += displacement
        "acceleration":
            var delta := interval.current_value * elapsed_sec
            intervals.speed.end_value += delta
            intervals.speed.min += delta
            intervals.speed.max += delta
        "rotation_speed":
            # FIXME: LEFT OFF HERE
            pass
        "scale_x":
            # FIXME: LEFT OFF HERE
            pass
        "scale_y":
            # FIXME: LEFT OFF HERE
            pass
        "skew":
            # FIXME: LEFT OFF HERE
            pass
    S.utils.ensure(false)


func _get_initial_value(interval: DimensionInterval) -> float:
    match interval.key:
        "direction", \
        "speed", \
        "acceleration", \
        "rotation_speed":
            return randf_range(interval.min, interval.max)
        "skew":
            return node.skew
        "perpendicular_oscillation_amplitude":
            return 0.0
        "scale_x":
            return node.scale.x
        "scale_y":
            return node.scale.y
    S.utils.ensure(false)
    return 0.0


class DimensionInterval extends RefCounted:

    var key: String

    var min: float
    var max: float

    var start_time_sec := 0.0
    var end_time_sec := 0.0

    var start_value: float
    var end_value: float

    var current_time_sec := 0.0

    var current_value: float


    func set_range(key: String, min: float, max: float) -> void:
        self.key = key
        self.min = min
        self.max = max


    func set_value(key: String, value: float) -> void:
        self.key = key
        self.min = value
        self.max = value


    func is_range() -> bool:
        return min != max
