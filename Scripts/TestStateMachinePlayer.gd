extends CharacterBody2D

#Jugador
@export var isplayerOne : bool;
var PX : String;

#Referencias
@onready var players = $"..";
@onready var player1: CharacterBody2D = $"../Player1"
@onready var player2: CharacterBody2D = $"../Player2"

const ANIMFPS = 16;
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var hurtboxes: Area2D = $Hurtboxes
@onready var hitboxes: Area2D = $Hitboxes
@onready var stateLabel: Label = $StateLabel
@onready var frameLabel: Label = $FrameLabel

#Atributos
@export var flipLabelDebug : bool;
const GRAVITY := 2680*2;
const JUMPVELOCITY := 1580*1.5;
const ADDITIONALGRAVITY := 1250*2;
const ACCELERATION := 5000;
const MAXHSPEED := 850;
const AIRHSPEED := 600;

#Condiciones
var canJump : bool;
var quequeJumpFrames : int;
const QUEQUEJUMPFRAMES : int = 7;
var canDoubleJump : bool;
var quequeDoubleJumpFrames : int;
const QUEQUEDOUBLEJUMPFRAMES : int = 5;
var direction : float;
var hitstunFrames : float;

#States
enum States {idle, fall, jump, doublejump, realfall, walk, hitstun};
enum Moveset {nulo, walkKick, jumpKick}
var state : States;
var move : Moveset;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Estado y condiciones iniciales
	state = States.idle;
	move = Moveset.nulo;
	canDoubleJump = false;
	canJump = true;
	direction = 0;
	
	#Jugador actual
	if isplayerOne:
		PX = "P1";
		#Collision Layers de Hitbox/Hurtbox:
		hitboxes.collision_layer = 1 << 2
		hurtboxes.collision_layer = 1 << 3
		hitboxes.collision_mask = 1 << 5
		hurtboxes.collision_mask = 1 << 4
	else:
		PX = "P2";
		#Collision Layers de Hitbox/Hurtbox:
		hitboxes.collision_layer = 1 << 4
		hurtboxes.collision_layer = 1 << 5
		hitboxes.collision_mask = 1 << 3
		hurtboxes.collision_mask = 1 << 2
	
	
	#Labels de Debug
	if flipLabelDebug:
		stateLabel.scale *= Vector2(-1,1)
		frameLabel.scale *= Vector2(-1,1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Hit management
	#State management
	match state:
		States.hitstun:
			#print("en Hitstun: " + str(hitstunFrames));
			frameLabel.text = str(int(floor(hitstunFrames)));
			hitstunFrames -= ANIMFPS * delta;
			if hitstunFrames <= 0:
				if is_on_floor():
					state = States.idle;
				else:
					state = States.fall;
		States.idle:
			DirectionDetection();
			velocity.x = 0;
			velocity.y = 0;
			anim.play("Idle");
			if not is_on_floor():
				state = States.fall;
			if direction != 0:
				state = States.walk;
			JumpLogic(false);
		States.walk:
			move = Moveset.walkKick
			DirectionDetection();
			velocity.y = 0;
			velocity.x += direction * ACCELERATION * delta;
			if abs(velocity.x) > MAXHSPEED:
				velocity.x = sign(velocity.x) * MAXHSPEED;
			anim.play("Walk");
			if not is_on_floor():
				move = Moveset.nulo;
				state = States.fall;
			if direction == 0:
				move = Moveset.nulo;
				state = States.idle;
			JumpLogic(false);
		States.jump:
			velocity.y += (GRAVITY) * delta;
			if velocity.y > -600:
				JumpLogic(true);
			if velocity.y >= 0:
				state = States.fall;
		States.doublejump:
			move = Moveset.jumpKick
			velocity.y += (GRAVITY) * delta;
			if velocity.y > 0:
				state = States.realfall;
		States.fall:
			velocity.y += (GRAVITY + ADDITIONALGRAVITY ) * delta;
			if is_on_floor():
				DirectionDetection()
				if direction != 0:
					state = States.walk;
				else:
					state = States.idle;
			JumpLogic(true);
		States.realfall:
			velocity.y += (GRAVITY + ADDITIONALGRAVITY ) * delta;
			if is_on_floor():
				DirectionDetection()
				if direction != 0:
					move = Moveset.nulo;
					state = States.walk;
				else:
					move = Moveset.nulo;
					state = States.idle;
			JumpLogic(false);
			
	move_and_slide();
	
	# Betatest
	if state != States.hitstun:
		frameLabel.text = str(int(anim.current_animation_position * ANIMFPS))
	#frameLabel.text = str(velocity.y)
	stateLabel.text = str(States.keys()[state]);

func JumpLogic(isDouble: bool) -> void:
	if Input.is_action_pressed(PX + "_Jump"):
		if not isDouble:
			quequeJumpFrames = QUEQUEJUMPFRAMES;
			canJump = true;
		else:
			if Input.is_action_just_pressed(PX + "_Jump"):
				quequeDoubleJumpFrames = QUEQUEDOUBLEJUMPFRAMES;
				canDoubleJump = true;
	else:
		if quequeJumpFrames > 0:
			quequeJumpFrames -= 1;
		elif quequeJumpFrames == 0:
			canJump = false;
		if quequeDoubleJumpFrames > 0:
			quequeDoubleJumpFrames -= 1;
		elif quequeDoubleJumpFrames == 0:
			canDoubleJump = false;
			
	if is_on_floor() and canJump and not isDouble:
		velocity.y = -JUMPVELOCITY;
		quequeJumpFrames = 0;
		DirectionDetection()
		if direction != 0:
			if direction > 0:
				velocity.x = AIRHSPEED
			else:
				velocity.x = -AIRHSPEED
		move = Moveset.nulo;
		state = States.jump;
	if canDoubleJump and isDouble:
		velocity.y = -JUMPVELOCITY * 0.8;
		quequeJumpFrames = 0;
		DirectionDetection()
		if direction != 0:
			if direction > 0:
				velocity.x = AIRHSPEED
			else:
				velocity.x = -AIRHSPEED
		else:
			velocity.x = 0;
		move = Moveset.nulo;
		state = States.doublejump;
		
func DirectionDetection():
	direction = Input.get_axis(PX + "_Left", PX + "_Right")


func _on_hurtboxes_area_entered(area: Area2D) -> void:
	if state != States.hitstun:
		print("Golpe: ")
		if isplayerOne:
			print(Moveset.keys()[player2.move])
			match player2.move:
				Moveset.walkKick:
					players.decreaseHealth(1, 5);
					hitstunFrames = 14;
					state = States.hitstun;
					Hitstop.hitStop(0.15)
				Moveset.jumpKick:
					players.decreaseHealth(1, 30);
					hitstunFrames = 7;
					state = States.hitstun;
					Hitstop.hitStop(0.5)
		else:
			print(Moveset.keys()[player1.move])
			match player1.move:
				Moveset.walkKick:
					players.decreaseHealth(2, 5);
					hitstunFrames = 14;
					state = States.hitstun;
					Hitstop.hitStop(0.15)
				Moveset.jumpKick:
					players.decreaseHealth(2, 30);
					hitstunFrames = 7;
					state = States.hitstun;
					Hitstop.hitStop(0.5)
