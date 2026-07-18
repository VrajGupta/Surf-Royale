extends SceneTree

const LaunchConnection = preload("res://src/network/launch_connection.gd")

var _failures: Array[String] = []

func _initialize() -> void:
	var suites := OS.get_cmdline_user_args()
	var suite := suites[0] if not suites.is_empty() else "all"

	if suite in ["bootstrap", "all"]:
		_test_missing_server_times_out_at_five_seconds()
		_test_success_cancels_timeout()
		_test_late_failure_cannot_overwrite_success()

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
