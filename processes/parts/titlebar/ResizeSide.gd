class_name ResizeSide extends Control

enum Side {
	LEFT,
	RIGHT,
	TOP,
	BOTTOM
}

@onready var process:Process = $"../../"

@export var side:ResizeSide.Side = ResizeSide.Side.LEFT

var hovering:bool = false
var dragging:bool = false
var process_pos:Vector2 = Vector2.ZERO
var process_size:Vector2 = Vector2.ZERO
var mouse_offset:Vector2 = Vector2.ZERO

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
		match side:
			Side.LEFT, Side.RIGHT:
				mouse_default_cursor_shape = Control.CURSOR_HSIZE
			
			Side.TOP, Side.BOTTOM:
				mouse_default_cursor_shape = Control.CURSOR_VSIZE
				
	elif old_hd != hovering or dragging:
		mouse_default_cursor_shape = Control.CURSOR_ARROW
		
	if dragging:
		match side:
			Side.LEFT:
				var distance_to_edge:float = global_position.x
				process.position.x = (process.position.x + get_global_mouse_position().x - mouse_offset.x) - distance_to_edge
				process.position.y = process_pos.y
				process.size.x = process_size.x + (process_pos.x - process.position.x)
			
			Side.RIGHT:
				var distance_to_edge:float = global_position.x - process.size.x
				process.size.x = get_global_mouse_position().x - distance_to_edge - mouse_offset.x
			
			Side.TOP:
				process.position.y = get_global_mouse_position().y - mouse_offset.y
				process.position.x = process_pos.x
				process.size.y = process_size.y + (process_pos.y - process.position.y)
			
			Side.BOTTOM:
				var distance_to_edge:float = process.size.y - position.y
				process.size.y = get_global_mouse_position().y + distance_to_edge - mouse_offset.y
		
		if not Input.is_action_pressed("left_click"):
			dragging = false
