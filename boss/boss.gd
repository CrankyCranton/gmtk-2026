class_name Boss extends Area3D

var endless = false
signal annoyed

# TODO: fill limitations
var limitations: Array[Dictionary] = [
	{

	},
	{
		"time": 140,
	},
	{
		"time": 130,
		"health": 3
	},
	{
		"time": 120,
		"health": 3,
		"dashes" : 5
	},
	{
		"time": 110,
		"health": 3,
		"dashes" : 5,
		"enemies" : 5
	},
	{
		"time": 100,
		"health": 3,
		"dashes" : 5,
		"enemies" : 5,
		"grappling_hooks": 3
	},
	{
		"time": 90,
		"health": 3,
		"dashes" : 5,
		"enemies" : 5,
		"grappling_hooks": 3,
		"ammo": 7
	},
	{
		"time": 80,
		"health": 3,
		"dashes" : 5,
		"enemies" : 5,
		"grappling_hooks": 3,
		"ammo": 7,
		"air_jumps" : 14
	},
]
var dialogues: Array[Array] = [
	[
		"You've come to file a complaint?",
		"It seems you didnt read the fine print, your contract cannot be broken.",
	],
	[
		"Back again?",
		"Seems like I need to enforce some more of your contracts restrictions."
	],
	[
		"I dont know why I even bother paying my imps when they cant even keep out nuisances like you"
	],
	[
		"I dont have time for this.",
		"Do you know how much paperwork comes with stealing mortal souls?"
	],
	[
		"If not for the terms of our contract a much worse fate would be awaiting those who interupt my work."
	],
	[
		"Again...",
		"How many times do I need to tell you that I dont do refunds?"
	],
	[
		"Begone!"
	],
	[
		"This is too much work.",
		"You can keep your pitifull soul if this is what it takes for you to stop pestering me.",
		"Now get out before I change my mind."
	]
]
var current_index: int = 0
var type_delay: float = 0.03
var hold_len_per_char: float = 0.05

@onready var annoyance_bar: TextureProgressBar = $AnnoyanceBar
@onready var face: Marker3D = $Face
@onready var text_display: Label3D = $TextDisplay
@onready var fade: ColorRect = $Fade

var easy_limitations: Array[Dictionary] = [
	{

	},
	{
		"time": 180,
	},
	{
		"time": 170,
		"health": 5
	},
	{
		"time": 160,
		"health": 5,
		"dashes" : 7
	},
	{
		"time": 150,
		"health": 5,
		"dashes" : 6,
		"enemies" : 5
	},
	{
		"time": 140,
		"health": 5,
		"dashes" : 6,
		"enemies" : 4,
		"grappling_hooks": 5
	},
	{
		"time": 130,
		"health": 5,
		"dashes" : 6,
		"enemies" : 4,
		"grappling_hooks": 5,
		"ammo": 10
	},
	{
		"time": 120,
		"health": 5,
		"dashes" : 6,
		"enemies" : 4,
		"grappling_hooks": 5,
		"ammo": 10,
		"air_jumps" : 20
	}]

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
	EndlessTimer.is_running = false
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
	if endless == false:
		if dialogues.size() > current_index:
			await dialogue(dialogues[current_index])
		else:
			printerr("No dialogue for index ", current_index)
		current_index += 1
	else:
		await  dialogue(["Your time was-",str(EndlessTimer.passed_time)])
	await create_tween().tween_property(fade, ^"modulate", Color.WHITE, 1.0).finished

	
	if endless == false:
		if current_index >= limitations.size():
			print("U WOOOOOOONNNNNN!!!!!!!!!!!!!!! (like, fr this time)")
			endless = true
			get_tree().change_scene_to_packed(load("res://level/text_screen_end.tscn"))
			#get_tree().change_scene_to_packed(Level.TEXT_SCREENS.back())
		else:
			print("U won!")
			update_health_bar()
			annoyed.emit()
	else:
		EndlessTimer.is_running = false
		EndlessTimer.passed_time = 0.0
		EndlessTimer.is_running = true
		EndlessTimer.start_time = Time.get_ticks_msec() - (EndlessTimer.passed_time * 1000.0)
		annoyed.emit()
