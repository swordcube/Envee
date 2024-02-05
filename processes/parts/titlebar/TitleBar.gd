class_name TitleBar extends Panel

@export var title:String = ""
@export var icon:Texture2D = preload("res://assets/app_icons/filebrowser.png")

@export var minimizable:bool = true
@export var maximizable:bool = true

@onready var label:Label = $Label
@onready var process:Process = $"../../"

var _last_pos:Vector2 = Vector2.ZERO
var _last_mouse_pos:Vector2 = Vector2.ZERO
var _last_size:Vector2 = Vector2.ZERO

var maximized:bool = false
var dragging:bool = false

func _ready():
	label.text = title
	$IconContainer/Icon.texture = icon
	
	if is_instance_valid(icon) and icon.resource_path.begins_with("res://assets/app_icons"):
		$IconContainer/Icon.modulate = Tools.cur_accent_color.lerp(Color.WHITE, 0.75)

	if not minimizable:
		$TitleButtons.remove_child($TitleButtons/minimize)
		
	if not maximizable:
		$TitleButtons.remove_child($TitleButtons/maximize)

	get_viewport().size_changed.connect(func():
		if maximized:
			var window:Window = get_window()
			process.size = Vector2(window.size.x, window.size.y - 45.0)
	)

func _input(event:InputEvent):
	if not ProcessManager.list.has(process):
		return
		
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if get_global_rect().has_point(get_global_mouse_position()) and event.button_index == MOUSE_BUTTON_LEFT:
			if not maximized:
				if event.pressed:
					dragging = true
					_last_pos = process.position
					_last_mouse_pos = get_global_mouse_position()
				else:
					dragging = false
			process.move_to_front()
				
	if event is InputEventMouseMotion:
		event = event as InputEventMouseMotion
		if not maximized and dragging and process.get_index() == get_tree().current_scene.get_child_count() - 1:
			process.position = _last_pos + (get_global_mouse_position() - _last_mouse_pos)

func select_item(item_name:StringName):
	match item_name:
		&"minimize":
			process.visible = false
			
		&"maximize":
			maximized = not maximized
			if maximized:
				_last_pos = process.position
				_last_size = process.size
				
				var window:Window = get_window()
				if SystemSettings.enable_animations:
					var tween:Tween = create_tween()
					tween.set_trans(Tween.TRANS_CUBIC)
					tween.set_ease(Tween.EASE_OUT)
					tween.set_parallel()
					tween.tween_property(process, "position", Vector2.ZERO, 0.25)
					tween.tween_property(process, "size", Vector2(window.size.x, window.size.y - 45.0), 0.25)
				else:
					process.position = Vector2.ZERO
					process.size = Vector2(window.size.x, window.size.y - 45.0)
			else:
				if SystemSettings.enable_animations:
					var tween:Tween = create_tween()
					tween.set_trans(Tween.TRANS_CUBIC)
					tween.set_ease(Tween.EASE_OUT)
					tween.set_parallel()
					tween.tween_property(process, "position", _last_pos, 0.25)
					tween.tween_property(process, "size", _last_size, 0.25)
				else:
					process.position = _last_pos
					process.size = _last_size
				
		&"close":
			process.close()
