class_name TaskbarIcon extends ColorRect

@onready var icon:TextureRect = $TextureRect
@onready var open_indicator:ColorRect = $OpenIndicator

var hovering:bool = false

func _ready():
	ProcessManager.process_open.connect(func(_proc:Process):
		open_indicator.visible = ProcessManager.has_process(name)
	)
	ProcessManager.process_close.connect(func(_proc:Process):
		open_indicator.visible = ProcessManager.has_process(name)
	)

func _process(delta:float):
	color = Tools.cur_accent_color
	hovering = get_global_rect().has_point(get_global_mouse_position())
	self_modulate.a = lerpf(self_modulate.a, (1.0 if Input.is_action_pressed("left_click") else 0.5) if hovering else 0.0, delta * 60 * 0.25)
	
	if hovering and Input.is_action_just_released("left_click"):
		if ProcessManager.has_process(name):
			ProcessManager.main_windows.get(name).visible = true
		else:
			if ProcessManager.exists(name):
				ProcessManager.open(name)
			else:
				var dialog := ProcessManager.load_process("dialogbox") as DialogBox
				dialog.type = DialogBox.Type.ERROR
				dialog.title = "Unable to open process"
				dialog.contents = 'Process at "%s" doesn\'t exist!' % name
				ProcessManager.spawn_process(dialog)
	
	if icon.texture.resource_path.begins_with("res://assets/app_icons/"): # Is probably a default icon, which is all white
		modulate = Tools.cur_accent_color.lerp(Color.WHITE, 0.75)
	else:
		modulate = Color.WHITE
