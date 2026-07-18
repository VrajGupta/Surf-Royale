class_name OceanTruth
extends RefCounted

const OceanSampleType = preload("res://src/ocean/ocean_sample.gd")
const WAVE_COUNT := 3
const REEF_BREAK_Z := -12.0
const REEF_INFLUENCE_METERS := 8.0
const SET_PERIOD_SECONDS := 75.0

var _seed: int
var _waves: Array[Dictionary] = []
var _base_current := Vector2.ZERO

func _init(seed: int) -> void:
	_seed = seed
	_build_wave_set()

func wave_starts() -> Array[float]:
	var starts: Array[float] = []
	for wave in _waves:
		starts.append(wave.start)
	return starts

func sample(position: Vector2, time_seconds: float) -> OceanSample:
	var height := 0.0
	var slope := Vector2.ZERO
	var surface_velocity := Vector2.ZERO

	for wave in _waves:
		var raw_elapsed := time_seconds - float(wave.start)
		var elapsed := fposmod(raw_elapsed + SET_PERIOD_SECONDS * 0.5, SET_PERIOD_SECONDS) - SET_PERIOD_SECONDS * 0.5
		var envelope := exp(-pow((elapsed - 7.0) / 8.0, 2.0))
		var direction: Vector2 = wave.direction
		var wave_number: float = TAU / float(wave.wavelength)
		var angular_speed := wave_number * float(wave.speed)
		var phase := wave_number * position.dot(direction) - angular_speed * elapsed
		var amplitude: float = wave.amplitude * envelope
		var sine := sin(phase)
		var cosine := cos(phase)

		height += amplitude * sine
		slope += direction * (amplitude * wave_number * cosine)
		surface_velocity += direction * (amplitude * angular_speed * cosine)

	var normal := Vector3(-slope.x, 1.0, -slope.y).normalized()
	var reef_proximity := 1.0 - clampf(absf(position.y - REEF_BREAK_Z) / REEF_INFLUENCE_METERS, 0.0, 1.0)
	var crest_strength := clampf((height + 1.5) / 3.0, 0.0, 1.0)
	var break_phase := reef_proximity * crest_strength
	var current := _base_current + Vector2(0.0, -0.35 * reef_proximity)

	return OceanSampleType.new(height, normal, surface_velocity, current, break_phase)

func is_underwater(world_y: float, position: Vector2, time_seconds: float) -> bool:
	return world_y < sample(position, time_seconds).height

func _build_wave_set() -> void:
	var random := RandomNumberGenerator.new()
	random.seed = _seed
	var next_start := 7.0 + random.randf_range(0.0, 2.0)

	for index in WAVE_COUNT:
		var angle := random.randf_range(-0.16, 0.16)
		var direction := Vector2(sin(angle), cos(angle)).normalized()
		_waves.append({
			"start": next_start,
			"amplitude": random.randf_range(0.8, 1.35),
			"wavelength": random.randf_range(20.0, 28.0),
			"speed": random.randf_range(6.0, 9.0),
			"direction": direction,
		})
		next_start += random.randf_range(5.0, 6.5)

	var current_angle := random.randf_range(-0.35, 0.35)
	_base_current = Vector2(sin(current_angle), cos(current_angle)).normalized() * random.randf_range(0.15, 0.35)
