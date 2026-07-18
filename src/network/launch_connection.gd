class_name LaunchConnection
extends RefCounted

enum State {
	IDLE,
	CONNECTING,
	CONNECTED,
	FAILED,
}

const UNAVAILABLE_MESSAGE := "Server unavailable. Check the address and try again."

var state: State = State.IDLE
var message := "Ready"
var _timeout_seconds: float
var _elapsed_seconds := 0.0

func _init(timeout_seconds: float = 5.0) -> void:
	_timeout_seconds = maxf(timeout_seconds, 0.001)

func begin() -> void:
	_elapsed_seconds = 0.0
	state = State.CONNECTING
	message = "Connecting…"

func advance(delta_seconds: float) -> void:
	if state != State.CONNECTING:
		return

	_elapsed_seconds += maxf(delta_seconds, 0.0)
	if _elapsed_seconds >= _timeout_seconds:
		fail(UNAVAILABLE_MESSAGE)

func succeed() -> void:
	if state != State.CONNECTING:
		return
	state = State.CONNECTED
	message = "Connected"

func fail(reason: String = UNAVAILABLE_MESSAGE) -> void:
	if state != State.CONNECTING:
		return
	state = State.FAILED
	message = reason
