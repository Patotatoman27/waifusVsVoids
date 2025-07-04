extends Node

@onready var player1: CharacterBody2D
@onready var player2: CharacterBody2D
@onready var players: Node2D = $"../Players"
@onready var roundScreen: AnimatedSprite2D = $"../HUD/Node2D/RoundScreen"
@onready var fightAnimation: AnimationPlayer = $"../HUD/Node2D/AnimationPlayer"
@onready var roundHUD: Label = $"../HUD/Round"
@onready var p1RoundHUD: Label = $"../HUD/P1Rounds"
@onready var p2RoundHUD: Label = $"../HUD/P2Rounds"
@onready var MainTestFight;

const CHARACTERS_SPAWN_X = 660;
const CHARACTERS_SPAWN_Y = -700;

func _ready() -> void:
	MainTestFight = get_parent().get_parent();

func _input(event):
	if event.is_action_pressed("A_StartMatch"):
		startMatch();

func startFight(char1 : String, char2 : String):
	SetCharacters(char1, char2);
	UpdateRoundHUD();
	roundScreen.play(str(MainTestFight.roundNumber));
	#SET PLAYERS HEALTH
	#await get_node("../Players").ready;
	fillPlayersHealth();
	await get_tree().create_timer(1.0).timeout;
	fightAnimation.play("RoundX");

func startMatch(): #Llamada por la animación de FIGHT!!
	var nodoPadre = get_node("../Players")
	var hijos = nodoPadre.get_children()
	for hijo in hijos:
		if is_instance_valid(hijo):
			hijo.canFinallyMove();

func nextRound():
	await get_tree().create_timer(3).timeout;
	if MainTestFight.victoriesP1 == 2 or MainTestFight.victoriesP2 == 2:
		MainTestFight.victory();
	else:
		UpdateRoundHUD();
		fillPlayersHealth();
		positionPlayers();
		roundScreen.play(str(MainTestFight.roundNumber));
		await get_tree().create_timer(1.0).timeout;
		fightAnimation.play("RoundX");

func UpdateRoundHUD():
	roundHUD.text = str(MainTestFight.roundNumber);
	p1RoundHUD.text = str(MainTestFight.victoriesP1);
	p2RoundHUD.text = str(MainTestFight.victoriesP2);

func SetCharacters(char1 : String, char2 : String):
	var nodoPadre = get_node("../Players")
	var escenaP1 = load("res://Scenes/Characters/" + char1 + ".tscn");
	var escenaP2 = load("res://Scenes/Characters/" + char2 + ".tscn");
	
	#PLAYER1
	var instanciaP1 = escenaP1.instantiate()
	instanciaP1.position = Vector2(-CHARACTERS_SPAWN_X, CHARACTERS_SPAWN_Y)
	if nodoPadre:
		instanciaP1.name = "Player1";
		instanciaP1.PlayerID = 1;
		nodoPadre.add_child(instanciaP1)
		player1 = $"../Players/Player1"
		#print("Player 1 ID: " + str(player1.PlayerID));
	else:
		print("Error: No se encontró el nodo ../Players para P1")

	#PLAYER2
	var instanciaP2 = escenaP2.instantiate()
	instanciaP2.position = Vector2(CHARACTERS_SPAWN_X, CHARACTERS_SPAWN_Y);
	if nodoPadre:
		instanciaP2.name = "Player2";
		instanciaP2.PlayerID = 2;
		nodoPadre.add_child(instanciaP2)
		player2 = $"../Players/Player2"
		#print("Player 2 ID: " + str(player2.PlayerID));
	else:
		print("Error: No se encontró el nodo ../Players para P2")


func fillPlayersHealth():
	players.fillHealthBar(1, player1.MAXHEALTH)
	players.fillHealthBar(2, player2.MAXHEALTH)

func positionPlayers():
	player1.position = Vector2(-CHARACTERS_SPAWN_X, CHARACTERS_SPAWN_Y)
	player2.position = Vector2(CHARACTERS_SPAWN_X, CHARACTERS_SPAWN_Y)
	player1.flippedRevision();
	player2.flippedRevision();
	
