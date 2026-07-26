class_name Level extends Node3D


# Should be 1 more in length than the amount of levels.
# The last one is the end screen, loaded in boss.gd
const TEXT_SCREENS: Array[PackedScene] = [
	preload("res://hud/text_screens/text_screen_intro.tscn"),
]

# Used to record the passed index from the previous level before the boss is instantiated.
var index: int = 0

@onready var player: Player = $Player
@onready var boss: Boss = $Boss
@onready var contract: Contract = $Contract
@onready var fall_zone_shape: CollisionShape3D = $FallZone/CollisionShape3D


func _ready() -> void:
	player.fall_depth = fall_zone_shape.global_position.y
	player.died.connect(load_scene)
	boss.annoyed.connect(load_scene)
	player.counters_changed.connect(contract._on_player_counters_changed)
	player.counters_initialized.connect(contract._on_player_counters_initialized)

	player.counters = boss.limitations[index].duplicate()
	player.counters_initialized.emit(player.counters.duplicate())

	if TEXT_SCREENS.size() <= index:
		printerr("Not enough text screens! Level index: ", index)
	else:
		add_child(TEXT_SCREENS[index].instantiate())


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
