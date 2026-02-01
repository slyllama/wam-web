extends Label

func update(string: String) -> void:
	text = string
	$ResetTimer.start()
	
	modulate.a = 1.0
	var _t = create_tween()
	_t.tween_property(self, "modulate:a", 0.0, 2.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

func _ready() -> void:
	Global.status_updated.connect(update)

func _on_reset_timer_timeout() -> void:
	text = ""
