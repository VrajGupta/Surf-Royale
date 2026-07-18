class_name SidearmProjectile
extends RefCounted

const WATER_CUTOFF_DEPTH_METERS := 1.0
const GRAVITY_METERS_PER_SECOND_SQUARED := 9.8
const MAX_LIFETIME_SECONDS := 3.0

var position: Vector3
var velocity: Vector3
var alive := true
var water_cutoff := false
var age_seconds := 0.0

func _init(start_position: Vector3, start_velocity: Vector3) -> void:
	position = start_position
	velocity = start_velocity

func step(delta_seconds: float, ocean: Variant, time_seconds: float) -> void:
	if not alive:
		return
	if not position.is_finite() or not velocity.is_finite() or not is_finite(delta_seconds) or not is_finite(time_seconds):
		alive = false
		return

	var delta := maxf(delta_seconds, 0.0)
	if _reached_water_cutoff(ocean, time_seconds):
		return

	position += velocity * delta
	velocity.y -= GRAVITY_METERS_PER_SECOND_SQUARED * delta
	age_seconds += delta
	if not position.is_finite() or not velocity.is_finite() or _reached_water_cutoff(ocean, time_seconds):
		alive = false
		return
	if age_seconds >= MAX_LIFETIME_SECONDS:
		alive = false

func _reached_water_cutoff(ocean: Variant, time_seconds: float) -> bool:
	var surface = ocean.sample(Vector2(position.x, position.z), time_seconds)
	if not is_finite(surface.height):
		alive = false
		return true
	if surface.height - position.y < WATER_CUTOFF_DEPTH_METERS:
		return false
	alive = false
	water_cutoff = true
	return true
