class_name NetworkInputValidator
extends RefCounted

const SurfInputType = preload("res://src/surf/surf_input.gd")

static func sanitize(payload: Variant) -> RefCounted:
	var result := SurfInputType.new()
	if not payload is Dictionary:
		return result

	var steer_value: Variant = payload.get("steer", 0.0)
	if steer_value is float or steer_value is int:
		var steer := float(steer_value)
		result.steer = clampf(steer, -1.0, 1.0) if is_finite(steer) else 0.0

	result.paddle = _strict_bool(payload.get("paddle", false))
	result.duck_dive = _strict_bool(payload.get("duck_dive", false))
	result.pop_up = _strict_bool(payload.get("pop_up", false))
	result.recover = _strict_bool(payload.get("recover", false))
	return result

static func _strict_bool(value: Variant) -> bool:
	return value if value is bool else false
