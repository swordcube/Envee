extends Control

@onready var bg:TextureRect = $BG
@onready var ui_container:Control = $UIContainer

@onready var user_list:HBoxContainer = $UIContainer/UserContainer/UserList

@onready var username_label:Label = $UIContainer/UsernameLabel
@onready var error_label:Label = $UIContainer/ErrorLabel
@onready var password_field:LineEdit = $UIContainer/PasswordField

@onready var cool_fx:TextureRect = $UIContainer/CoolFX
@onready var accept_password:TextureRect = $UIContainer/AcceptPassword

var user_data:UserData
var wallpapers:Dictionary = {}

func update_accent_color():
	var line_edit := Tools.GUI_THEME.get_stylebox("normal", "LineEdit") as StyleBoxFlat
	cool_fx.modulate = line_edit.bg_color

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	user_data = UserDatabase.users[Tools.current_user]
	for user in UserDatabase.users:
		wallpapers[user.user_name] = load(user.wallpaper) if ResourceLoader.exists(user.wallpaper) else ImageTexture.create_from_image(Image.load_from_file(user.wallpaper))
	
	bg.texture = wallpapers[user_data.user_name]
	username_label.text = user_data.user_name
	
	var icon:TextureRect = user_list.get_child(Tools.current_user).get_node("TextureRect") as TextureRect
	icon.modulate = Tools.GUI_THEME.get_color("font_color", "Label")
	accept_password.modulate = Tools.GUI_THEME.get_color("font_color", "Label")
	
	update_accent_color()
	if SystemSettings.enable_animations:
		ui_container.modulate.a = 0.0
		ui_container.position.x = 30.0
		
		await get_tree().create_timer(0.5).timeout
		var tween:Tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_parallel()
		tween.tween_property(ui_container, "position:x", 0.0, 1.0)
		tween.tween_property(ui_container, "modulate:a", 1.0, 1.0)
		tween.tween_property(bg, "modulate:a", 0.15, 1.0)
	else:
		bg.modulate.a = 0.15

func _input(event:InputEvent):
	if event is InputEventKey:
		event = event as InputEventKey
		if not event.pressed and event.keycode == KEY_ENTER and password_field.has_focus():
			try_login()

func accept_click(event:InputEvent):
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.pressed:
			return
		try_login()

func try_login():
	var encrypted_input:String = password_field.text.reverse().sha256_text()
	if encrypted_input == user_data.password:
		error_label.visible = false
		load_into_shell()
	else:
		error_label.visible = true

func load_into_shell():
	if SystemSettings.enable_animations:
		var tween:Tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_parallel()
		tween.tween_property(ui_container, "position:x", -30.0, 0.5)
		tween.tween_property(ui_container, "modulate:a", 0.0, 0.5)
		tween.tween_property(bg, "modulate:a", 0.0, 1.0)
	else:
		ui_container.modulate.a = 0.0
		bg.modulate.a = 0.0
	
	await get_tree().create_timer(1.05).timeout
	Tools.cur_wallpaper = wallpapers[user_data.user_name]
	get_tree().change_scene_to_file("res://shell/Shell.tscn")
