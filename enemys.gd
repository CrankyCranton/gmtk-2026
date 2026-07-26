extends Node3D


func _process(delta: float) -> void:
	print($"../Player".counters)
	if not $"../Player".counters.has("health"):
		for i in get_children():
			i.queue_free()
