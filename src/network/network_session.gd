class_name NetworkSession
extends Node

const OceanTruthType = preload("res://src/ocean/ocean_truth.gd")
const SurfControllerType = preload("res://src/surf/surf_controller.gd")
const SurfInputType = preload("res://src/surf/surf_input.gd")
const InputValidator = preload("res://src/network/network_input_validator.gd")
const CorrectionTrackerType = preload("res://src/network/correction_tracker.gd")
const ProjectileType = preload("res://src/gameplay/sidearm_projectile.gd")

const SERVER_PEER_ID := 1
const SERVER_OCEAN_SEED := 20260718
const ONE_WAY_DELAY_SECONDS := 0.05
const DROP_INTERVAL := 50

var _is_server := false
var _client_label := 0
var _duration_seconds := 5.0
var _result_path := ""
var _elapsed := 0.0
var _connected_elapsed := 0.0
var _physics_ticks := 0
var _sequence := 0
var _connected := false
var _finished := false
var _peer: ENetMultiplayerPeer

var _server_ocean: Variant
var _server_controllers: Dictionary = {}
var _server_inputs: Dictionary = {}
var _server_fire_latches: Dictionary = {}
var _server_player_hp: Dictionary = {}
var _server_board_hp: Dictionary = {}
var _server_projectiles: Array[Dictionary] = []
var _snapshot_queue: Array[Dictionary] = []
var _clients_seen_total := 0
var _server_fire_requests := 0
var _server_hits := 0
var _server_water_cutoffs := 0

var _client_controller: Variant
var _input_queue: Array[Dictionary] = []
var _corrections := CorrectionTrackerType.new()
var _snapshot_count := 0
var _false_state_transitions := 0
var _fire_sent := false

func start_server(port: int, duration_seconds: float, result_path: String) -> int:
	_is_server = true
	_duration_seconds = maxf(duration_seconds, 1.0)
	_result_path = result_path
	_server_ocean = OceanTruthType.new(SERVER_OCEAN_SEED)
	_peer = ENetMultiplayerPeer.new()
	var result := _peer.create_server(port, 8)
	if result != OK:
		push_error("Could not create ENet server: %s" % error_string(result))
		return result

	multiplayer.multiplayer_peer = _peer
	multiplayer.peer_connected.connect(_on_server_peer_connected)
	multiplayer.peer_disconnected.connect(_on_server_peer_disconnected)
	print("NETWORK_SERVER_READY port=%d" % port)
	return OK

func start_client(host: String, port: int, client_label: int, duration_seconds: float, result_path: String) -> int:
	_is_server = false
	_client_label = client_label
	_duration_seconds = maxf(duration_seconds, 1.0)
	_result_path = result_path
	_peer = ENetMultiplayerPeer.new()
	var result := _peer.create_client(host, port)
	if result != OK:
		push_error("Could not create ENet client: %s" % error_string(result))
		return result

	multiplayer.connected_to_server.connect(_on_client_connected)
	multiplayer.connection_failed.connect(_on_client_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.multiplayer_peer = _peer
	return OK

func _physics_process(delta: float) -> void:
	if _finished:
		return
	_elapsed += delta
	_physics_ticks += 1

	if _is_server:
		_server_tick(delta)
	else:
		_client_tick(delta)

func _server_tick(delta: float) -> void:
	for peer_id: int in _server_controllers:
		var controller: Variant = _server_controllers[peer_id]
		var input: Variant = _server_inputs.get(peer_id, SurfInputType.new())
		controller.step(input, delta, _elapsed)
	_tick_server_projectiles(delta)

	_sequence += 1
	for peer_id: int in _server_controllers:
		if not _should_drop(_sequence + peer_id):
			var controller: Variant = _server_controllers[peer_id]
			_snapshot_queue.append({
				"deliver_at": _elapsed + ONE_WAY_DELAY_SECONDS,
				"peer_id": peer_id,
				"sequence": _sequence,
				"position": controller.position,
				"velocity": controller.velocity,
				"state": int(controller.state),
				"stamina": controller.stamina,
			})
	_flush_snapshot_queue()

	if _elapsed >= _duration_seconds:
		_finish_server()

func _client_tick(delta: float) -> void:
	if not _connected:
		if _elapsed >= 5.0:
			_finish_client(false, "connection timeout")
		return

	_connected_elapsed += delta
	_sequence += 1
	var input := SurfInputType.new()
	input.paddle = true
	input.steer = sin(float(_sequence) * 0.025) * 0.25
	if not _fire_sent and _connected_elapsed >= 1.0:
		input.fire = true
		_fire_sent = true
	_client_controller.step(input, delta, _connected_elapsed)

	if not _should_drop(_sequence):
		_input_queue.append({
			"deliver_at": _elapsed + ONE_WAY_DELAY_SECONDS,
			"sequence": _sequence,
			"payload": {
				"steer": input.steer,
				"paddle": input.paddle,
				"duck_dive": false,
				"pop_up": false,
				"recover": false,
				"fire": input.fire,
			},
		})
	_flush_input_queue()

	if _connected_elapsed >= _duration_seconds:
		_finish_client(true)

func _flush_input_queue() -> void:
	var remaining: Array[Dictionary] = []
	for packet in _input_queue:
		if float(packet.deliver_at) <= _elapsed:
			submit_input.rpc_id(SERVER_PEER_ID, int(packet.sequence), packet.payload)
		else:
			remaining.append(packet)
	_input_queue = remaining

func _flush_snapshot_queue() -> void:
	var remaining: Array[Dictionary] = []
	for packet in _snapshot_queue:
		if float(packet.deliver_at) <= _elapsed:
			if _server_has_connected_peer(int(packet.peer_id)):
				receive_snapshot.rpc_id(
					int(packet.peer_id),
					int(packet.sequence),
					packet.position,
					packet.velocity,
					int(packet.state),
					float(packet.stamina)
				)
			continue
		remaining.append(packet)
	_snapshot_queue = remaining

func _server_has_connected_peer(peer_id: int) -> bool:
	if _peer == null:
		return false
	var packet_peer := _peer.get_peer(peer_id)
	return packet_peer != null and packet_peer.get_state() == ENetPacketPeer.STATE_CONNECTED

func _on_server_peer_connected(peer_id: int) -> void:
	_clients_seen_total += 1
	var controller := SurfControllerType.new(_server_ocean)
	controller.position = Vector3(float(_server_controllers.size()) * 2.0, 0.0, 0.0)
	_server_controllers[peer_id] = controller
	_server_inputs[peer_id] = SurfInputType.new()
	_server_fire_latches[peer_id] = false
	_server_player_hp[peer_id] = 100
	_server_board_hp[peer_id] = 100
	server_hello.rpc_id(peer_id, controller.position)

func _on_server_peer_disconnected(peer_id: int) -> void:
	_server_controllers.erase(peer_id)
	_server_inputs.erase(peer_id)
	_server_fire_latches.erase(peer_id)
	_snapshot_queue = _snapshot_queue.filter(
		func(packet: Dictionary) -> bool: return int(packet.peer_id) != peer_id
	)

func _on_client_connected() -> void:
	print("NETWORK_CLIENT_TRANSPORT_CONNECTED label=%d" % _client_label)

func _on_client_connection_failed() -> void:
	_finish_client(false, "transport connection failed")

func _on_server_disconnected() -> void:
	if not _finished:
		_finish_client(_snapshot_count >= 30, "server completed soak")

@rpc("authority", "call_remote", "reliable")
func server_hello(initial_position: Vector3) -> void:
	_client_controller = SurfControllerType.new(OceanTruthType.new(1000 + _client_label))
	_client_controller.position = initial_position
	_connected = true
	_connected_elapsed = 0.0
	print("NETWORK_CLIENT_READY label=%d" % _client_label)

@rpc("any_peer", "call_remote", "unreliable", 0)
func submit_input(sequence: int, payload: Variant) -> void:
	if not _is_server:
		return
	var sender := multiplayer.get_remote_sender_id()
	if not _server_controllers.has(sender) or sequence < 0:
		return
	var sanitized: Variant = InputValidator.sanitize(payload)
	var fire_was_pressed := bool(_server_fire_latches.get(sender, false))
	if sanitized.fire and not fire_was_pressed:
		_server_fire_requests += 1
		_spawn_server_projectile(sender)
	_server_fire_latches[sender] = sanitized.fire
	_server_inputs[sender] = sanitized

@rpc("authority", "call_remote", "unreliable", 1)
func receive_snapshot(
	_sequence_number: int,
	authoritative_position: Vector3,
	authoritative_velocity: Vector3,
	authoritative_state: int,
	authoritative_stamina: float
) -> void:
	if _is_server or not _connected or _client_controller == null:
		return
	if not _finite_vector(authoritative_position) or not _finite_vector(authoritative_velocity):
		_corrections.record(NAN)
		return
	if authoritative_state < 0 or authoritative_state > int(SurfControllerType.State.TREAD):
		return

	var horizontal_correction := Vector2(
		_client_controller.position.x - authoritative_position.x,
		_client_controller.position.z - authoritative_position.z
	).length()
	_corrections.record(horizontal_correction)
	_snapshot_count += 1

	var local_is_wipeout: bool = _client_controller.state == SurfControllerType.State.WIPEOUT
	var server_is_wipeout := authoritative_state == int(SurfControllerType.State.WIPEOUT)
	if local_is_wipeout != server_is_wipeout:
		_false_state_transitions += 1

	_client_controller.position = authoritative_position
	_client_controller.velocity = authoritative_velocity
	_client_controller.state = authoritative_state as SurfControllerType.State
	_client_controller.stamina = clampf(authoritative_stamina, 0.0, 100.0)

func _spawn_server_projectile(shooter_peer_id: int) -> void:
	var target_peer_id := -1
	for peer_id: int in _server_controllers:
		if peer_id != shooter_peer_id:
			target_peer_id = peer_id
			break
	if target_peer_id == -1:
		return

	var shooter: Variant = _server_controllers[shooter_peer_id]
	var target: Variant = _server_controllers[target_peer_id]
	var start: Vector3 = shooter.position + Vector3(0.0, 5.0, 0.0)
	var target_point: Vector3 = target.position + Vector3(0.0, 5.0, 0.0)
	var direction := start.direction_to(target_point)
	if not direction.is_finite() or direction.length_squared() <= 0.0:
		return
	_server_projectiles.append({
		"model": ProjectileType.new(start, direction * 30.0),
		"shooter": shooter_peer_id,
		"target": target_peer_id,
	})

func _tick_server_projectiles(delta: float) -> void:
	var active: Array[Dictionary] = []
	for entry in _server_projectiles:
		var projectile: Variant = entry.model
		projectile.step(delta, _server_ocean, _elapsed)
		var target_peer_id := int(entry.target)
		if projectile.alive and _server_controllers.has(target_peer_id):
			var target: Variant = _server_controllers[target_peer_id]
			var target_point: Vector3 = target.position + Vector3(0.0, 5.0, 0.0)
			if projectile.position.distance_to(target_point) <= 1.1:
				projectile.alive = false
				_server_hits += 1
				_server_player_hp[target_peer_id] = maxi(int(_server_player_hp[target_peer_id]) - 10, 0)
				_server_board_hp[target_peer_id] = maxi(int(_server_board_hp[target_peer_id]) - 5, 0)
		if projectile.water_cutoff:
			_server_water_cutoffs += 1
		if projectile.alive:
			active.append(entry)
	_server_projectiles = active

func _minimum_stat(values: Dictionary) -> int:
	var minimum := 100
	for value: int in values.values():
		minimum = mini(minimum, value)
	return minimum

func _finish_server() -> void:
	_finished = true
	var expected_ticks := _elapsed * float(Engine.physics_ticks_per_second)
	var missed_ticks := maxf(expected_ticks - float(_physics_ticks), 0.0)
	var missed_tick_rate := missed_ticks / maxf(expected_ticks, 1.0)
	var minimum_player_hp := _minimum_stat(_server_player_hp)
	var minimum_board_hp := _minimum_stat(_server_board_hp)
	var passed := (
		missed_tick_rate < 0.01
		and _server_fire_requests >= 2
		and _server_hits >= 1
		and minimum_player_hp < 100
		and minimum_board_hp < 100
	)
	_write_result({
		"mode": "server",
		"ticks": _physics_ticks,
		"elapsed": _elapsed,
		"missed_tick_rate": missed_tick_rate,
		"clients_seen": _clients_seen_total,
		"sidearm_fire_requests": _server_fire_requests,
		"sidearm_hits": _server_hits,
		"water_cutoffs": _server_water_cutoffs,
		"minimum_player_hp": minimum_player_hp,
		"minimum_board_hp": minimum_board_hp,
		"passed": passed,
	})
	print("NETWORK_SERVER_%s clients=%d hits=%d missed_tick_rate=%.5f" % ["OK" if passed else "FAILED", _clients_seen_total, _server_hits, missed_tick_rate])
	get_tree().quit(0 if passed else 1)

func _finish_client(success: bool, reason: String = "") -> void:
	_finished = true
	var correction_p95 := _corrections.p95()
	var passed := success and _snapshot_count >= 30 and correction_p95 <= 0.5 and _false_state_transitions == 0 and _corrections.invalid_samples == 0
	_write_result({
		"mode": "client",
		"label": _client_label,
		"connected": _connected,
		"snapshots": _snapshot_count,
		"p95_correction_m": correction_p95,
		"false_state_transitions": _false_state_transitions,
		"invalid_snapshots": _corrections.invalid_samples,
		"reason": reason,
		"passed": passed,
	})
	if passed:
		print("NETWORK_CLIENT_OK label=%d snapshots=%d p95=%.4f" % [_client_label, _snapshot_count, correction_p95])
	else:
		push_error("Network client failed: label=%d reason=%s snapshots=%d p95=%.4f false_states=%d invalid=%d" % [
			_client_label,
			reason,
			_snapshot_count,
			correction_p95,
			_false_state_transitions,
			_corrections.invalid_samples,
		])
	get_tree().quit(0 if passed else 1)

func _write_result(data: Dictionary) -> void:
	if _result_path.is_empty():
		return
	var absolute_path := ProjectSettings.globalize_path(_result_path)
	DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
	var file := FileAccess.open(absolute_path, FileAccess.WRITE)
	if file == null:
		push_error("Could not write network result: %s" % absolute_path)
		return
	file.store_string(JSON.stringify(data, "\t"))

func _should_drop(packet_sequence: int) -> bool:
	return packet_sequence > 0 and packet_sequence % DROP_INTERVAL == 0

func _finite_vector(value: Vector3) -> bool:
	return is_finite(value.x) and is_finite(value.y) and is_finite(value.z)
