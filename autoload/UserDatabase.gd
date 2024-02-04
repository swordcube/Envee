extends Node

const USER_DIR:String = "user://users"

var users:Array[UserData] = []

func _ready():
	if not DirAccess.dir_exists_absolute(USER_DIR):
		print("Users folder non-existent, creating now...")
		DirAccess.make_dir_absolute(USER_DIR)
		
	scan()
	if not users.is_empty():
		Tools.update_accent_color(users[0].color_scheme)
	
func data_for(user_name:String) -> UserData:
	for user in users:
		if user.user_name == user_name:
			return user
	return null

func scan():
	users.clear()
	for user in DirAccess.get_files_at(USER_DIR):
		var json_path:String = "%s/%s" % [USER_DIR, user]
		if not FileAccess.file_exists(json_path):
			continue
			
		var json:Dictionary = JSON.parse_string(FileAccess.open(json_path, FileAccess.READ).get_as_text())
		var data:UserData = UserData.new()
		data.user_name = user.get_basename()
		data.password = json.password
		
		var sch:PackedStringArray = json.color_scheme.split(",")
		data.color_scheme = Color(float(sch[0]), float(sch[1]), float(sch[2]), 1.0)
		data.wallpaper = json.wallpaper
		data.wallpaper_picture_pos = json.wallpaper_picture_pos
		users.append(data)
		
func save(user_name:String, data:Dictionary):
	var f:FileAccess = FileAccess.open("%s/%s.json" % [USER_DIR, user_name], FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))
	
	var d:UserData = data_for(user_name)
	if not is_instance_valid(d):
		return
	d.password = data.password
	
	var sch:PackedStringArray = data.color_scheme.split(",")
	data.color_scheme = Color(float(sch[0]), float(sch[1]), float(sch[2]), 1.0)
	
	d.wallpaper = data.wallpaper
	d.wallpaper_picture_pos = data.wallpaper_picture_pos
