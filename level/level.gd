class_name Level extends Node3D


# Used to record the passed index from the previous level before the boss is instantiated.
var index: int = 0

@onready var player: Player = $Player
@onready var boss: Boss = $Boss
@onready var contract: Contract = $Contract


func _ready() -> void:
	player.died.connect(load_scene)
	boss.annoyed.connect(load_scene)
	player.counters_changed.connect(contract._on_player_counters_changed)
	player.counters_initialized.connect(contract._on_player_counters_initialized)

	player.counters = boss.limitations[index].duplicate()
	player.counters_initialized.emit(player.counters.duplicate())


func load_scene() -> void:
	get_tree().paused = true
	await get_tree().create_timer(1.5).timeout
	get_tree().paused = false

	var next_level: Level = load(scene_file_path).instantiate()
	next_level.index = boss.current_index
	get_node(^"/root").add_child(next_level)

	next_level.boss.current_index = boss.current_index
	next_level.boss.update_health_bar()

	get_tree().current_scene.queue_free()
	get_tree().current_scene = next_level
