extends CharacterBody2D

#Jugador
@export var PlayerID : int; #ID del Jugador

#Referencias //Players
@onready var players = $"..";
@onready var player1: CharacterBody2D = $"../Player1"
@onready var player2: CharacterBody2D = $"../Player2"
var myChar;
var otherChar; #Siempre comprobar su existencia

#Animacion Hit y Hurtboxes
@onready var anim: AnimationPlayer = $Visual/AnimationPlayer
@onready var visual: Node2D = $Visual
@onready var hurtboxes: Area2D = $Visual/Hurtboxes
@onready var hitboxes: Area2D = $Visual/Hitboxes
@onready var stateLabel: Label = $StateLabel
@onready var frameLabel: Label = $FrameLabel

#Atributos Universales
const ANIMFPS = 16;
const AIRFLIPPEDDISTANCE := 100; #Pixeles despues de Vict.Pos.x para que se voltee en el aire.
const QUEQUEJUMPFRAMES : int = 7;
const QUEQUEDOUBLEJUMPFRAMES : int = 5;

#Atributos
const MAXHEALTH := 300;
const MAXHSPEED := 850; #Movimiento Terrestre
const ACCELERATION := 5000;
const ACCEL = 20; #Friccion/Frenado
const FRICTION = 15;
const GRAVITY := 5360; #Caida
const ADDITIONALGRAVITY := 2500;
const JUMPVELOCITY := 2370; #Salto
const AIRHSPEED := 600; #Horizontal Aereo
const DASHHOLDFRAMES := 2;
const DASHSPEED := 2500;

#Condiciones
@export var isFlipped : bool; #Bool. Si el Sprite está flipeado o no.
var direction : float; #Input.X de jugador. Solo confirmado en X momentos
var originalFlippedState : bool; #Estado de Flipped al dejar el suelo.
var canJump : bool; #Salto
var quequeJumpFrames : int; #Cuantos frames lleva el Salto en Que
var canDoubleJump : bool; #DobleSalto
var quequeDoubleJumpFrames : int; #Cuantos frames lleva el doble salto en Que
var hitstunFrames : float; #Golpes
var dashHoldFrames : int; #Cuantos frames lleva en el hold final del Dash
var canMove : bool; #Si puede salir o no de idle

#States
enum States {cantMove, cantMoveFell, idle, fall, jump, doublejump, realfall, walk, hitstun, dashStart, dash, dashHold};
var state : States;

#Moveset
enum Moveset {nulo, walkKick, jumpKick}
var attack_info = {
	#Damage, Hitstun, Hitstop, KnockbackX, KnockbackY
	Moveset.walkKick: AttackData.new(5, 3, 0.15, 330, 0),
	Moveset.jumpKick: AttackData.new(30, 7, 0.4, 500, 0)
}
var move : Moveset;



#READY
func _ready() -> void:
	#Estado y condiciones iniciales
	state = States.cantMove;
	move = Moveset.nulo;
	canDoubleJump = false;
	canJump = true;
	canMove = false;
	direction = 0;
	
	#Jugador actual
	if PlayerID == 1:
		myChar = player1;
		otherChar = player2;
		#Collision Layers de Hitbox/Hurtbox:
		hitboxes.collision_layer = 1 << 2
		hurtboxes.collision_layer = 1 << 3
		hitboxes.collision_mask = 1 << 5
		hurtboxes.collision_mask = 1 << 4
		isFlipped = false;
	else:
		myChar = player2;
		otherChar = player1;
		#Collision Layers de Hitbox/Hurtbox:
		hitboxes.collision_layer = 1 << 4
		hurtboxes.collision_layer = 1 << 5
		hitboxes.collision_mask = 1 << 3
		hurtboxes.collision_mask = 1 << 2
		isFlipped = true;
	if myChar == player1:
		if get_node_or_null("../Player2") and get_node("../Player2").is_inside_tree():
			await get_node("../Player2").ready
	else:
		if get_node_or_null("../Player1") and get_node("../Player1").is_inside_tree():
			await get_node("../Player1").ready;


#PROCESS
func _process(delta: float) -> void:
	#State management
	match state:
		States.cantMove:
			anim.play("Idle");
			if not is_on_floor():
				state = States.cantMoveFell;
			if canMove == true:
				state = States.idle;
		States.cantMoveFell:
			velocity.y += (GRAVITY + ADDITIONALGRAVITY ) * delta;
			anim.play("Walk");
			if is_on_floor():
				state = States.cantMove;
			if canMove == true:
				state = States.fall;
		States.hitstun:
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
			if otherChar != null and is_instance_valid(otherChar) and otherChar.is_inside_tree():
				isFlipped = (otherChar.position.x < myChar.position.x)
			velocity.x = 0;
			velocity.y = 0;
			anim.play("Idle");
			if not is_on_floor():
				state = States.fall;
			if direction != 0:
				state = States.walk;
			FlippedOriginalStateDetection() #Solo en los que salen del suelo
			JumpLogic(false);
			DashLogic();
		States.walk:
			move = Moveset.walkKick
			DirectionDetection();
			if is_instance_valid(otherChar):
				isFlipped = (otherChar.position.x < myChar.position.x);
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
			FlippedOriginalStateDetection();
			JumpLogic(false);
			DashLogic();
		States.dashStart:
			velocity = Vector2(0,0);
			anim.play("Dash");
			DirectionDetection();
			state = States.dash;
		States.dash:
			if direction < 0 or (direction == 0 and isFlipped):
				velocity.x = -DASHSPEED;
			elif direction > 0  or (direction == 0 and not isFlipped):
				velocity.x = DASHSPEED;
			velocity.y = 0;
			if int(anim.current_animation_position * ANIMFPS) >= 6:
				dashHoldFrames = 0;
				state = States.dashHold;
		States.dashHold:
			velocity.x = 0;
			velocity.y = 0;
			dashHoldFrames += 1;
			if dashHoldFrames >= DASHHOLDFRAMES:
				DirectionDetection();
				AirDirectionLogic();
				if is_on_floor():
					state = States.idle;
				else:
					state = States.realfall;
		States.jump:
			velocity.y += (GRAVITY) * delta;
			anim.play("Walk");
			if velocity.y > -600:
				JumpLogic(true);
			if velocity.y >= 0:
				state = States.fall;
			AirDirectionLogic();
			DashLogic();
		States.doublejump:
			move = Moveset.jumpKick
			velocity.y += (GRAVITY) * delta;
			anim.play("WalkKick");
			if velocity.y > 0:
				state = States.realfall;
			AirDirectionLogic();
		States.fall:
			velocity.y += (GRAVITY + ADDITIONALGRAVITY ) * delta;
			anim.play("Walk");
			if is_on_floor():
				DirectionDetection()
				if direction != 0:
					state = States.walk;
				else:
					state = States.idle;
			JumpLogic(true);
			AirDirectionLogic();
			DashLogic();
		States.realfall:
			velocity.y += (GRAVITY + ADDITIONALGRAVITY ) * delta;
			anim.play("Walk");
			if is_on_floor():
				DirectionDetection()
				if direction != 0:
					move = Moveset.nulo;
					state = States.walk;
				else:
					move = Moveset.nulo;
					state = States.idle;
			JumpLogic(false);
			AirDirectionLogic();

	if abs(direction) > 0.01:
		velocity.x = lerp(velocity.x, direction * MAXHSPEED, ACCEL * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)
	move_and_slide();
	visual.scale.x = 1.0 - 2.0 * int(isFlipped)
	
	# Betatest
	if state != States.hitstun:
		frameLabel.text = str(int(anim.current_animation_position * ANIMFPS))
	#frameLabel.text = str(velocity.y)
	stateLabel.text = str(States.keys()[state]);

func JumpLogic(isDouble: bool) -> void:
	if Input.is_action_pressed("P" + str(PlayerID) + "_Jump"):
		if not isDouble:
			quequeJumpFrames = QUEQUEJUMPFRAMES;
			canJump = true;
		else:
			if Input.is_action_just_pressed("P" + str(PlayerID) + "_Jump"):
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

func _on_hurtboxes_area_entered(area: Area2D) -> void:
	#if state != States.hitstun:
		var hitMove
		if is_instance_valid(otherChar):
			hitMove = otherChar.move;
		var hitStun = 50 + int(floor(20.5));
		print(Moveset.keys()[hitMove]) #Que Movimiento impactó
		if hitMove != 0:
			var data: AttackData = attack_info[hitMove]
			players.decreaseHealth(PlayerID, data.damage)
			var VictimDirection;
			if myChar.isFlipped:
				VictimDirection = -1;
			else:
				VictimDirection = 1;
			myChar.velocity.x += VictimDirection * -data.knockbackH
			hitstunFrames = data.hitstun
			state = States.hitstun
			Hitstop.hitStop(data.hitstop)


func DirectionDetection():
	direction = Input.get_action_strength("P" + str(PlayerID) + "_Right") - Input.get_action_strength("P" + str(PlayerID) + "_Left")

func AirDirectionLogic():
	if is_instance_valid(otherChar):
		if originalFlippedState:
			isFlipped = (otherChar.position.x - AIRFLIPPEDDISTANCE) < myChar.position.x;
		else:
			isFlipped = (otherChar.position.x + AIRFLIPPEDDISTANCE) < myChar.position.x;

func FlippedOriginalStateDetection():
	originalFlippedState = isFlipped;

func DashLogic():
	if Input.is_action_just_pressed("P" + str(PlayerID) + "_Dash"):
		state = States.dashStart;

func killMyself(): #alch no recuerdo si esto se usa o no, pero aca lo dejo
	call_deferred("free")

func canFinallyMove():
	canMove = true;
	
func cantMove():
	canMove = false;
	state = States.cantMove
