extends Control

signal local_slice_requested

const SERVER_PORT := 7000

@onready var _address: LineEdit = %Address
@onready var _local_slice_button: Button = %LocalSliceButton
@onready var _connect_button: Button = %ConnectButton
@onready var _status: Label = %Status

var _connection := LaunchConnection.new(5.0)
var _peer: ENetMultiplayerPeer

func _ready() -> void:
	_local_slice_button.pressed.connect(local_slice_requested.emit)
	_connect_button.pressed.connect(_connect)
	_status.text = _connection.message

func _process(delta: float) -> void:
	if _connection.state != LaunchConnection.State.CONNECTING:
		return

	if is_instance_valid(_peer) and _peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		_connection.succeed()
	else:
		_connection.advance(delta)

	_status.text = _connection.message
	if _connection.state == LaunchConnection.State.FAILED:
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
		_connect_button.disabled = false

func _connect() -> void:
	_connection.begin()
	_status.text = _connection.message
	_connect_button.disabled = true

	_peer = ENetMultiplayerPeer.new()
	var result := _peer.create_client(_address.text.strip_edges(), SERVER_PORT)
	if result != OK:
		_connection.fail("Could not start the connection: %s" % error_string(result))
		_status.text = _connection.message
		_connect_button.disabled = false
		return

	multiplayer.multiplayer_peer = _peer
