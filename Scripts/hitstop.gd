extends Node


func hitStop(amount : float):
	Engine.time_scale = 0;
	await get_tree().create_timer(amount, true, false, true).timeout
	Engine.time_scale = 1;
	
