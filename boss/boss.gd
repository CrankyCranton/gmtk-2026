class_name Boss extends Area3D


signal annoyed

# TODO: Adjust limitation order.
var limitation_order: Array[String] = [
	"health",
	"grappling_hooks",
	"dashes",
	"wall_jumps",
	"air_jumps",
	"enemies",
	"ammo",
	"time",
]
var current_index: int = 0

@onready var annoyance_bar: TextureProgressBar = $AnnoyanceBar


func _ready() -> void:
	annoyance_bar.max_value = limitation_order.size()
	update_health_bar()


func update_health_bar() -> void:
	annoyance_bar.value = limitation_order.size() - current_index


func _on_body_entered(body: Player) -> void:
	if body.counters["enemies"] > 0:
		print("No enough enemies")
		return

	print("U won!")
	if current_index >= limitation_order.size():
		print("U WOOOOOOONNNNNN!!!!!!!!!!!!!!!")
		pass # TODO: Load win screen.
	else:
		var next_limitation: String = limitation_order[current_index]
		current_index += 1
		update_health_bar()
		annoyed.emit(next_limitation)
