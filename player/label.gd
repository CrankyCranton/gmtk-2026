extends Label


func _physics_process(delta: float) -> void:
	if get_parent().get_parent().easy_mode == false:
		text = "WASD to move
Space to jump
Shift to dash
Left-click to attack
Right-click to grapple
1 to enable easy mode (OFF)"
	else:
		text = "WASD to move
Space to jump
Shift to dash
Left-click to attack
Right-click to grapple
1 to enable easy mode (ON)"
