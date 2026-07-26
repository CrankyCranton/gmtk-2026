extends CanvasLayer


var accepted := false

@onready var background: ColorRect = $Background


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept") and not accepted:
		accepted = true
		get_tree().paused = false
		await create_tween().tween_property(background, ^"modulate", Color.TRANSPARENT, 3.0
				).finished
		load_scene()

func load_scene():
	var next_level: Level = load("res://level_3_test.tscn").instantiate()
	next_level.easy_mode = false
	next_level.index = 7
	get_node(^"/root").add_child(next_level)

	next_level.boss.endless = true
	if not get_tree().current_scene == null:
		get_tree().current_scene.queue_free()
		get_tree().current_scene = next_level
	queue_free()
