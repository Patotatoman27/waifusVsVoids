extends Node

@onready var player1: CharacterBody2D
@onready var player2: CharacterBody2D
@onready var players: Node2D = $"../Players"
@onready var roundScreen: AnimatedSprite2D = $"../HUD/Node2D/RoundScreen"
@onready var fightAnimation: AnimationPlayer = $"../HUD/Node2D/AnimationPlayer"

var char1 : String = "Greumann";
var char2 : String = "Yeumann";

func _ready():
	SetCharacters(char1, char2);
	roundScreen.play(str(MainTestFight.round));
	await get_tree().create_timer(1.0).timeout;
	fightAnimation.play("RoundX");

func _input(event):
	if event.is_action_pressed("A_Restart"):
		get_tree().reload_current_scene();
	if event.is_action_pressed("A_StartMatch"):
		startMatch();

func startMatch():
	var nodoPadre = get_node("../Players")
	var hijos = nodoPadre.get_children()
	for hijo in hijos:
		if is_instance_valid(hijo):
			hijo.canFinallyMove();

func nextRound():
	if MainTestFight.victoriesP1 == 2 or MainTestFight.victoriesP2 == 2:
		get_tree().change_scene_to_file("res://Scenes/victory.tscn")
	else:
		get_tree().reload_current_scene();

func SetCharacters(char1 : String, char2 : String):
	var nodoPadre = get_node("../Players")
	var hijos = nodoPadre.get_children()
	
	# Vaciar el nodo
	for hijo in hijos:
		if is_instance_valid(hijo):
			hijo.queue_free();
	
	hijos = nodoPadre.get_children()
	if hijos.size() == 0:
		#print("No tiene hijos")
		GeneratePlayers()
	else:
		for hijo in hijos:
			print(hijo.name);
			SetCharacters(char1, char2)

func GeneratePlayers():
	var nodoPadre = get_node("../Players")
	var escenaP1 = load("res://Scenes/Characters/" + char1 + ".tscn");
	var escenaP2 = load("res://Scenes/Characters/" + char2 + ".tscn");
	
	#PLAYER1
	var instanciaP1 = escenaP1.instantiate()
	instanciaP1.position = Vector2(-960, -700)
	if nodoPadre:
		nodoPadre.add_child(instanciaP1)
		instanciaP1.name = "Player1";
		player1 = $"../Players/Player1"
		player1.PlayerID = 1;
		#print("Player 1 ID: " + str(player1.PlayerID));
	else:
		print("Error: No se encontró el nodo ../Players para P1")

	#PLAYER2
	var instanciaP2 = escenaP2.instantiate()
	instanciaP2.position = Vector2(960, -700);
	if nodoPadre:
		nodoPadre.add_child(instanciaP2)
		instanciaP2.name = "Player2";
		player2 = $"../Players/Player2"
		player2.PlayerID = 2;
		#print("Player 2 ID: " + str(player2.PlayerID));
	else:
		print("Error: No se encontró el nodo ../Players para P2")
	
	#SET PLAYERS HEALTH
	await get_node("../Players").ready;
	players.fillHealthBar(1, player1.MAXHEALTH)
	players.fillHealthBar(2, player2.MAXHEALTH)
