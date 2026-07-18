extends SceneTree

const LaunchConnection = preload("res://src/network/launch_connection.gd")
const OceanTruth = preload("res://src/ocean/ocean_truth.gd")

var _failures: Array[String] = []

func _initialize() -> void:
	var suites := OS.get_cmdline_user_args()
	var suite := suites[0] if not suites.is_empty() else "all"

	if suite in ["bootstrap", "all"]:
		_test_missing_server_times_out_at_five_seconds()
		_test_success_cancels_timeout()
		_test_late_failure_cannot_overwrite_success()

	if suite in ["ocean", "all"]:
		_test_ocean_schedules_exactly_three_repeatable_waves()
		_test_ocean_seed_changes_schedule()
		_test_wave_schedule_copy_cannot_mutate_server_truth()
		_test_ocean_sample_is_finite_and_normalized()
		_test_underwater_uses_authoritative_surface_height()
		_test_ocean_cpu_query_budget()

	call_deferred("_finish")

func _test_missing_server_times_out_at_five_seconds() -> void:
	var connection := LaunchConnection.new(5.0)
	connection.begin()
	connection.advance(4.99)
	_expect_equal(connection.state, LaunchConnection.State.CONNECTING, "connection remains pending before deadline")
	connection.advance(0.01)
	_expect_equal(connection.state, LaunchConnection.State.FAILED, "connection fails at deadline")
	_expect_equal(connection.message, "Server unavailable. Check the address and try again.", "failure is actionable")

func _test_success_cancels_timeout() -> void:
	var connection := LaunchConnection.new(5.0)
	connection.begin()
	connection.advance(2.0)
	connection.succeed()
	connection.advance(10.0)
	_expect_equal(connection.state, LaunchConnection.State.CONNECTED, "connected state is stable")

func _test_late_failure_cannot_overwrite_success() -> void:
	var connection := LaunchConnection.new(5.0)
	connection.begin()
	connection.succeed()
	connection.fail("late disconnect callback")
	_expect_equal(connection.state, LaunchConnection.State.CONNECTED, "late failure does not race a successful connection")

func _test_ocean_schedules_exactly_three_repeatable_waves() -> void:
	var first := OceanTruth.new(20260718)
	var second := OceanTruth.new(20260718)
	var starts := first.wave_starts()
	_expect_equal(starts.size(), 3, "one prototype set contains exactly three waves")
	_expect_equal(starts, second.wave_starts(), "same seed reproduces the schedule")
	_expect_true(starts[0] < starts[1] and starts[1] < starts[2], "wave starts are ordered")

func _test_ocean_seed_changes_schedule() -> void:
	var first := OceanTruth.new(20260718)
	var second := OceanTruth.new(20260719)
	_expect_true(first.wave_starts() != second.wave_starts(), "different seeds change the schedule")

func _test_wave_schedule_copy_cannot_mutate_server_truth() -> void:
	var ocean := OceanTruth.new(9)
	var exposed_starts := ocean.wave_starts()
	exposed_starts[0] = -999.0
	_expect_true(ocean.wave_starts()[0] >= 7.0, "callers cannot mutate the server schedule")

func _test_ocean_sample_is_finite_and_normalized() -> void:
	var ocean: Variant = OceanTruth.new(42)
	var sample = ocean.sample(Vector2(12.0, -8.0), 15.0)
	_expect_true(is_finite(sample.height), "height is finite")
	_expect_true(is_finite(sample.surface_velocity.x) and is_finite(sample.surface_velocity.y), "surface velocity is finite")
	_expect_near(sample.normal.length(), 1.0, 0.001, "surface normal is normalized")
	_expect_true(sample.break_phase >= 0.0 and sample.break_phase <= 1.0, "break phase is bounded")

func _test_underwater_uses_authoritative_surface_height() -> void:
	var ocean: Variant = OceanTruth.new(42)
	var position := Vector2(3.0, -5.0)
	var sample = ocean.sample(position, 10.0)
	_expect_true(ocean.is_underwater(sample.height - 0.1, position, 10.0), "point below the surface is underwater")
	_expect_true(not ocean.is_underwater(sample.height + 0.1, position, 10.0), "point above the surface is not underwater")

func _test_ocean_cpu_query_budget() -> void:
	var ocean: Variant = OceanTruth.new(42)
	var started := Time.get_ticks_usec()
	for index in 10_000:
		ocean.sample(Vector2(float(index % 100), float(index / 100)), float(index) * 0.01)
	var elapsed_ms := float(Time.get_ticks_usec() - started) / 1000.0
	_expect_true(elapsed_ms <= 500.0, "10k headless ocean queries stay under the M4 budget (%.2f ms)" % elapsed_ms)

func _expect_true(condition: bool, label: String) -> void:
	if not condition:
		_failures.append("%s: expected true" % label)

func _expect_near(actual: float, expected: float, tolerance: float, label: String) -> void:
	if absf(actual - expected) > tolerance:
		_failures.append("%s: expected %.4f ± %.4f, got %.4f" % [label, expected, tolerance, actual])

func _expect_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		_failures.append("%s: expected %s, got %s" % [label, expected, actual])

func _finish() -> void:
	if _failures.is_empty():
		print("TESTS_OK")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)
