extends Node2D

#Health
@onready var P1healthBar: ProgressBar = $"../CanvasLayer/P1HittedBar/P1HealthBar"
var P1healthBarStyle = preload("res://Styles/P1HealthBar.tres");
@onready var P1hittedBar: ProgressBar = $"../CanvasLayer/P1HittedBar"
@onready var P1hittedDelay: Timer = $"../CanvasLayer/P1HittedBar/P1HittedDelay"

@onready var P2healthBar: ProgressBar = $"../CanvasLayer/P2HittedBar/P2HealthBar"
var P2healthBarStyle = preload("res://Styles/P2HealthBar.tres");
@onready var P2hittedBar: ProgressBar = $"../CanvasLayer/P2HittedBar"
@onready var P2hittedDelay: Timer = $"../CanvasLayer/P2HittedBar/P2HittedDelay"

var healthP1 : int;
var healthP2 : int;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fillHealthBar(0, 100);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_B):
		decreaseHealth(1, 1);

func fillHealthBar(player : int, maxhealth : int):
	match player:
		1:
			healthP1 = maxhealth;
			P1healthBar.value = maxhealth;
			P1healthBar.max_value = maxhealth;
			P1hittedBar.value = maxhealth;
			P1hittedBar.max_value = maxhealth;
		2:
			healthP2 = maxhealth;
			P2healthBar.value = maxhealth;
			P2healthBar.max_value = maxhealth;
			P2hittedBar.value = maxhealth;
			P2hittedBar.max_value = maxhealth;
		0:
			fillHealthBar(1, maxhealth);
			fillHealthBar(2, maxhealth);

func decreaseHealth(player : int, amount : int):
	match player:
		1:
			P1healthBar.value -= amount;
			P1healthBarStyle.bg_color.r = 0.5 + (healthP1 / 200.0)
			P1hittedDelay.stop();
			P1hittedDelay.start();
		2:
			P2healthBar.value -= amount;
			P2healthBarStyle.bg_color.r = 0.5 + (healthP2 / 200.0)
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
