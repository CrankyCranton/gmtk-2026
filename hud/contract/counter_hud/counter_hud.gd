class_name CounterHud extends TextureRect


const TYPE_ICONS: Dictionary[String, Texture2D] = {
	"ammo": preload("uid://dtb17ym3n8vo8"),
	"dashes": preload("uid://dl7bj25frbcxs"),
	"grappling_hooks": preload("uid://capwe5i801dju"),
	"health": preload("uid://g7n3eo2i6qim"),
	#"jumps": preload("uid://cac4awpdhhnif"),
	"air_jumps": preload("uid://6gnxtueb3hwa"),
	"enemies": preload("uid://gqoq3ted3u7"),
	"time": preload("uid://cu1ayho6x7j4w"),
}

@onready var icon: TextureRect = $Icon
@onready var counter: Label = $Counter
@onready var placeholder_text: Label = %PlaceholderText


func set_type(type: String) -> void:
	if placeholder_text == null or icon == null:
		await get_tree().process_frame
	if TYPE_ICONS.has(type):
		icon.texture = TYPE_ICONS[type]
	else:
		placeholder_text.text = type


func set_counter(count: int) -> void:
	if counter == null:
		await get_tree().process_frame
	counter.text = "∞" if count == -1 else str(count)
