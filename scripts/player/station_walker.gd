class_name StationWalker
extends CharacterBody3D

## Contrôleur FPS au sol pour l'exploration de la station pressurisée.

signal interact_requested

@export_group("References")
@export var head_pivot: Node3D
@export var interaction_ray: RayCast3D

@export_group("Walk Movement")
@export var walk_speed: float = 4.2
@export var sprint_multiplier: float = 1.45
@export var gravity: float = 14.0
@export var jump_velocity: float = 4.5

@export_group("Camera Look")
@export var mouse_sensitivity: float = 0.0025
@export var max_pitch_degrees: float = 82.0

var movement_enabled: bool = true

var _input_reader: DiverInput = DiverInput.new()
var _pitch_radians: float = 0.0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if not movement_enabled:
		return

	if event.is_action_pressed(DiverInput.ACTION_PAUSE) and _input_reader.is_pause_just_pressed():
		_toggle_mouse_capture()
		return

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var motion: InputEventMouseMotion = event as InputEventMouseMotion
		_apply_look(motion.relative)


func _physics_process(delta: float) -> void:
	if not movement_enabled:
		velocity = Vector3.ZERO
		return

	_apply_walk_movement(delta)
	move_and_slide()

	if _input_reader.is_interact_just_pressed():
		interact_requested.emit()


func set_movement_enabled(enabled: bool) -> void:
	movement_enabled = enabled
	if not enabled:
		velocity = Vector3.ZERO
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func get_looked_at_interactable() -> BaseInteractable:
	if interaction_ray == null or not interaction_ray.is_colliding():
		return null
	return interaction_ray.get_collider() as BaseInteractable


func _apply_look(relative_motion: Vector2) -> void:
	rotate_y(-relative_motion.x * mouse_sensitivity)
	var max_pitch: float = deg_to_rad(max_pitch_degrees)
	_pitch_radians = clampf(
		_pitch_radians - relative_motion.y * mouse_sensitivity,
		-max_pitch,
		max_pitch
	)
	if head_pivot != null:
		head_pivot.rotation.x = _pitch_radians


func _apply_walk_movement(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed(DiverInput.ACTION_SWIM_UP):
		velocity.y = jump_velocity

	var axis: Vector2 = _input_reader.get_planar_axis()
	var direction: Vector3 = global_basis * Vector3(axis.x, 0.0, axis.y)
	direction.y = 0.0
	if direction.length_squared() > 1.0:
		direction = direction.normalized()

	var speed: float = walk_speed * (sprint_multiplier if _input_reader.is_sprinting() else 1.0)
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed


func _toggle_mouse_capture() -> void:
	var is_captured: bool = Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if is_captured else Input.MOUSE_MODE_CAPTURED)
