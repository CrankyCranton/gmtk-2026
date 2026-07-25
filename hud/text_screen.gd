class_name TextScreen extends CanvasLayer


var accepted := false

@onready var background: ColorRect = $Background


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept") and not accepted:
		accepted = true
		get_tree().paused = false
		await create_tween().tween_property(background, ^"modulate", Color.TRANSPARENT, 1.0
				).finished
		queue_free()
