class_name FrameMetrics
extends RefCounted

var _start_memory_bytes: int
var _end_memory_bytes: int
var _frame_seconds: Array[float] = []

func _init(start_memory_bytes: int) -> void:
	_start_memory_bytes = max(start_memory_bytes, 0)
	_end_memory_bytes = _start_memory_bytes

func record(frame_seconds: float) -> bool:
	if not is_finite(frame_seconds) or frame_seconds < 0.0:
		return false
	_frame_seconds.append(frame_seconds)
	return true

func finish(end_memory_bytes: int) -> void:
	_end_memory_bytes = max(end_memory_bytes, 0)

func p95_ms() -> float:
	if _frame_seconds.is_empty():
		return 0.0
	var ordered := _frame_seconds.duplicate()
	ordered.sort()
	var index := clampi(ceili(0.95 * float(ordered.size())) - 1, 0, ordered.size() - 1)
	return ordered[index] * 1000.0

func memory_growth_bytes() -> int:
	return maxi(_end_memory_bytes - _start_memory_bytes, 0)

func sample_count() -> int:
	return _frame_seconds.size()
