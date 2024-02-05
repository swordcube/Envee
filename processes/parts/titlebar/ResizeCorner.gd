class_name ResizeCorner extends Control

@onready var process:Process = $"../../"

@export var left:bool = true
@export var top:bool = false

var hovering:bool = false
var dragging:bool = false
var process_pos:Vector2 = Vector2.ZERO
var process_size:Vector2 = Vector2.ZERO
var mouse_offset:Vector2 = Vector2.ZERO
var distance_to_edge:Vector2 = Vector2.ZERO

func _process(_delta:float):
	hovering = get_global_rect().has_point(get_global_mouse_position())
	if hovering:
		if Input.is_action_just_pressed("left_click"):
			process_pos = process.position
			process_size = process.size
			mouse_offset = get_local_mouse_position()
			dragging = true
	
	var old_hd:bool = hovering or dragging
	if hovering or dragging:
		if left:
			mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE if top else Control.CURSOR_BDIAGSIZE
		else:
			mouse_default_cursor_shape = Control.CURSOR_BDIAGSIZE if top else Control.CURSOR_FDIAGSIZE
			
	elif old_hd != hovering or dragging:
		mouse_default_cursor_shape = Control.CURSOR_ARROW
		
	if dragging:
		if top:
			process.position.y = get_global_mouse_position().y - mouse_offset.y
			if not left: process.position.x = process_pos.x
			process.size.y = process_size.y + (process_pos.y - process.position.y)
		else:
			distance_to_edge.y = process.size.y - global_position.y
			process.size.y = get_global_mouse_position().y + distance_to_edge.y - mouse_offset.y
		
		if left:
			distance_to_edge.x = global_position.x
			process.position.x = (process.position.x + get_global_mouse_position().x - mouse_offset.x) - distance_to_edge.x
			if not top: process.position.y = process_pos.y
			process.size.x = process_size.x + (process_pos.x - process.position.x)
		else:
			distance_to_edge.x = global_position.x - process.size.x
			process.size.x = get_global_mouse_position().x - distance_to_edge.x - mouse_offset.x
	
		if not Input.is_action_pressed("left_click"):
			dragging = false
