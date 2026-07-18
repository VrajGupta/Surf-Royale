extends Node

const LAUNCH_SCREEN := preload("res://src/app/launch_screen.tscn")
const NETWORK_SESSION := preload("res://src/network/network_session.gd")
const TUTORIAL_COVE := preload("res://src/world/tutorial_cove.tscn")

var _server_smoke_seconds := -1.0
var _smoke_elapsed := 0.0
var _smoke_ticks := 0

func _ready() -> void:
	_server_smoke_seconds = _read_server_smoke_duration()
	if _server_smoke_seconds >= 0.0:
		print("SERVER_SMOKE_START tick_rate=%d" % Engine.physics_ticks_per_second)
		return

	var arguments := _argument_map()
	if arguments.has("server"):
		_start_network_server(arguments)
		return
	if arguments.has("client"):
		_start_network_client(arguments)
		return
	if arguments.has("slice-benchmark") or arguments.has("slice-smoke"):
		_start_tutorial_cove(arguments)
		return

	var launch_screen := LAUNCH_SCREEN.instantiate()
	launch_screen.local_slice_requested.connect(_open_local_tutorial_cove.bind(launch_screen))
	add_child(launch_screen)

func _physics_process(delta: float) -> void:
	if _server_smoke_seconds < 0.0:
		return

	_smoke_ticks += 1
	_smoke_elapsed += delta
	if _smoke_elapsed < _server_smoke_seconds:
		return

	var expected_ticks := _server_smoke_seconds * float(Engine.physics_ticks_per_second)
	var within_tolerance := absf(float(_smoke_ticks) - expected_ticks) <= 2.0
	if within_tolerance:
		print("SERVER_SMOKE_OK ticks=%d elapsed=%.3f" % [_smoke_ticks, _smoke_elapsed])
		get_tree().quit(0)
	else:
		push_error("Server tick cadence outside tolerance: ticks=%d expected=%.1f" % [_smoke_ticks, expected_ticks])
		get_tree().quit(1)

func _open_local_tutorial_cove(launch_screen: Control) -> void:
	launch_screen.queue_free()
	_start_tutorial_cove({})

func _start_tutorial_cove(arguments: Dictionary) -> void:
	var cove := TUTORIAL_COVE.instantiate()
	cove.benchmark_duration_seconds = -1.0
	if arguments.has("slice-benchmark"):
		cove.benchmark_duration_seconds = float(arguments.get("slice-benchmark", "300.0"))
	elif arguments.has("slice-smoke"):
		cove.benchmark_duration_seconds = float(arguments.get("slice-smoke", "3.0"))
	cove.benchmark_requires_frame_budget = arguments.has("slice-benchmark")
	cove.benchmark_result_path = String(arguments.get("result", ""))
	cove.benchmark_screenshot_path = String(arguments.get("screenshot", ""))
	add_child(cove)

func _start_network_server(arguments: Dictionary) -> void:
	var session := NETWORK_SESSION.new()
	session.name = "NetworkSession"
	add_child(session)
	var result: int = session.start_server(
		int(arguments.get("port", "7000")),
		float(arguments.get("duration", "7.0")),
		String(arguments.get("result", ""))
	)
	if result != OK:
		get_tree().quit(1)

func _start_network_client(arguments: Dictionary) -> void:
	var session := NETWORK_SESSION.new()
	session.name = "NetworkSession"
	add_child(session)
	var result: int = session.start_client(
		String(arguments.get("host", "127.0.0.1")),
		int(arguments.get("port", "7000")),
		int(arguments.get("client", "0")),
		float(arguments.get("duration", "4.0")),
		String(arguments.get("result", ""))
	)
	if result != OK:
		get_tree().quit(1)

func _argument_map() -> Dictionary:
	var result := {}
	for argument in OS.get_cmdline_user_args():
		var normalized := argument.trim_prefix("--")
		var separator := normalized.find("=")
		if separator == -1:
			result[normalized] = true
		else:
			result[normalized.left(separator)] = normalized.substr(separator + 1)
	return result

func _read_server_smoke_duration() -> float:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--server-smoke="):
			return maxf(argument.trim_prefix("--server-smoke=").to_float(), 0.05)
	return -1.0
