class_name StaggeredCharacterJob
extends RefCounted


signal stopped


var text: String
var interval_sec: float
var label: Label
var callback: Callable

var last_call_time_sec := 0.0
var index := 0


func _init(text: String, interval_sec: float, label_or_callback: Variant) -> void:
    self.text = text
    self.interval_sec = interval_sec
    if label_or_callback is Callable:
        self.callback = label_or_callback
    elif label_or_callback is Label:
        self.label = label_or_callback
    else:
        S.utils.ensure(false)


func start() -> void:
    if is_instance_valid(label):
        label.text = ""
    _trigger()
    last_call_time_sec = G.get_current_time_sec()


func update(current_time_sec: float) -> void:
    while (not is_complete() and
            current_time_sec > last_call_time_sec + interval_sec):
        _trigger()
        last_call_time_sec += interval_sec

    if is_complete():
        stopped.emit()


func _trigger() -> void:
    if is_instance_valid(label):
        label.text += text[index]
    else:
        callback.call(text[index])

    index += 1


func is_complete() -> bool:
    return index >= text.length()
