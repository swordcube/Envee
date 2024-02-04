extends Control

@onready var container:HBoxContainer = $HBoxContainer

var hovering:bool = false

func _input(event:InputEvent):
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if not hovering:
			return
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_LEFT:
			container.position.x -= event.factor * 15.0
			if container.position.x < -(container.size.x - 500):
				container.position.x = -(container.size.x - 500)
			
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN or event.button_index == MOUSE_BUTTON_WHEEL_RIGHT:
			container.position.x += event.factor * 15.0
			if container.position.x > 0:
				container.position.x = 0

func _process(delta):
	hovering = get_global_rect().has_point(get_global_mouse_position())
