extends Node

const PROCESS_DIR:String = "res://processes"
const SYSTEM_PROCESS_DIR:String = "res://processes/system"

signal process_open(proc:Process)
signal process_close(proc:Process)

var main_windows:Dictionary = {}
var list:Array[Process] = []

var proc_mutex:Mutex = Mutex.new()

func has_process(process_name:String):
	for proc in list:
		if proc.proc_name == process_name:
			return true
	return false
	
func spawn_process(proc:Process):
	get_tree().current_scene.add_child(proc)
	if not is_instance_valid(main_windows.get(proc.proc_name)):
		main_windows[proc.proc_name] = proc
	process_open.emit(proc)

func load_process_raw(process_path:String) -> Process:
	if ResourceLoader.exists(process_path):
		var proc:Process = load(process_path).instantiate()
		proc.proc_name = process_path.substr(process_path.rfind("/") + 1).get_basename()
		return proc
		
	printerr('Process at "%s" doesn\'t exist!' % process_path)
	return null
	
func load_process(process_path:String) -> Process:
	var full_sys_process_path:String = SYSTEM_PROCESS_DIR+"/"+process_path+".tscn"
	var full_process_path:String = PROCESS_DIR+"/"+process_path+".tscn"
	
	# Check for system processes first
	if ResourceLoader.exists(full_sys_process_path):
		var proc:Process = load(full_sys_process_path).instantiate()
		proc.proc_name = full_sys_process_path.substr(full_sys_process_path.rfind("/") + 1).get_basename()
		return proc
		
	# Check for full path processes after
	if ResourceLoader.exists(full_process_path):
		var proc:Process = load(full_process_path).instantiate()
		proc.proc_name = full_process_path.substr(full_process_path.rfind("/") + 1).get_basename()
		return proc
		
	printerr('Process at "%s" doesn\'t exist!' % process_path)
	return null

func exists(process_path:String):
	var full_sys_process_path:String = SYSTEM_PROCESS_DIR+"/"+process_path+".tscn"
	var full_process_path:String = PROCESS_DIR+"/"+process_path+".tscn"
	
	# Check for system processes first
	if ResourceLoader.exists(full_sys_process_path):
		return true
		
	# Check for full path processes after
	if ResourceLoader.exists(full_process_path):
		return true
		
	return false

func open(process_path:String):
	var full_sys_process_path:String = SYSTEM_PROCESS_DIR+"/"+process_path+".tscn"
	var full_process_path:String = PROCESS_DIR+"/"+process_path+".tscn"
	
	# Check for system processes first
	if ResourceLoader.exists(full_sys_process_path):
		Thread.new().start(func():
			proc_mutex.lock()
			var proc:Process = load_process_raw(full_sys_process_path)
			spawn_process.call_deferred(proc)
			proc_mutex.unlock()
		)
		return
		
	# Check for full path processes after
	if ResourceLoader.exists(full_process_path):
		Thread.new().start(func():
			proc_mutex.lock()
			var proc:Process = load_process_raw(full_process_path)
			spawn_process.call_deferred(proc)
			proc_mutex.unlock()
		)
