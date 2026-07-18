extends SceneTree

const LaunchConnection = preload("res://src/network/launch_connection.gd")
const OceanTruth = preload("res://src/ocean/ocean_truth.gd")
const SurfController = preload("res://src/surf/surf_controller.gd")
const SurfInput = preload("res://src/surf/surf_input.gd")
const NetworkInputValidator = preload("res://src/network/network_input_validator.gd")
const CorrectionTracker = preload("res://src/network/correction_tracker.gd")

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

	if suite in ["surf", "all"]:
		_test_paddling_builds_speed_over_strokes()
		_test_duck_dive_spends_stamina_and_returns_to_paddle()
		_test_pop_up_requires_a_catchable_wave()
		_test_catch_ride_wipeout_tread_and_recover_flow()
		_test_non_finite_steer_cannot_poison_motion()

	if suite in ["network", "all"]:
		_test_server_sanitizes_client_input_and_ignores_claims()
		_test_server_rejects_non_finite_steer()
		_test_correction_tracker_reports_nearest_rank_p95()
		_test_correction_tracker_rejects_non_finite_samples()

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

func _test_paddling_builds_speed_over_strokes() -> void:
	var controller := SurfController.new(OceanTruth.new(42))
	var paddle := SurfInput.new()
	paddle.paddle = true
	controller.step(paddle, 0.4, 0.0)
	var first_stroke_speed := controller.horizontal_speed()
	for index in 4:
		controller.step(paddle, 0.4, float(index + 1) * 0.4)
	_expect_true(controller.horizontal_speed() > first_stroke_speed, "paddle speed builds over strokes")
	_expect_true(controller.horizontal_speed() <= 1.2, "paddle speed remains within the GDD envelope")

func _test_duck_dive_spends_stamina_and_returns_to_paddle() -> void:
	var controller := SurfController.new(OceanTruth.new(42))
	var duck := SurfInput.new()
	duck.duck_dive = true
	var starting_stamina := controller.stamina
	controller.step(duck, 0.01, 0.0)
	_expect_equal(controller.state, SurfController.State.DUCK_DIVE, "duck dive starts from paddling")
	_expect_true(controller.stamina < starting_stamina, "duck dive spends stamina")
	controller.step(SurfInput.new(), 1.0, 1.0)
	_expect_equal(controller.state, SurfController.State.PADDLE, "duck dive returns to paddling")

func _test_pop_up_requires_a_catchable_wave() -> void:
	var controller := SurfController.new(OceanTruth.new(42))
	controller.position = Vector3(0.0, 0.0, 50.0)
	var pop_up := SurfInput.new()
	pop_up.pop_up = true
	controller.step(pop_up, 0.016, 10.0)
	_expect_equal(controller.state, SurfController.State.PADDLE, "pop-up is rejected away from a breaking wave")

func _test_catch_ride_wipeout_tread_and_recover_flow() -> void:
	var ocean := OceanTruth.new(42)
	var controller := SurfController.new(ocean)
	controller.position = Vector3(0.0, 0.0, -12.0)
	var catch_time := _find_catchable_time(ocean, Vector2(0.0, -12.0))
	_expect_true(catch_time >= 0.0, "test seed produces a catchable wave")

	var pop_up := SurfInput.new()
	pop_up.pop_up = true
	controller.step(pop_up, 0.016, catch_time)
	_expect_equal(controller.state, SurfController.State.POP_UP, "catchable wave starts pop-up")
	controller.step(SurfInput.new(), 0.8, catch_time + 0.8)
	_expect_equal(controller.state, SurfController.State.RIDE, "committed pop-up becomes a ride")

	controller.apply_impact(12.0)
	_expect_equal(controller.state, SurfController.State.WIPEOUT, "heavy impact causes wipeout")
	controller.step(SurfInput.new(), 1.2, catch_time + 2.0)
	_expect_equal(controller.state, SurfController.State.TREAD, "wipeout resolves to treading")

	var recover := SurfInput.new()
	recover.recover = true
	controller.step(recover, 0.016, catch_time + 2.1)
	_expect_equal(controller.state, SurfController.State.PADDLE, "board recovery returns to paddling")

func _test_non_finite_steer_cannot_poison_motion() -> void:
	var ocean := OceanTruth.new(42)
	var controller := SurfController.new(ocean)
	controller.position = Vector3(0.0, 0.0, -12.0)
	var catch_time := _find_catchable_time(ocean, Vector2(0.0, -12.0))
	var pop_up := SurfInput.new()
	pop_up.pop_up = true
	controller.step(pop_up, 0.016, catch_time)
	controller.step(SurfInput.new(), 0.8, catch_time + 0.8)
	var speed_before_malformed_input := controller.horizontal_speed()
	var malformed := SurfInput.new()
	malformed.steer = NAN
	controller.step(malformed, 0.016, catch_time + 1.0)
	_expect_true(is_finite(controller.velocity.x) and is_finite(controller.velocity.z), "non-finite steer is rejected")
	_expect_true(controller.horizontal_speed() >= speed_before_malformed_input, "malformed steer cannot erase ride momentum")

func _test_server_sanitizes_client_input_and_ignores_claims() -> void:
	var sanitized = NetworkInputValidator.sanitize({
		"steer": 8.0,
		"paddle": true,
		"duck_dive": false,
		"pop_up": false,
		"recover": false,
		"position": Vector3(999.0, 999.0, 999.0),
		"damage": 999,
	})
	_expect_near(sanitized.steer, 1.0, 0.0001, "server clamps steering intent")
	_expect_true(sanitized.paddle, "server accepts boolean paddle intent")
	_expect_equal(sanitized.get_property_list().any(func(property: Dictionary) -> bool: return property.name == "position"), false, "sanitized input has no position claim")

func _test_server_rejects_non_finite_steer() -> void:
	var sanitized = NetworkInputValidator.sanitize({"steer": NAN, "paddle": true})
	_expect_near(sanitized.steer, 0.0, 0.0001, "non-finite steer becomes neutral")

func _test_correction_tracker_reports_nearest_rank_p95() -> void:
	var tracker := CorrectionTracker.new()
	tracker.record(0.1)
	tracker.record(0.2)
	tracker.record(0.6)
	_expect_near(tracker.p95(), 0.6, 0.0001, "p95 uses nearest-rank behavior")

func _test_correction_tracker_rejects_non_finite_samples() -> void:
	var tracker := CorrectionTracker.new()
	_expect_true(not tracker.record(NAN), "non-finite correction is rejected")
	_expect_equal(tracker.invalid_samples, 1, "invalid correction is counted")

func _find_catchable_time(ocean: Variant, position: Vector2) -> float:
	for index in 800:
		var time_seconds := float(index) * 0.05
		if ocean.sample(position, time_seconds).break_phase >= 0.2:
			return time_seconds
	return -1.0

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
