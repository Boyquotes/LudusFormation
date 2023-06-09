extends Label

var tick_spent : float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	tick_spent += delta
	text = "%.1f" % tick_spent
