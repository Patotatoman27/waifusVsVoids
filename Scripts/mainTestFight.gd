extends Node

var round : int;
var victoriesP1 : int;
var victoriesP2 : int;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startFight();

func startFight():
	round = 1;
	victoriesP1 = 0;
	victoriesP2 = 0;

func winFight(playerID : int):
	round += 1;
	if playerID == 1:
		victoriesP1 += 1;
	elif playerID == 2:
		victoriesP2 += 1;
			
