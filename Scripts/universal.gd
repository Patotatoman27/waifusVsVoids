extends Node

@onready var player1: CharacterBody2D
@onready var player2: CharacterBody2D
@onready var players: Node2D = $"../Players"

func _ready():
	SetCharacters("Blueumann", "Redeumann");

func SetCharacters(char1 : String, char2 : String):
	var nodoPadre = get_node("../Players")
	var escenaP1 = load("res://Scenes/" + char1 + ".tscn");
	var escenaP2 = load("res://Scenes/" + char2 + ".tscn");
	
	var instanciaP1 = escenaP1.instantiate()
	instanciaP1.position = Vector2(-960, -700)
	if nodoPadre:
		nodoPadre.add_child(instanciaP1)
		instanciaP1.name = "Player1";
		player1 = $"../Players/Player1"
		player1.PlayerID = 1;
	else:
		print("No se encontró el nodo ../Players para P1")

	#PLAYER2
	
	var instanciaP2 = escenaP2.instantiate()
	instanciaP2.position = Vector2(960, -700);
	if nodoPadre:
		nodoPadre.add_child(instanciaP2)
		instanciaP2.name = "Player2";
		player2 = $"../Players/Player2"
		player2.PlayerID = 2;
	else:
		print("No se encontró el nodo ../Players para P2")
	
	await get_node("../Players").ready;
	players.fillHealthBar(1, player1.MAXHEALTH)
	players.fillHealthBar(2, player2.MAXHEALTH)
