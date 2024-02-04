class_name ColorBox extends Control

@onready var panel:Panel = $Panel

signal selected

func _process(delta):
	var hovering:bool = get_global_rect().has_point(get_global_mouse_position())
	if hovering and Input.is_action_just_pressed("left_click"):
		selected.emit()
