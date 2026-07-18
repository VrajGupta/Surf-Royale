class_name SurfController
extends RefCounted

enum State {
	PADDLE,
	DUCK_DIVE,
	POP_UP,
	RIDE,
	WIPEOUT,
	TREAD,
}

const SurfTuningType = preload("res://src/surf/surf_tuning.gd")

var state: State = State.PADDLE
var position := Vector3.ZERO
var velocity := Vector3.ZERO
var stamina := 100.0
var tuning: RefCounted

var _ocean: Variant
var _state_elapsed := 0.0
var _stroke_cooldown := 0.0
var _ride_direction := Vector3(0.0, 0.0, 1.0)

func _init(ocean: Variant, p_tuning: RefCounted = null) -> void:
	_ocean = ocean
	tuning = p_tuning if p_tuning != null else SurfTuningType.new()

func step(input: Variant, delta_seconds: float, time_seconds: float) -> void:
	var delta := maxf(delta_seconds, 0.0)
	_state_elapsed += delta
	_stroke_cooldown = maxf(_stroke_cooldown - delta, 0.0)
	var ocean_sample = _ocean.sample(Vector2(position.x, position.z), time_seconds)

	match state:
		State.PADDLE:
			_step_paddle(input, delta, ocean_sample)
		State.DUCK_DIVE:
			_step_duck_dive(delta, ocean_sample)
		State.POP_UP:
			_step_pop_up(delta, ocean_sample)
		State.RIDE:
			_step_ride(input, delta, ocean_sample)
		State.WIPEOUT:
			_step_wipeout(delta, ocean_sample)
		State.TREAD:
			_step_tread(input, delta, ocean_sample)

	position += velocity * delta
	if state not in [State.DUCK_DIVE, State.WIPEOUT, State.TREAD]:
		position.y = ocean_sample.height
	if state != State.DUCK_DIVE:
		stamina = minf(stamina + tuning.stamina_regen_per_second * delta, 100.0)

func horizontal_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()

func apply_impact(impulse: float) -> void:
	if state not in [State.RIDE, State.POP_UP]:
		return
	if impulse >= tuning.wipeout_impact_threshold:
		_transition_to(State.WIPEOUT)

func _step_paddle(input: Variant, delta: float, ocean_sample: Variant) -> void:
	var horizontal := Vector2(velocity.x, velocity.z)
	horizontal = horizontal.move_toward(Vector2.ZERO, tuning.paddle_drag_per_second * delta)

	if input.paddle and _stroke_cooldown <= 0.0:
		horizontal += Vector2(_ride_direction.x, _ride_direction.z) * tuning.paddle_impulse
		if horizontal.length() > tuning.paddle_max_speed:
			horizontal = horizontal.normalized() * tuning.paddle_max_speed
		_stroke_cooldown = tuning.paddle_stroke_cooldown

	velocity.x = horizontal.x
	velocity.z = horizontal.y

	if input.duck_dive and stamina >= tuning.duck_dive_stamina_cost:
		stamina -= tuning.duck_dive_stamina_cost
		_transition_to(State.DUCK_DIVE)
		return

	if input.pop_up and ocean_sample.break_phase >= tuning.catch_break_phase:
		_transition_to(State.POP_UP)

func _step_duck_dive(_delta: float, ocean_sample: Variant) -> void:
	position.y = ocean_sample.height - 1.1
	velocity *= 0.75
	if _state_elapsed >= tuning.duck_dive_duration:
		_transition_to(State.PADDLE)

func _step_pop_up(delta: float, ocean_sample: Variant) -> void:
	var surface_direction := Vector3(ocean_sample.surface_velocity.x, 0.0, ocean_sample.surface_velocity.y)
	if surface_direction.length_squared() > 0.001:
		_ride_direction = surface_direction.normalized()
	velocity = velocity.move_toward(_ride_direction * tuning.ride_min_speed, tuning.ride_acceleration * delta)
	if _state_elapsed >= tuning.pop_up_duration:
		_transition_to(State.RIDE)

func _step_ride(input: Variant, delta: float, ocean_sample: Variant) -> void:
	var raw_steer: float = input.steer
	var safe_steer := raw_steer if is_finite(raw_steer) else 0.0
	var turn: float = clampf(safe_steer, -1.0, 1.0) * tuning.carve_radians_per_second * delta
	_ride_direction = _ride_direction.rotated(Vector3.UP, turn).normalized()
	var target_speed := lerpf(tuning.ride_min_speed, tuning.ride_max_speed, ocean_sample.break_phase)
	velocity = velocity.move_toward(_ride_direction * target_speed, tuning.ride_acceleration * delta)

func _step_wipeout(_delta: float, ocean_sample: Variant) -> void:
	velocity *= 0.7
	position.y = ocean_sample.height - 0.8
	if _state_elapsed >= tuning.wipeout_duration:
		_transition_to(State.TREAD)

func _step_tread(input: Variant, delta: float, ocean_sample: Variant) -> void:
	velocity = velocity.move_toward(Vector3.ZERO, 1.5 * delta)
	position.y = ocean_sample.height - 0.2
	if input.recover:
		_transition_to(State.PADDLE)

func _transition_to(next_state: State) -> void:
	state = next_state
	_state_elapsed = 0.0
