extends CharacterBody2D

#Jugador
@export var isplayerOne : bool;
var PX : String;

#Referencias //Players
@onready var players = $"..";
@onready var player1: CharacterBody2D = $"../Player1"
@onready var player2: CharacterBody2D = $"../Player2"
			#//Hit and Hurtboxes
const ANIMFPS = 16;
@onready var anim: AnimationPlayer = $Visual/AnimationPlayer
@onready var visual: Node2D = $Visual
@onready var hurtboxes: Area2D = $Visual/Hurtboxes
@onready var hitboxes: Area2D = $Visual/Hitboxes
@onready var stateLabel: Label = $StateLabel
@onready var frameLabel: Label = $FrameLabel

#Atributos
@export var isFlipped : bool;
const MAXHSPEED := 850;
const ACCEL = 20
const FRICTION = 15
const GRAVITY := 2680*2;
const JUMPVELOCITY := 1580*1.5;
const ADDITIONALGRAVITY := 1250*2;
const ACCELERATION := 5000;
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
var state : States;

#Moveset
enum Moveset {nulo, walkKick, jumpKick}
var attack_info = {
	Moveset.walkKick: AttackData.new(5, 14, 0.15, 330, 0),
	Moveset.jumpKick: AttackData.new(30, 7, 0.5, 500, 0)
}
var move : Moveset;


#READY
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


#PROCESS
func _process(delta: float) -> void:
	#Hit management
	#State management
	match state:
		States.hitstun:
			#print("en Hitstun: " + str(hitstunFrames));
			frameLabel.text = str(int(floor(hitstunFrames)));
			direction = 0;
			if not is_on_floor():
				velocity.y += (GRAVITY + ADDITIONALGRAVITY ) * delta;
			hitstunFrames -= ANIMFPS * delta;
			anim.play("Idle");
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
			anim.play("WalkKick");
			if not is_on_floor():
				move = Moveset.nulo;
				state = States.fall;
			if direction == 0:
				move = Moveset.nulo;
				state = States.idle;
			JumpLogic(false);
		States.jump:
			velocity.y += (GRAVITY) * delta;
			anim.play("Walk");
			if velocity.y > -600:
				JumpLogic(true);
			if velocity.y >= 0:
				state = States.fall;
		States.doublejump:
			move = Moveset.jumpKick
			velocity.y += (GRAVITY) * delta;
			anim.play("WalkKick");
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

	if abs(direction) > 0.01:
		velocity.x = lerp(velocity.x, direction * MAXHSPEED, ACCEL * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)
	move_and_slide();
	if isFlipped:
		visual.scale.x = -1.0
	else:
		visual.scale.x = 1.0
	
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
	direction = Input.get_action_strength(PX + "_Right") - Input.get_action_strength(PX + "_Left")


func _on_hurtboxes_area_entered(area: Area2D) -> void:
	if state != States.hitstun:
		var attacker
		var victimID
		var victim; 
		if isplayerOne:
			attacker = player2;
			victimID = 1;
			victim = player1;
		else:
			attacker = player1;
			victimID = 2;
			victim = player2;

		var move = attacker.move;

		print(Moveset.keys()[move])
		if move != 0:
			var data: AttackData = attack_info[move]
			players.decreaseHealth(victimID, data.damage)
			var VictimDirection;
			if victim.isFlipped:
				VictimDirection = -1;
			else:
				VictimDirection = 1;
			victim.velocity.x += VictimDirection * -data.knockbackH
			hitstunFrames = data.hitstun
			state = States.hitstun
			Hitstop.hitStop(data.hitstop)
			

	#if state != States.hitstun:
		#print("Golpe: ")
		#if isplayerOne:
			#print(Moveset.keys()[player2.move])
			#match player2.move:
				#Moveset.walkKick:
					#players.decreaseHealth(1, 5);
					#hitstunFrames = 14;
					#state = States.hitstun;
					#Hitstop.hitStop(0.15)
				#Moveset.jumpKick:
					#players.decreaseHealth(1, 30);
					#hitstunFrames = 7;
					#state = States.hitstun;
					#Hitstop.hitStop(0.5)
		#else:
			#print(Moveset.keys()[player1.move])
			#match player1.move:
				#Moveset.walkKick:
					#players.decreaseHealth(2, 5);
					#hitstunFrames = 14;
					#state = States.hitstun;
					#Hitstop.hitStop(0.15)
				#Moveset.jumpKick:
					#players.decreaseHealth(2, 30);
					#hitstunFrames = 7;
					#state = States.hitstun;
					#Hitstop.hitStop(0.5)
