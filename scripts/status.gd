extends Label

func update(string: String) -> void:
	text = string
	$ResetTimer.start()
	
	modulate = Color.WHITE
	var _t = create_tween()
	_t.tween_property(self, "modulate", Color(0.5, 0.5, 0.5), 0.4)

func _ready() -> void:
	Global.status_updated.connect(update)

func _on_reset_timer_timeout() -> void:
	text = "WAM"
