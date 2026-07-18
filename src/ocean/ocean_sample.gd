class_name OceanSample
extends RefCounted

var height: float
var normal: Vector3
var surface_velocity: Vector2
var current: Vector2
var break_phase: float

func _init(
	p_height: float,
	p_normal: Vector3,
	p_surface_velocity: Vector2,
	p_current: Vector2,
	p_break_phase: float
) -> void:
	height = p_height
	normal = p_normal
	surface_velocity = p_surface_velocity
	current = p_current
	break_phase = p_break_phase
