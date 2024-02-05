class_name Taskbar extends ColorRect

@onready var fg:ColorRect = $FG
@onready var start_button:ColorRect = $StartButton
@onready var start_icon:TextureRect = $StartButton/TextureRect

@onready var clock_bg:ColorRect = $Clock
@onready var clock:Label = $Clock/Label
@onready var clock_updater:Timer = $Clock/UpdateTimer

func _ready():
	start_button.self_modulate.a = 0.0
	clock_bg.self_modulate.a = 0.0
	update_clock()
	clock_updater.timeout.connect(update_clock)

func update_clock():
	var time:Dictionary = Time.get_time_dict_from_system()
	var hour:int = time.hour % 12
	clock.text = "%s:%s%s" % [12 if hour == 0 else hour, str(time.minute).lpad(2, "0"), "am" if time.hour - 12 < 0 else "pm"]

func _process(delta:float):
	var start_hovering:bool = start_button.get_global_rect().has_point(get_global_mouse_position())
	start_button.color = Tools.cur_accent_color
	start_icon.modulate = Tools.cur_accent_color.lerp(Color.WHITE, 0.75)
	start_button.self_modulate.a = lerpf(start_button.self_modulate.a, (1.0 if Input.is_action_pressed("left_click") else 0.5) if start_hovering else 0.0, delta * 60 * 0.25)

	var clock_hovering:bool = clock_bg.get_global_rect().has_point(get_global_mouse_position())
	clock_bg.color = Tools.cur_accent_color
	clock.modulate = Tools.cur_accent_color.lerp(Color.WHITE, 0.75)
	clock_bg.self_modulate.a = lerpf(clock_bg.self_modulate.a, (1.0 if Input.is_action_pressed("left_click") else 0.5) if clock_hovering else 0.0, delta * 60 * 0.25)

