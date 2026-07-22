class_name Boss extends Area3D


func _on_body_entered(_body: Node3D) -> void:
	print("U won!")
	get_tree().paused = true
