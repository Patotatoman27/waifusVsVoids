extends CharacterBody2D

#Referencias
const ANIMFPS = 16;
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var stateLabel: Label = $StateLabel
@onready var frameLabel: Label = $FrameLabel

#Atributos
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

#States
enum States {idle, fall, jump, doublejump, realfall, walk};
var state : States;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state = States.idle;
	canDoubleJump = false;
	canJump = true;
	direction = 0;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
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
					state = States.walk;
				else:
					state = States.idle;
			JumpLogic(false);
		States.jump:
			velocity.y += (GRAVITY) * delta;
			if velocity.y > -600:
				JumpLogic(true);
			if velocity.y >= 0:
				state = States.fall;
		States.doublejump:
			velocity.y += (GRAVITY) * delta;
			if velocity.y > 0:
				state = States.realfall;
		States.walk:
			DirectionDetection();
			velocity.y = 0;
			velocity.x += direction * ACCELERATION * delta;
			anim.play("Walk");
			if abs(velocity.x) > MAXHSPEED:
				velocity.x = sign(velocity.x) * MAXHSPEED;
			if direction == 0:
				state = States.idle;
			JumpLogic(false);
			
	move_and_slide();
	
	# Betatest
	frameLabel.text = str(int(anim.current_animation_position * ANIMFPS))
	#frameLabel.text = str(velocity.y)
	stateLabel.text = str(States.keys()[state]);

func JumpLogic(isDouble: bool) -> void:
	if Input.is_action_pressed("P1_Jump"):
		if not isDouble:
			quequeJumpFrames = QUEQUEJUMPFRAMES;
			canJump = true;
		else:
			if Input.is_action_just_pressed("P1_Jump"):
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
		state = States.doublejump;
		
func DirectionDetection():
	direction = Input.get_axis("P1_Left", "P1_Right")
