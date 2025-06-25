extends Node2D

@onready var universal: Node = $"../Universal"
@onready var player1: CharacterBody2D = $Player1
@onready var player2: CharacterBody2D = $Player2

#HealthBars
@onready var P1healthBar: ProgressBar = $"../HUD/P1HittedBar/P1HealthBar"
var P1healthBarStyle = preload("res://Styles/P1HealthBar.tres");
@onready var P1hittedBar: ProgressBar = $"../HUD/P1HittedBar"
@onready var P1hittedDelay: Timer = $"../HUD/P1HittedBar/P1HittedDelay"

@onready var P2healthBar: ProgressBar = $"../HUD/P2HittedBar/P2HealthBar"
var P2healthBarStyle = preload("res://Styles/P2HealthBar.tres");
@onready var P2hittedBar: ProgressBar = $"../HUD/P2HittedBar"
@onready var P2hittedDelay: Timer = $"../HUD/P2HittedBar/P2HittedDelay"

var healthP1 : int;
var healthP2 : int;


func fillHealthBar(player : int, maxhealth : int):
	match player:
		1:
			healthP1 = maxhealth;
			P1healthBar.min_value = 0;
			P1healthBar.max_value = maxhealth;
			P1healthBar.value = maxhealth;
			P1hittedBar.max_value = maxhealth;
			P1hittedBar.value = maxhealth;
		2:
			healthP2 = maxhealth;
			P2healthBar.max_value = maxhealth;
			P2healthBar.value = maxhealth;
			P2hittedBar.max_value = maxhealth;
			P2hittedBar.value = maxhealth;	

func decreaseHealth(player : int, amount : int):
	match player:
		1:
			P1healthBar.value -= amount;
			P1healthBarStyle.bg_color.r = 0.5 + (healthP1 / 200.0)
			if P1healthBar.value <= 0:
				MainTestFight.winFight(1); #Añade puntos
				player1.cantMove();
				player2.cantMove();
				universal.nextRound();
			P1hittedDelay.stop();
			P1hittedDelay.start();
		2:
			P2healthBar.value -= amount;
			P2healthBarStyle.bg_color.r = 0.5 + (healthP2 / 200.0)
			if P2healthBar.value <= 0:
				MainTestFight.winFight(2);
				player1.cantMove();
				player2.cantMove();
				universal.nextRound();
			else:
				P2hittedDelay.stop();
				P2hittedDelay.start();

func _on_p_1_hitted_delay_timeout() -> void:
	correctHittedBar(1, 1);

func _on_p_2_hitted_delay_timeout() -> void:
	correctHittedBar(2, 1);

func correctHittedBar(player : int, amount : int):
	await get_tree().create_timer(0.01).timeout;
	match player:
		1:
			P1hittedBar.value -= amount;
			if P1healthBar.value <= P1hittedBar.value:
				correctHittedBar(1, amount);
		2:
			P2hittedBar.value -= amount;
			if P2healthBar.value <= P2hittedBar.value:
				correctHittedBar(2, amount);
