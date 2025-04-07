class_name AnimationJob
extends RefCounted


signal stopped


var node: Node2D

var destroys_node_when_done: bool
var is_one_shot: bool
var ease_name := "ease_in_out"

var start_time_sec := 0.0

var duration_sec := 0.0

var start_opacity: float
var end_opacity := -1.0

var start_speed := 0.0

var anchor_position: Vector2
var is_clockwise := false

var interval_min_sec := 0.0
var interval_max_sec := 0.0

var intervals: Dictionary[String, DimensionInterval] = {}

const _job_keys := [
    "duration_sec",
    "end_opacity",
]

const _interval_keys := [
    "direction_angle",
    "speed",
    "acceleration",
    "rotation_speed",
    "perpendicular_oscillation_amplitude",
    "scale_x",
    "scale_y",
    "skew",
]


# AnimationJob.new({
#     node: node,
#
#     destroys_node_when_done: true,
#
#     # If recurring, then interval_sec must be included.
#     is_one_shot: false,
#
#     ease_name?: "ease_in_out",
#
#     direction_angle?: -PI / 4,
#     direction_deviaton_angle_max?: PI / 8,
#
#     start_speed?: 0.0, # If included, this will be used as the initial speed value. Otherwise, a random initial value will be calculated from speed.
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
    destroys_node_when_done = config.destroys_node_when_done
    is_one_shot = config.is_one_shot

    anchor_position = node.position
    start_opacity = node.modulate.a

    if config.has("rotation_speed"):
        is_clockwise = randf() < 0.5

    if config.has("ease_name"):
        ease_name = config.ease_name

    for key in _job_keys:
        if config.has(key):
            if config[key] is float or config[key] is int:
                self[key] = config[key]
            else:
                S.utils.ensure(config[key] is Array and config[key].size() == 2)
                self[key] = randf_range(config[key][0], config[key][1])

    if not is_one_shot:
        S.utils.ensure(config.has("interval_sec"))

        if config.interval_sec is float or config.interval_sec is int:
            interval_min_sec = config.interval_sec
            interval_max_sec = config.interval_sec
        else:
            S.utils.ensure(
                config.interval_sec is Array and
                config.interval_sec.size() == 2)
            interval_min_sec = config.interval_sec[0]
            interval_max_sec = config.interval_sec[1]

    if interval_min_sec == 0.0:
        S.utils.ensure(config.has("duration_sec"))

    if config.has("direction_angle"):
        var interval := DimensionInterval.new()
        intervals["direction_angle"] = interval

        var direction_deviaton_angle_max: float = (
            config.direction_deviaton_angle_max
            if config.has("direction_deviaton_angle_max")
            else 0.0
        )
        interval.set_range(
            "direction_angle",
            config.direction_angle - direction_deviaton_angle_max,
            config.direction_angle + direction_deviaton_angle_max)

    for key in _interval_keys:
        if config.has(key):
            var interval := DimensionInterval.new()
            intervals[key] = interval

            if config[key] is float or config[key] is int:
                interval.set_value(key, config[key])
            else:
                S.utils.ensure(
                    config[key] is Array and
                    config[key].size() == 2)
                interval.set_range(key, config[key][0], config[key][1])

    if config.has("start_speed"):
        S.utils.ensure(config.has("speed"))

    if config.has("speed"):
        if config.has("start_speed"):
            start_speed = config.start_speed
        else:
            start_speed = intervals.speed.rand_value()


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
    if not is_instance_valid(node):
        return

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
        var progress := clampf(
            (interval.current_time_sec - interval.start_time_sec) /
            (interval.end_time_sec - interval.start_time_sec),
            0,
            1
        )
        progress = S.utils.ease_by_name(progress, ease_name)
        interval.current_value = lerpf(
            interval.start_value, interval.end_value, progress)
        _apply_value_to_node(interval, elapsed_sec)

    if end_opacity >= 0 and duration_sec > 0:
        var progress := clampf(
            (current_time_sec - start_time_sec) / duration_sec,
            0,
            1
        )
        progress = S.utils.ease_by_name(progress, ease_name)
        node.modulate.a = lerp(start_opacity, end_opacity, progress)

    if is_complete(current_time_sec) and destroys_node_when_done:
        node.queue_free()


func _trigger(interval: DimensionInterval, current_time_sec: float) -> void:
    interval.start_value = interval.current_value
    interval.end_value = interval.rand_value()
    interval.start_time_sec = current_time_sec
    var interval_duration_sec := (
        randf_range(interval_min_sec, interval_max_sec)
        if interval_min_sec > 0.0
        else duration_sec
    )
    interval.end_time_sec = interval.start_time_sec + interval_duration_sec


func is_complete(current_time_sec: float) -> bool:
    return (
        not is_instance_valid(node) or
        duration_sec > 0
        and current_time_sec >= start_time_sec + duration_sec
    )


func get_current_speed() -> float:
    if intervals.has("speed"):
        return intervals.speed.current_value
    else:
        return 0.0


func get_current_direction_angle() -> float:
    if intervals.has("direction_angle"):
        return intervals.direction_angle.current_value
    else:
        return 0.0


func _apply_value_to_node(interval: DimensionInterval, elapsed_sec: float) -> void:
    match interval.key:
        "direction_angle":
            # Do nothing on the node directly.
            # Other dimensions will use this.
            pass
        "perpendicular_oscillation_amplitude":
            var progress := clampf(
                (interval.current_time_sec - interval.start_time_sec) /
                (interval.end_time_sec - interval.start_time_sec),
                0,
                1
            )
            # Use interval.current_value as the current anchor_amplitude for the
            # oscillation calculation.
            var perpendicular_offset := interval.current_value * sin(progress * PI)
            var direction := Vector2.from_angle(intervals.direction_angle.current_value)
            var displacement := direction.orthogonal() * perpendicular_offset
            node.position = anchor_position + displacement
        "speed":
            var direction := Vector2.from_angle(intervals.direction_angle.current_value)
            var displacement := direction * interval.current_value
            anchor_position += displacement
            node.position += displacement
        "acceleration":
            var delta := interval.current_value * elapsed_sec
            intervals.speed.end_value += delta
            intervals.speed.min += delta
            intervals.speed.max += delta
        "rotation_speed":
            var delta := interval.current_value * elapsed_sec
            if is_clockwise:
                delta *= -1
            node.rotation += delta
        "scale_x":
            node.scale.x = interval.current_value
        "scale_y":
            node.scale.y = interval.current_value
        "skew":
            node.skew = interval.current_value
        _:
            S.utils.ensure(false)


func _get_initial_value(interval: DimensionInterval) -> float:
    match interval.key:
        "direction_angle", \
        "acceleration", \
        "rotation_speed":
            return interval.rand_value()
        "speed":
            return start_speed
        "perpendicular_oscillation_amplitude":
            return 0.0
        "scale_x":
            return node.scale.x
        "scale_y":
            return node.scale.y
        "skew":
            return node.skew
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


    func rand_value() -> float:
        return randf_range(min, max)
