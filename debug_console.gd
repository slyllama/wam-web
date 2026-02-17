extends RichTextLabel

func _ready() -> void:
	Global.printed_to_console.connect(func(string: String):
		text += string + "\n")
