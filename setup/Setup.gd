extends Control

@onready var bg:TextureRect = $BG

# user account page
@onready var username_field:LineEdit = $Pages/Page2/UsernameField
@onready var password_field:LineEdit = $Pages/Page2/PasswordField
@onready var password_hint_field:LineEdit = $Pages/Page2/PasswordHintField
@onready var uap_error:Label = $Pages/Page2/Error

# personalization page
@onready var color_selections:HBoxContainer = $Pages/Page3/ColorSelections
@onready var color_indicator:Panel = $Pages/Page3/ColorIndicator

@onready var wallpaper_selections:HBoxContainer = $Pages/Page3/WallpaperSelections/HBoxContainer

var _indicator_tween:Tween
var _cur_accent_color:Color
var _cur_wallpaper:Texture2D

# misc
@export var cur_page:NodePath = "Pages/Page1"

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_cur_accent_color = Color("76c08b")
	_cur_wallpaper = $Pages/Page3/WallpaperSelections/HBoxContainer/Wallpaper3.texture
	
	var page:Control = get_node(cur_page)
	page.modulate.a = 0.0
	page.position.x = 30.0
	
	for p in $Pages.get_children():
		p.visible = (p == page)
		
	await get_tree().create_timer(0.5).timeout
	
	var tween:Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel()
	tween.tween_property(page, "position:x", 0.0, 1.0)
	tween.tween_property(page, "modulate:a", 1.0, 1.0)
	tween.tween_property(bg, "modulate:a", 0.15, 1.0)

func create_user():
	if username_field.text.is_empty():
		return
	
	print('Creating user called %s' % username_field.text)
	UserDatabase.save(username_field.text, {
		"password": password_field.text.reverse().sha256_text(),
		"color_scheme": "%s,%s,%s" % [_cur_accent_color.r, _cur_accent_color.g, _cur_accent_color.b],
		"wallpaper": _cur_wallpaper.resource_path,
		"wallpaper_picture_pos": Tools.PicturePosition.FILL
	})
	UserDatabase.scan()
	
	switch_page(3)

func switch_page(idx:int):
	var page:Control = get_node(cur_page)
	
	var tween:Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel()
	tween.tween_property(page, "position:x", -30.0, 0.5)
	tween.tween_property(page, "modulate:a", 0.0, 0.5)
	
	cur_page = NodePath("Pages/Page"+str(idx))
	page = get_node(cur_page)
	page.modulate.a = 0.0
	page.position.x = 30.0
	page.visible = true
	
	var tween2:Tween = get_tree().create_tween()
	tween2.set_trans(Tween.TRANS_CUBIC)
	tween2.set_ease(Tween.EASE_OUT)
	tween2.set_parallel()
	tween2.tween_interval(1.5)
	tween2.tween_property(page, "position:x", 0.0, 1.0)
	tween2.tween_property(page, "modulate:a", 1.0, 1.0)
	
func finish_setup():
	var page:Control = get_node(cur_page)
	var tween:Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel()
	tween.tween_property(page, "position:x", -30.0, 0.5)
	tween.tween_property(page, "modulate:a", 0.0, 0.5)
	tween.tween_property(bg, "modulate:a", 0.0, 1.0)
	
	await get_tree().create_timer(1.05).timeout
	UserDatabase.scan()
	
	var data:UserData = UserDatabase.data_for(username_field.text)
	UserDatabase.save(username_field.text, {
		"password": data.password,
		"color_scheme": "%s,%s,%s" % [_cur_accent_color.r, _cur_accent_color.g, _cur_accent_color.b],
		"wallpaper": _cur_wallpaper.resource_path,
		"wallpaper_picture_pos": data.wallpaper_picture_pos
	})
	
	Tools.update_accent_color(_cur_accent_color)
	get_tree().change_scene_to_file("res://login/LoginUI.tscn")

func select_color(idx:int):
	var box:ColorBox = color_selections.get_child(idx) as ColorBox
	_cur_accent_color = box.panel.modulate
	
	if is_instance_valid(_indicator_tween):
		_indicator_tween.stop()
		_indicator_tween.unreference()
		
	_indicator_tween = create_tween()
	_indicator_tween.set_parallel()
	_indicator_tween.set_ease(Tween.EASE_OUT)
	_indicator_tween.set_trans(Tween.TRANS_CUBIC)
	_indicator_tween.tween_property(color_indicator, "position:x", box.global_position.x + ((box.size.x - color_indicator.size.x) * 0.5), 0.5)
	_indicator_tween.tween_property(color_indicator, "modulate", box.panel.modulate, 0.5)
	
func select_wallpaper(idx:int):
	var wallpaper:WallpaperBox = wallpaper_selections.get_child(idx) as WallpaperBox
	_cur_wallpaper = wallpaper.texture
	
	for w:WallpaperBox in wallpaper_selections.get_children():
		w.modulate.a = 1.0 if w.get_index() == idx else 0.3

func _physics_process(_delta:float):
	if username_field.text.is_empty():
		uap_error.label_settings.font_color = Color("df7b7b")
		uap_error.text = "A username is required."
	elif password_field.text.is_empty():
		uap_error.label_settings.font_color = Color("dfd67b")
		uap_error.text = "A password is recommended."
	else:
		uap_error.text = ""
