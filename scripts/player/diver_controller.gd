class_name DiverController
extends CharacterBody3D

signal interact_requested
signal flashlight_toggled(is_enabled: bool)

@export_group("References")
@export var head_pivot: Node3D
@export var flashlight: SpotLight3D

@export_group("Swim Movement")
@export var swim_speed: float = 5.5
@export var sprint_multiplier: float = 1.6
@export var swim_acceleration: float = 10.0
@export var water_drag: float = 5.0

@export_group("Camera Look")
@export var mouse_sensitivity: float = 0.0025
@export var max_pitch_degrees: float = 85.0

var _input_reader: DiverInput = DiverInput.new()
var _pitch_radians: float = 0.0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if _input_reader.is_pause_just_pressed():
		_toggle_mouse_capture()
		return

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var motion: InputEventMouseMotion = event as InputEventMouseMotion
		_apply_look(motion.relative)


func _physics_process(delta: float) -> void:
	_handle_action_triggers()
	_apply_swim_movement(delta)
	move_and_slide()


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


func _handle_action_triggers() -> void:
	if _input_reader.is_interact_just_pressed():
		interact_requested.emit()

	if _input_reader.is_flashlight_just_pressed():
		_toggle_flashlight()


func _toggle_flashlight() -> void:
	if flashlight == null:
		return
	flashlight.visible = not flashlight.visible
	flashlight_toggled.emit(flashlight.visible)


func _toggle_mouse_capture() -> void:
	var is_captured: bool = Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if is_captured else Input.MOUSE_MODE_CAPTURED)


func _apply_swim_movement(delta: float) -> void:
	var wish_direction: Vector3 = _compute_wish_direction()
	var target_speed: float = swim_speed * (sprint_multiplier if _input_reader.is_sprinting() else 1.0)
	var target_velocity: Vector3 = wish_direction * target_speed
	var blend_rate: float = swim_acceleration if not wish_direction.is_zero_approx() else water_drag
	velocity = velocity.move_toward(target_velocity, blend_rate * delta)


func _compute_wish_direction() -> Vector3:
	var planar: Vector2 = _input_reader.get_planar_axis()
	var vertical: float = _input_reader.get_vertical_axis()
	var look_basis: Basis = head_pivot.global_basis if head_pivot != null else global_basis
	var forward_dir: Vector3 = -look_basis.z
	var right_dir: Vector3 = look_basis.x
	var combined: Vector3 = (right_dir * planar.x) + (forward_dir * -planar.y) + (Vector3.UP * vertical)
	return combined.normalized() if combined.length_squared() > 1.0 else combined
