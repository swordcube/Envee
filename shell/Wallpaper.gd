extends TextureRect

func _notification(what):
	if what == NOTIFICATION_RESIZED and not UserDatabase.users.is_empty():
		Tools.apply_picture_pos(UserDatabase.users[Tools.current_user].wallpaper_picture_pos, self)
