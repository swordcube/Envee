extends Node

enum PicturePosition {
	FILL,
	FIT,
	STRETCH,
	TILE,
	CENTER
}

const GUI_THEME:Theme = preload("res://assets/themes/gui.tres")
const GUI_SMALL_THEME:Theme = preload("res://assets/themes/gui_small.tres")

var cur_wallpaper:Texture2D
var cur_accent_color:Color

var current_user:int = 0

func apply_picture_pos(pos:PicturePosition, tex_rect:TextureRect):
	match pos:
		PicturePosition.FILL:
			var window:Window = get_window()
			var screen_size:Vector2 = window.size
			
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			
			var screen_ratio:float = screen_size.x / screen_size.y
			var tex_size:Vector2 = tex_rect.texture.get_size()
			var tex_ratio:float = tex_size.x / tex_size.y

			if tex_ratio >= screen_ratio:
				tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			else:
				tex_rect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
		
		PicturePosition.FIT:
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				
		PicturePosition.STRETCH:
			tex_rect.stretch_mode = TextureRect.STRETCH_SCALE
			tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			
		PicturePosition.TILE:
			tex_rect.stretch_mode = TextureRect.STRETCH_TILE
			tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			
		PicturePosition.CENTER:
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

func update_accent_color(new_color:Color):
	cur_accent_color = new_color
	
	var line_edit_n := Tools.GUI_THEME.get_stylebox("normal", "LineEdit") as StyleBoxFlat
	line_edit_n.bg_color = new_color.lerp(Color.BLACK, 0.75)
	
	var line_edit_sn := Tools.GUI_SMALL_THEME.get_stylebox("normal", "LineEdit") as StyleBoxFlat
	line_edit_sn.bg_color = new_color.lerp(Color.BLACK, 0.75)
	line_edit_sn.border_color = line_edit_sn.bg_color
	
	var line_edit_f := Tools.GUI_THEME.get_stylebox("focus", "LineEdit") as StyleBoxFlat
	line_edit_f.border_color = new_color.lerp(Color.BLACK, 0.15)
	line_edit_f.border_color.a = 0.5
	
	var line_edit_sf := Tools.GUI_SMALL_THEME.get_stylebox("focus", "LineEdit") as StyleBoxFlat
	line_edit_sf.border_color = new_color.lerp(Color.BLACK, 0.15)
	line_edit_sf.border_color.a = 0.5

	for th in [Tools.GUI_THEME, Tools.GUI_SMALL_THEME]:
		th.set_color("font_placeholder_color", "LineEdit", line_edit_f.border_color)
		th.set_color("font_color", "LineEdit", Color.WHITE.lerp(new_color, 0.35))
		th.set_color("font_color", "Label", Color.WHITE.lerp(new_color, 0.35))
	
		var button_n := th.get_stylebox("normal", "Button") as StyleBoxFlat
		button_n.bg_color = new_color.lerp(Color.BLACK, 0.25)
		
		var button_h := th.get_stylebox("hover", "Button") as StyleBoxFlat
		button_h.bg_color = new_color.lerp(Color.BLACK, 0.45)
		
		var button_p := th.get_stylebox("pressed", "Button") as StyleBoxFlat
		button_p.bg_color = new_color.lerp(Color.BLACK, 0.15)
		
		var button_f := th.get_stylebox("focus", "Button") as StyleBoxFlat
		button_f.border_color = new_color.lerp(Color.WHITE, 0.45)
		button_f.border_color.a = 0.65
	
		for i in ["font_color", "font_focus_color", "font_hover_color", "font_hover_pressed_color"]:
			th.set_color(i, "Button", Color.WHITE.lerp(new_color, 0.35))
	
	var panel := Tools.GUI_THEME.get_stylebox("panel", "Panel") as StyleBoxFlat
	panel.bg_color = new_color
