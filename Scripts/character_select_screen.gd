extends Node2D

@onready var p1Select: Sprite2D = $P1Select
@onready var p2Select: Sprite2D = $P2Select
var p1State : int = 0;
var p2State : int = 0;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	p1Select.visible = false;
	p2Select.visible = false;

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("P1_Select"):
		if p1State == 0:
			p1Select.visible = true;
			p1State = 1;
			Global.p1char = "Neumann";
		elif p1State == 1:
			p1State = 2;
			if p2State == 2:
				get_tree().change_scene_to_file("res://Scenes/mainGame.tscn")
	if event.is_action_pressed("P2_Select"):
		if p2State == 0:
			p2Select.visible = true;
			p2State = 1;
			Global.p2char = "Neumann";
		elif p2State == 1:
			p2State = 2;
			if p1State == 2:
				get_tree().change_scene_to_file("res://Scenes/mainGame.tscn")
			
