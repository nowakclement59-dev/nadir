class_name DiverInput
extends RefCounted

const ACTION_MOVE_FORWARD: StringName = &"move_forward"
const ACTION_MOVE_BACKWARD: StringName = &"move_backward"
const ACTION_MOVE_LEFT: StringName = &"move_left"
const ACTION_MOVE_RIGHT: StringName = &"move_right"
const ACTION_SWIM_UP: StringName = &"swim_up"
const ACTION_SWIM_DOWN: StringName = &"swim_down"
const ACTION_SPRINT: StringName = &"sprint"
const ACTION_INTERACT: StringName = &"interact"
const ACTION_FLASHLIGHT: StringName = &"flashlight"
const ACTION_PAUSE: StringName = &"pause"


func get_planar_axis() -> Vector2:
	return Input.get_vector(
		ACTION_MOVE_LEFT,
		ACTION_MOVE_RIGHT,
		ACTION_MOVE_FORWARD,
		ACTION_MOVE_BACKWARD
	)


func get_vertical_axis() -> float:
	return Input.get_axis(ACTION_SWIM_DOWN, ACTION_SWIM_UP)


func is_sprinting() -> bool:
	return Input.is_action_pressed(ACTION_SPRINT)


func is_interact_just_pressed() -> bool:
	return Input.is_action_just_pressed(ACTION_INTERACT)


func is_flashlight_just_pressed() -> bool:
	return Input.is_action_just_pressed(ACTION_FLASHLIGHT)


func is_pause_just_pressed() -> bool:
	return Input.is_action_just_pressed(ACTION_PAUSE)
