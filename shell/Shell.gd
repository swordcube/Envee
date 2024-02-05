extends Control

@onready var wallpaper:TextureRect = $Wallpaper
@onready var taskbar:Taskbar = $Taskbar

func _ready():
	var user:UserData = UserDatabase.users[Tools.current_user]
	if not is_instance_valid(Tools.cur_wallpaper):
		Tools.cur_wallpaper = load(user.wallpaper) if ResourceLoader.exists(user.wallpaper) else ImageTexture.create_from_image(Image.load_from_file(user.wallpaper))
	
	wallpaper.texture = Tools.cur_wallpaper
	Tools.apply_picture_pos(user.wallpaper_picture_pos, wallpaper)
	
	taskbar.fg.color = Tools.cur_accent_color.lerp(Color.BLACK, 0.8)
	taskbar.fg.color.a = 0.8
	
	modulate.a = 0.0
	await get_tree().create_timer(0.5).timeout
	
	if SystemSettings.enable_animations:
		var tween:Tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "modulate:a", 1.0, 1.0)
	else:
		modulate.a = 1.0
