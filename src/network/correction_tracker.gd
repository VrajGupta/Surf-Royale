class_name CorrectionTracker
extends RefCounted

var invalid_samples := 0
var _samples: Array[float] = []

func record(distance_meters: float) -> bool:
	if not is_finite(distance_meters) or distance_meters < 0.0:
		invalid_samples += 1
		return false
	_samples.append(distance_meters)
	return true

func p95() -> float:
	if _samples.is_empty():
		return 0.0
	var ordered := _samples.duplicate()
	ordered.sort()
	var index := clampi(ceili(0.95 * float(ordered.size())) - 1, 0, ordered.size() - 1)
	return ordered[index]

func sample_count() -> int:
	return _samples.size()
