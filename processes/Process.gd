class_name Process extends Control

var proc_name:String = ""
	
func _ready():
	ProcessManager.list.append(self)
	position = (Vector2(get_window().size) - size) * 0.5
	pivot_offset = size * 0.5
	
	if SystemSettings.enable_animations:
		animate_inwards()
	
func animate_inwards():
	scale *= 0.9
	modulate.a = 0.0
	
	var tween:Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel()
	tween.tween_property(self, "modulate:a", 1.0, 0.25)
	tween.tween_property(self, "scale", Vector2.ONE, 0.25)
	
func animate_outwards():
	var tween:Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.set_parallel()
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.tween_property(self, "scale", Vector2.ONE * 0.9, 0.25)
	
func _process(_delta:float):
	pivot_offset = size * 0.5
	if position.y < -15:
		position.y = -15
	
func close():
	if not ProcessManager.list.has(self):
		return
	ProcessManager.list.erase(self)
	
	if ProcessManager.main_windows.get(proc_name) == self:
		ProcessManager.main_windows.erase(proc_name)
	
	ProcessManager.process_close.emit(self)
	
	if SystemSettings.enable_animations:
		animate_outwards()
		await get_tree().create_timer(0.3).timeout
		queue_free()
	else:
		queue_free()

func _on_address_bar_text_submitted(new_text:String):
	var filtered_address:String = new_text.replace("sys://", "user://")
	print("Loading address: %s" % filtered_address)
