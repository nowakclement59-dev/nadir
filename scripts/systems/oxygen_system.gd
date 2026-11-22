class_name OxygenSystem
extends Node

signal oxygen_changed(current: float, maximum: float)
signal suffocation_changed(progress: float)
signal suffocated

@export var max_oxygen: float = 60.0
@export var base_drain_per_second: float = 1.0
@export var sprint_drain_multiplier: float = 2.0
@export var suffocation_duration: float = 5.0

var current_oxygen: float = 60.0
var suffocation_progress: float = 0.0
var is_sprinting: bool = false
var is_active: bool = true
var is_dead: bool = false


func _ready() -> void:
	current_oxygen = max_oxygen
	oxygen_changed.emit(current_oxygen, max_oxygen)


func _process(delta: float) -> void:
	if not is_active or is_dead:
		return

	if current_oxygen > 0.0:
		var drain_rate: float = base_drain_per_second * (sprint_drain_multiplier if is_sprinting else 1.0)
		current_oxygen = maxf(0.0, current_oxygen - drain_rate * delta)
		oxygen_changed.emit(current_oxygen, max_oxygen)
		if suffocation_progress > 0.0:
			suffocation_progress = 0.0
			suffocation_changed.emit(suffocation_progress)
		return

	var duration: float = maxf(suffocation_duration, 0.1)
	suffocation_progress = minf(1.0, suffocation_progress + delta / duration)
	suffocation_changed.emit(suffocation_progress)
	if suffocation_progress >= 1.0:
		is_dead = true
		suffocated.emit()


func refill_oxygen(amount: float) -> void:
	if is_dead or amount <= 0.0:
		return
	current_oxygen = minf(max_oxygen, current_oxygen + amount)
	oxygen_changed.emit(current_oxygen, max_oxygen)
	if current_oxygen > 0.0 and suffocation_progress > 0.0:
		suffocation_progress = 0.0
		suffocation_changed.emit(suffocation_progress)


func reset_oxygen() -> void:
	is_dead = false
	is_active = true
	current_oxygen = max_oxygen
	suffocation_progress = 0.0
	oxygen_changed.emit(current_oxygen, max_oxygen)
	suffocation_changed.emit(suffocation_progress)
