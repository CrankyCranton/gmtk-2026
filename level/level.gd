class_name Level extends Node3D


var active_limitations: Array[String] = []

@onready var player: Player = $Player
@onready var boss: Boss = $Boss


func _ready() -> void:
	player.died.connect(reload_scene)
	boss.annoyed.connect(progress_scenes)
	for counter: String in player.counters:
		if not counter in active_limitations:
			player.counters[counter] = -1
	player.counters_initialized.emit(player.counters.duplicate())


func reload_scene() -> void:
	get_tree().paused = true
	await get_tree().create_timer(1.5).timeout
	get_tree().paused = false

	var next_level: Level = load(scene_file_path).instantiate()
	next_level.active_limitations = active_limitations.duplicate()
	get_node(^"/root").add_child(next_level)
	next_level.boss.current_index = boss.current_index
	next_level.boss.update_health_bar()
	get_tree().current_scene.queue_free()
	get_tree().current_scene = next_level


func progress_scenes(new_limitation: String) -> void:
	active_limitations.append(new_limitation)
	reload_scene()
