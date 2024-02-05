class_name TitleButton extends Panel

const MAXIMIZE_TEX:Texture2D = preload("res://assets/titlebar/maximize.png")
const RESTORE_TEX:Texture2D = preload("res://assets/titlebar/restore.png")

@onready var title_bar:TitleBar = $"../../"
@onready var icon:TextureRect = $TextureRect

var hovering:bool = false

func _ready():
	self_modulate.a = 0.0

func _process(delta:float):
	hovering = get_global_rect().has_point(get_global_mouse_position())
	
	modulate = Tools.cur_accent_color.lerp(Color.WHITE, 0.75)
	self_modulate.a = lerpf(self_modulate.a, (1.0 if Input.is_action_pressed("left_click") else 0.5) if hovering else 0.0, delta * 60 * 0.25)

	if hovering and Input.is_action_just_released("left_click"):
		title_bar.select_item(name)
		on_select()
		
func on_select():
	match name:
		&"maximize":
			if title_bar.maximized:
				icon.texture = RESTORE_TEX
			else:
				icon.texture = MAXIMIZE_TEX
