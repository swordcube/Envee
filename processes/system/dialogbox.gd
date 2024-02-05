class_name DialogBox extends Process

enum Type {
	ERROR,
	WARNING,
	INFO,
	SUCCESS
}

@onready var title_bar:TitleBar = $Container/TitleBar
@onready var message_contents:Label = $Container/MessageContents
@onready var icon:TextureRect = $Container/Icon

@export var type:Type = Type.INFO
@export var title:String = "Dialog Title"
@export_multiline var contents:String = "Dialog Contents"

func _ready():
	super()
	title_bar.label.text = title
	message_contents.text = contents
	
	match type:
		Type.ERROR:
			icon.texture = preload("res://assets/dialog_icons/error.png")
			
		Type.WARNING:
			icon.texture = preload("res://assets/dialog_icons/warning.png")
			
		Type.INFO:
			icon.texture = preload("res://assets/dialog_icons/info.png")
			
		Type.SUCCESS:
			icon.texture = preload("res://assets/dialog_icons/success.png")

func button_press(button:StringName):
	match button:
		&"OK":
			close()
