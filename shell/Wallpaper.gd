extends TextureRect


func _ready() -> void:
	get_viewport().size_changed.connect(on_size_change)


func on_size_change() -> void:
	if UserDatabase.users.is_empty():
		return
	
	Tools.apply_picture_pos(UserDatabase.users[Tools.current_user].wallpaper_picture_pos, self)
