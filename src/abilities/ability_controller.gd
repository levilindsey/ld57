class_name AbilityController
extends RefCounted


var config: Dictionary
var value: String

var start_time_sec := 0.0


func start(config: Dictionary, value: String) -> void:
    self.config = config
    self.value = value

    start_time_sec = Anim.get_current_time_sec()
