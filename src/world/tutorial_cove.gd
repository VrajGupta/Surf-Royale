class_name TutorialCove
extends Node3D

const OceanTruthType = preload("res://src/ocean/ocean_truth.gd")
const SurfControllerType = preload("res://src/surf/surf_controller.gd")
const SurfInputType = preload("res://src/surf/surf_input.gd")
const ProjectileType = preload("res://src/gameplay/sidearm_projectile.gd")
const FrameMetricsType = preload("res://src/telemetry/frame_metrics.gd")

const SET_PERIOD_SECONDS := 75.0
const FIRE_COOLDOWN_SECONDS := 0.35
const WATER_COLOR := Color(0.035, 0.42, 0.52, 1.0)
const STORM_COLOR := Color(0.08, 0.18, 0.23, 1.0)
const CUE_COLOR := Color(0.1, 0.78, 0.85, 1.0)
const REEF_COLOR := Color(0.28, 0.24, 0.18, 1.0)
const BOARD_COLOR := Color(0.95, 0.38, 0.18, 1.0)

var benchmark_duration_seconds := -1.0
var benchmark_result_path := ""
var benchmark_screenshot_path := ""
var benchmark_requires_frame_budget := false

var _ocean := OceanTruthType.new(20260718)
var _controller := SurfControllerType.new(_ocean)
var _metrics: Variant
var _elapsed := 0.0
var _benchmark_elapsed := 0.0
var _fire_cooldown := 0.0
var _cue_played_for_wave := -1
var _hits := 0
var _finished := false
var _screenshot_saved := false

var _board: MeshInstance3D
var _surfer: MeshInstance3D
var _camera: Camera3D
var _ocean_mesh: MeshInstance3D
var _status_label: Label
var _wave_label: Label
var _controls_label: Label
var _audio_player: AudioStreamPlayer
var _wave_meshes: Array[MeshInstance3D] = []
var _projectiles: Array[Dictionary] = []

func _ready() -> void:
	_controller.position = Vector3(0.0, 0.0, -12.0)
	_build_world()
	_build_hud()
	_build_audio_cue()
	_update_player_visuals()
	_metrics = FrameMetricsType.new(OS.get_static_memory_usage())
	if benchmark_duration_seconds > 0.0:
		Engine.max_fps = 60

func _process(delta: float) -> void:
	if _finished:
		return
	_elapsed += delta
	if benchmark_duration_seconds > 0.0:
		_benchmark_elapsed += delta
		var screenshot_time := minf(8.0, benchmark_duration_seconds * 0.5)
		if not _screenshot_saved and _benchmark_elapsed >= screenshot_time:
			_capture_screenshot()
		if _benchmark_elapsed >= 2.0:
			_metrics.record(delta)
		if _benchmark_elapsed >= benchmark_duration_seconds:
			_finish_benchmark()

func _physics_process(delta: float) -> void:
	if _finished:
		return
	_fire_cooldown = maxf(_fire_cooldown - delta, 0.0)
	var input := _benchmark_input() if benchmark_duration_seconds > 0.0 else _player_input()
	_controller.step(input, delta, _elapsed)
	_update_player_visuals()
	_update_wave_cues()
	_update_projectiles(delta)

	if benchmark_duration_seconds > 0.0 and _fire_cooldown <= 0.0 and fmod(_elapsed, 2.0) < delta:
		_fire_sidearm(false)
	elif benchmark_duration_seconds <= 0.0 and (Input.is_key_pressed(KEY_F) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		_fire_sidearm(false)

func _build_world() -> void:
	var sunlight := DirectionalLight3D.new()
	sunlight.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	sunlight.light_energy = 1.15
	sunlight.shadow_enabled = true
	add_child(sunlight)

	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.62, 0.78, 0.84, 1.0)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.55, 0.68, 0.72, 1.0)
	environment.ambient_light_energy = 0.75
	world_environment.environment = environment
	add_child(world_environment)

	_ocean_mesh = MeshInstance3D.new()
	var ocean_plane := PlaneMesh.new()
	ocean_plane.size = Vector2(160.0, 160.0)
	ocean_plane.subdivide_width = 20
	ocean_plane.subdivide_depth = 20
	ocean_plane.material = _material(WATER_COLOR, 0.2, 0.15)
	_ocean_mesh.mesh = ocean_plane
	add_child(_ocean_mesh)

	for index in 7:
		var reef := MeshInstance3D.new()
		var reef_mesh := BoxMesh.new()
		reef_mesh.size = Vector3(8.0, 1.5 + float(index % 3), 4.0)
		reef_mesh.material = _material(REEF_COLOR, 0.95)
		reef.mesh = reef_mesh
		reef.position = Vector3(-24.0 + float(index) * 8.0, -1.5, -12.0 + sin(float(index)) * 2.0)
		add_child(reef)

	for index in 3:
		var cue := MeshInstance3D.new()
		var cue_mesh := BoxMesh.new()
		cue_mesh.size = Vector3(72.0, 0.18, 0.75)
		var cue_material := _material(CUE_COLOR, 0.3)
		cue_material.emission_enabled = true
		cue_material.emission = CUE_COLOR * 0.45
		cue_mesh.material = cue_material
		cue.mesh = cue_mesh
		cue.position = Vector3(0.0, 0.12, 55.0 + float(index) * 7.0)
		add_child(cue)
		_wave_meshes.append(cue)

	_board = MeshInstance3D.new()
	var board_mesh := BoxMesh.new()
	board_mesh.size = Vector3(0.75, 0.12, 2.4)
	board_mesh.material = _material(BOARD_COLOR, 0.35)
	_board.mesh = board_mesh
	add_child(_board)

	_surfer = MeshInstance3D.new()
	var surfer_mesh := CapsuleMesh.new()
	surfer_mesh.radius = 0.28
	surfer_mesh.height = 1.35
	surfer_mesh.material = _material(Color(0.08, 0.1, 0.12, 1.0), 0.75)
	_surfer.mesh = surfer_mesh
	add_child(_surfer)

	var target := MeshInstance3D.new()
	var target_mesh := SphereMesh.new()
	target_mesh.radius = 0.7
	target_mesh.height = 1.4
	target_mesh.material = _material(Color(0.95, 0.72, 0.12, 1.0), 0.45)
	target.mesh = target_mesh
	target.position = Vector3(0.0, 1.0, 24.0)
	target.name = "TargetBuoy"
	add_child(target)

	_camera = Camera3D.new()
	_camera.position = Vector3(0.0, 10.0, -26.0)
	_camera.current = true
	add_child(_camera)

func _build_hud() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var panel := PanelContainer.new()
	panel.position = Vector2(24.0, 24.0)
	panel.custom_minimum_size = Vector2(420.0, 0.0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.02, 0.055, 0.075, 0.94)
	panel_style.border_color = Color(0.16, 0.66, 0.72, 1.0)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", panel_style)
	canvas.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	panel.add_child(content)

	var title := Label.new()
	title.text = "SURF ROYALE — TUTORIAL COVE"
	title.add_theme_color_override("font_color", Color(0.94, 0.98, 1.0, 1.0))
	title.add_theme_font_size_override("font_size", 20)
	content.add_child(title)

	_status_label = Label.new()
	_status_label.add_theme_color_override("font_color", Color.WHITE)
	content.add_child(_status_label)

	_wave_label = Label.new()
	_wave_label.add_theme_color_override("font_color", CUE_COLOR)
	content.add_child(_wave_label)

	_controls_label = Label.new()
	_controls_label.text = "SPACE paddle  •  CTRL duck-dive  •  SHIFT pop-up  •  A/D carve  •  R recover  •  F fire"
	_controls_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_controls_label.add_theme_color_override("font_color", Color(0.82, 0.88, 0.9, 1.0))
	content.add_child(_controls_label)

func _build_audio_cue() -> void:
	_audio_player = AudioStreamPlayer.new()
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = 22_050.0
	generator.buffer_length = 0.25
	_audio_player.stream = generator
	add_child(_audio_player)

func _player_input() -> RefCounted:
	var input := SurfInputType.new()
	input.steer = float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A))
	input.paddle = Input.is_key_pressed(KEY_SPACE)
	input.duck_dive = Input.is_key_pressed(KEY_CTRL)
	input.pop_up = Input.is_key_pressed(KEY_SHIFT)
	input.recover = Input.is_key_pressed(KEY_R)
	return input

func _benchmark_input() -> RefCounted:
	var input := SurfInputType.new()
	input.paddle = fmod(_elapsed, 0.7) < 0.12
	input.steer = sin(_elapsed * 0.45) * 0.35
	var sample = _ocean.sample(Vector2(_controller.position.x, _controller.position.z), _elapsed)
	input.pop_up = _controller.state == SurfControllerType.State.PADDLE and sample.break_phase >= 0.25
	input.recover = _controller.state == SurfControllerType.State.TREAD
	return input

func _update_player_visuals() -> void:
	var base_position: Vector3 = _controller.position
	_board.position = base_position + Vector3(0.0, 0.12, 0.0)
	_surfer.position = base_position + Vector3(0.0, 0.95, 0.0)
	_surfer.visible = _controller.state not in [SurfControllerType.State.WIPEOUT, SurfControllerType.State.TREAD]
	_camera.position = _camera.position.lerp(base_position + Vector3(0.0, 8.0, -13.0), 0.08)
	_camera.look_at(base_position + Vector3(0.0, 0.7, 0.0), Vector3.UP)
	_status_label.text = "STATE %-10s  SPEED %4.1f m/s  STAMINA %3d  HITS %d" % [
		_state_name(_controller.state),
		_controller.horizontal_speed(),
		int(_controller.stamina),
		_hits,
	]

func _update_wave_cues() -> void:
	var starts := _ocean.wave_starts()
	var nearest_seconds := INF
	var nearest_index := -1
	for index in starts.size():
		var cycle_start: float = starts[index]
		while cycle_start < _elapsed:
			cycle_start += SET_PERIOD_SECONDS
		var seconds_until := cycle_start - _elapsed
		if seconds_until < nearest_seconds:
			nearest_seconds = seconds_until
			nearest_index = index
		var approach := clampf(1.0 - seconds_until / 12.0, 0.0, 1.0)
		_wave_meshes[index].position.z = lerpf(58.0, -12.0, approach)
		_wave_meshes[index].position.y = 0.12 + approach * 0.65

	_wave_label.text = "VISUAL + AUDIO SWELL CUE  •  WAVE %d IN %.1fs" % [nearest_index + 1, nearest_seconds]
	if nearest_seconds <= 3.0 and nearest_index != _cue_played_for_wave:
		_cue_played_for_wave = nearest_index
		_play_wave_tone()
	elif nearest_seconds > 6.0:
		_cue_played_for_wave = -1

	var storm_amount := clampf(fposmod(_elapsed, SET_PERIOD_SECONDS) / SET_PERIOD_SECONDS, 0.0, 1.0)
	var ocean_material := _ocean_mesh.get_active_material(0) as StandardMaterial3D
	ocean_material.albedo_color = WATER_COLOR.lerp(STORM_COLOR, storm_amount * 0.7)

func _play_wave_tone() -> void:
	_audio_player.play()
	var playback := _audio_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		return
	for index in 2_646:
		var sample := sin(TAU * 660.0 * float(index) / 22_050.0) * 0.12
		playback.push_frame(Vector2(sample, sample))

func _fire_sidearm(aim_down: bool) -> void:
	if _fire_cooldown > 0.0:
		return
	_fire_cooldown = FIRE_COOLDOWN_SECONDS
	var direction := Vector3(0.0, -0.35 if aim_down else 0.0, 1.0).normalized()
	var projectile := ProjectileType.new(_controller.position + Vector3(0.0, 1.4, 0.0), direction * 30.0)
	var visual := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.08
	mesh.height = 0.16
	mesh.material = _material(Color(1.0, 0.82, 0.28, 1.0), 0.25)
	visual.mesh = mesh
	add_child(visual)
	_projectiles.append({"model": projectile, "visual": visual})

func _update_projectiles(delta: float) -> void:
	var active: Array[Dictionary] = []
	var target := get_node_or_null("TargetBuoy") as Node3D
	for entry in _projectiles:
		var projectile: Variant = entry.model
		var visual: MeshInstance3D = entry.visual
		projectile.step(delta, _ocean, _elapsed)
		visual.position = projectile.position
		if projectile.alive and target != null and projectile.position.distance_to(target.position) <= 1.0:
			projectile.alive = false
			_hits += 1
		if projectile.alive:
			active.append(entry)
		else:
			visual.queue_free()
	_projectiles = active

func _finish_benchmark() -> void:
	_finished = true
	_metrics.finish(OS.get_static_memory_usage())
	var p95_ms: float = _metrics.p95_ms()
	var memory_growth: int = _metrics.memory_growth_bytes()
	var enough_samples: bool = _metrics.sample_count() >= maxi(int((benchmark_duration_seconds - 2.0) * 30.0), 1)
	var passed := enough_samples and memory_growth <= 67_108_864
	if benchmark_requires_frame_budget:
		passed = (
			passed
			and p95_ms <= 16.7
			and benchmark_duration_seconds >= 300.0
			and not benchmark_result_path.is_empty()
		)
	var evidence := {
		"godot_version": Engine.get_version_info().string,
		"platform": OS.get_name(),
		"architecture": Engine.get_architecture_name(),
		"resolution": "1600x900",
		"duration_seconds": benchmark_duration_seconds,
		"frame_samples": _metrics.sample_count(),
		"p95_frame_ms": p95_ms,
		"memory_growth_bytes": memory_growth,
		"performance_budget_required": benchmark_requires_frame_budget,
		"passed": passed,
	}
	if not _write_benchmark(evidence):
		passed = false
	print("SLICE_BENCHMARK_%s duration=%.1f p95_ms=%.3f memory_growth=%d" % ["OK" if passed else "FAILED", benchmark_duration_seconds, p95_ms, memory_growth])
	get_tree().quit(0 if passed else 1)

func _capture_screenshot() -> void:
	_screenshot_saved = true
	if benchmark_screenshot_path.is_empty() or DisplayServer.get_name() == "headless":
		return
	var absolute_path := ProjectSettings.globalize_path(benchmark_screenshot_path)
	DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
	var result := get_viewport().get_texture().get_image().save_png(absolute_path)
	if result != OK:
		push_error("Could not write benchmark screenshot: %s" % absolute_path)

func _write_benchmark(data: Dictionary) -> bool:
	if benchmark_result_path.is_empty():
		return not benchmark_requires_frame_budget
	var absolute_path := ProjectSettings.globalize_path(benchmark_result_path)
	DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
	var file := FileAccess.open(absolute_path, FileAccess.WRITE)
	if file == null:
		push_error("Could not write benchmark evidence: %s" % absolute_path)
		return false
	file.store_string(JSON.stringify(data, "\t"))
	return true

func _material(color: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material

func _state_name(value: int) -> String:
	return ["PADDLE", "DUCK-DIVE", "POP-UP", "RIDE", "WIPEOUT", "TREAD"][clampi(value, 0, 5)]
