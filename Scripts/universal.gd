extends Node

@onready var player1: CharacterBody2D
@onready var player2: CharacterBody2D

func _ready():
	SetCharacters();

func SetCharacters():
	var escenaP1 = preload("res://Scenes/Neumann.tscn")
	var escenaP2 = preload("res://Scenes/Neumann.tscn")
	var instanciaP1 = escenaP1.instantiate()
	instanciaP1.position = Vector2(-960, -700)

	var nodoPadre = get_node("../Players")
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
