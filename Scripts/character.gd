class_name Character
extends CharacterBody2D

#Jugador
@export var isplayerOne : bool; #Es jugador uno o no.
var PX : String;

#Referencias //Players
@onready var players = $"..";
@onready var player1: CharacterBody2D = $"../Player1"
@onready var player2: CharacterBody2D = $"../Player2"
var myChar;
var otherChar;
			#//Hit and Hurtboxes
const ANIMFPS = 16;
@onready var anim: AnimationPlayer = $Visual/AnimationPlayer
@onready var visual: Node2D = $Visual
@onready var hurtboxes: Area2D = $Visual/Hurtboxes
@onready var hitboxes: Area2D = $Visual/Hitboxes
@onready var stateLabel: Label = $StateLabel
@onready var frameLabel: Label = $FrameLabel

#Atributos
@export var isFlipped : bool; #Bool. Si el Sprite está flipeado o no.
const MAXHSPEED := 850; #Movimiento Terrestre
const ACCELERATION := 5000;
const ACCEL = 20 #Friccion/Frenado
const FRICTION = 15
const GRAVITY := 2680*2; #Caida
const ADDITIONALGRAVITY := 1250*2;
const JUMPVELOCITY := 1580*1.5;#Salto
const AIRHSPEED := 600;#Horizontal Aereo
const DASHHOLDFRAMES := 3;
const DASHSPEED := 1500;
const AIRFLIPPEDDISTANCE := 100; #Pixeles despues de Vict.Pos.x para que se voltee en el aire.

#Condiciones
var direction : float; #Input.X de jugador. Solo confirmado en X momentos
var originalFlippedState : bool; #Estado de Flipped al dejar el suelo.
var canJump : bool; #Salto
var quequeJumpFrames : int;
const QUEQUEJUMPFRAMES : int = 7;
var canDoubleJump : bool; #DobleSalto
var quequeDoubleJumpFrames : int;
const QUEQUEDOUBLEJUMPFRAMES : int = 5;
var hitstunFrames : float; #Golpes
var dashHoldFrames : int;

#States
enum States {idle, fall, jump, doublejump, realfall, walk, hitstun, dashStart, dash, dashHold};
var state : States;

#Moveset
enum Moveset {nulo, walkKick, jumpKick}
var attack_info = {
	Moveset.walkKick: AttackData.new(5, 3, 0.15, 330, 0),
	Moveset.jumpKick: AttackData.new(30, 7, 0.5, 500, 0)
}
var move : Moveset;



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
