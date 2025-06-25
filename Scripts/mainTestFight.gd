extends Node

const MainTestStage = preload("res://Scenes/mainTestStage.tscn")

var roundNumber : int;
var victoriesP1 : int;
var victoriesP2 : int;
var MTS; #Aqui va el MainTestStage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setUpFight("Blueumann", "Blueumann", "MainTheme");

func setUpFight(char1 : String, char2 : String, music : String):
	roundNumber = 1;
	victoriesP1 = 0;
	victoriesP2 = 0;
	Music.play(music);
	#Generate Stage
	var instance = MainTestStage.instantiate();
	instance.name = "MainTestStage";
	add_child(instance);
	MTS = get_node_or_null("MainTestStage")
	var universal = MTS.get_node_or_null("Universal")
	universal.startFight(char1, char2)


func winFight(playerID : int):
	roundNumber += 1;
	if playerID == 1:
		victoriesP1 += 1;
	elif playerID == 2:
		victoriesP2 += 1;
	

func victory():
	get_tree().change_scene_to_file("res://Scenes/victory.tscn")
