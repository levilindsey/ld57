class_name AnimationController
extends Node

var _animation_jobs: Dictionary[AnimationJob, bool]
var _staggered_character_jobs: Dictionary[StaggeredCharacterJob, bool]


static func get_current_time_sec() -> float:
    return Time.get_ticks_msec() / 1000.0


func _process(delta: float) -> void:
    var current_time := get_current_time_sec()

    for job in _animation_jobs.keys():
        job.update(current_time)
        if job.is_complete(current_time):
            _animation_jobs.erase(job)

    for job in _staggered_character_jobs.keys():
        job.update(current_time)
        if job.is_complete():
            _staggered_character_jobs.erase(job)


func start_animation(config: Dictionary) -> AnimationJob:
    var job := AnimationJob.new(config)
    _animation_jobs[job] = true
    job.start()
    return job


func stop_animation(job: AnimationJob) -> void:
    _animation_jobs.erase(job)


func stop_all_animations() -> void:
    _animation_jobs.clear()


func stagger_calls_for_each_character(
        text: String, interval_sec: float, label_or_callback: Variant) -> StaggeredCharacterJob:
    var job := StaggeredCharacterJob.new(text, interval_sec, label_or_callback)
    _staggered_character_jobs[job] = true
    job.start()
    return job


func stop_stagger_character_job(job: StaggeredCharacterJob) -> void:
    _staggered_character_jobs.erase(job)


func stop_all_stagger_character_jobs() -> void:
    _staggered_character_jobs.clear()
