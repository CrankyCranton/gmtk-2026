class_name Boss extends Area3D


signal annoyed

# TODO: fill limitations
var limitations: Array[Dictionary] = [
	{

	},
	{
		"time": 130,
	},
	{
		"time": 120,
		"health": 3
	},
	{
		"time": 110,
		"health": 3,
		"dashes" : 4
	},
	{
		"time": 100,
		"health": 3,
		"dashes" : 4,
		"enemies" : 5
	},
	{
		"time": 90,
		"health": 3,
		"dashes" : 4,
		"enemies" : 5,
		"grappling_hooks": 3
	},
	{
		"time": 80,
		"health": 3,
		"dashes" : 4,
		"enemies" : 5,
		"grappling_hooks": 3,
		"ammo": 7
	},
	{
		"time": 70,
		"health": 3,
		"dashes" : 4,
		"enemies" : 5,
		"grappling_hooks": 3,
		"ammo": 7,
		"air_jumps" : 12
	},
]
var dialogues: Array[Array] = [
	[
		"Hello. This is a test.",
		"Here's line 2 of the dialogue.",
	],
]
var current_index: int = 0
var type_delay: float = 0.03
var hold_len_per_char: float = 0.05

@onready var annoyance_bar: TextureProgressBar = $AnnoyanceBar
@onready var face: Marker3D = $Face
@onready var text_display: Label3D = $TextDisplay
@onready var fade: ColorRect = $Fade


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	annoyance_bar.max_value = limitations.size()
	update_health_bar()


func update_health_bar() -> void:
	annoyance_bar.value = limitations.size() - current_index


func dialogue(lines: Array) -> void:
	for line: String in lines:
		await say(line)


func say(line: String) -> void:
	text_display.text = ""
	@warning_ignore("shadowed_global_identifier")
	for char: String in line:
		text_display.text += char
		await get_tree().create_timer(type_delay).timeout
	await get_tree().create_timer(hold_len_per_char * line.length()).timeout
	text_display.text = ""


func _on_body_entered(body: Player) -> void:
	if body.counters.has("enemies") and body.counters["enemies"] > 0:
		print("No enough enemies")
		say("As per the contract, you must kill %s more imps before you may speak to me."
				% body.counters["enemies"])
		return

	get_tree().paused = true
	await get_tree().create_timer(0.5).timeout
	create_tween().set_trans(Tween.TRANS_SINE).tween_property(
			body.head, ^"global_basis",
			Basis.looking_at(body.head.global_position.direction_to(face.global_position)), 1.0)

	if dialogues.size() > current_index:
		await dialogue(dialogues[current_index])
	else:
		printerr("No dialogue for index ", current_index)
	await create_tween().tween_property(fade, ^"modulate", Color.WHITE, 1.0).finished

	current_index += 1
	if current_index >= limitations.size():
		print("U WOOOOOOONNNNNN!!!!!!!!!!!!!!! (like, fr this time)")
		get_tree().change_scene_to_packed(Level.TEXT_SCREENS.back())
	else:
		print("U won!")
		update_health_bar()
		annoyed.emit()
