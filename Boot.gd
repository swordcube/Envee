extends Control

@onready var logo:TextureRect = $Logo
@onready var progress:ProgressBar = $Progress
@onready var status:Label = $Status

var cur_progress:int = 0

func _ready():
	timed_method(0.01, init_boot)
	timed_method(1.0, change_status.bind("WindowManager"))
	timed_method(2.0, change_progress.bind("LoginUI", 1))
	timed_method(3.0, change_progress.bind("ShellInterface", 2))
	timed_method(4.0, change_progress.bind("WallpaperService", 3))
	timed_method(5.0, finish_booting)
	
func _process(delta:float):
	progress.value = lerpf(progress.value, float(cur_progress), delta * 60 * 0.25)
	if Input.is_anything_pressed():
		immediately_finish()

func timed_method(delay_s:float, method:Callable):
	var timer:SceneTreeTimer = get_tree().create_timer(delay_s)
	timer.timeout.connect(method)

func change_status(new_status:String):
	if not status.visible:
		status.modulate.a = 0.0
		status.position.y -= 5.0
		status.visible = true
		
		var tween:Tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_parallel()
		tween.tween_property(status, "modulate:a", 1.0, 0.5)
		tween.tween_property(status, "position:y", status.position.y + 5.0, 0.5)
	
	status.text = "Loading %s" % new_status

func init_boot():
	var window:Window = get_window()
	window.mode = Window.MODE_FULLSCREEN
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func change_progress(new_status:String, new_progress:int):
	change_status(new_status)
	cur_progress = new_progress
	
func finish_booting():
	cur_progress = int(progress.max_value)
	
	var tween:Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel()
	tween.tween_property(status, "modulate:a", 0.0, 0.5)
	
	await get_tree().create_timer(1.0).timeout
	
	tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.set_parallel()
	tween.tween_property(logo, "modulate:a", 0.0, 0.5)
	tween.tween_property(progress, "modulate:a", 0.0, 0.5)
	
	await get_tree().create_timer(0.75).timeout
	
	immediately_finish()
	
func immediately_finish():
	if UserDatabase.users.is_empty():
		get_tree().change_scene_to_file("res://setup/Setup.tscn")
	else:
		get_tree().change_scene_to_file("res://login/LoginUI.tscn")
