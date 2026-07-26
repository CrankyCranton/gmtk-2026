extends Node


var start_time : float = 0.0
var passed_time : float = 0.0
var is_running : bool = false
var level = null


func _process(_delta):
	if is_running:
		passed_time = (Time.get_ticks_msec() - start_time) / 1000.0
