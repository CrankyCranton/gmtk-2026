class_name Boss extends Area3D


signal annoyed

# TODO: fill limitations
var limitations: Array[Dictionary] = [
	{

	},
	{
		"health": 3,
	},
	{
		"health": 3,
		"ammo": 50,
		"air_jumps": 25,
		"dashes": 5,
		"grappling_hooks": 5,
		"time": 50,
		"enemies": 3,
	},
]
var current_index: int = 0

@onready var annoyance_bar: TextureProgressBar = $AnnoyanceBar


func _ready() -> void:
	annoyance_bar.max_value = limitations.size()
	update_health_bar()


func update_health_bar() -> void:
	annoyance_bar.value = limitations.size() - current_index


func _on_body_entered(body: Player) -> void:
	if body.counters.has("enemies") and body.counters["enemies"] > 0:
		print("No enough enemies")
		return

	current_index += 1
	if current_index >= limitations.size():
		print("U WOOOOOOONNNNNN!!!!!!!!!!!!!!! (like, fr this time)")
		get_tree().change_scene_to_packed(Level.TEXT_SCREENS.back())
	else:
		print("U won!")
		update_health_bar()
		annoyed.emit()
