class_name FallZone extends Area3D


func _on_body_entered(body: Player) -> void:
	body.die()
