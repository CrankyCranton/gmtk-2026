class_name FallZone extends Area3D


func _on_body_entered(_body: Node3D) -> void:
	print("U looze")
	get_tree().paused = true
	await get_tree().create_timer(1.5).timeout
	get_tree().paused = false
	get_tree().reload_current_scene()
