extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

#Atributos
const SPEED = 400.0
@export var JUMP_VELOCITY = -400.0;
const QUEQUE_JUMP_FRAMES = 10;
const GRAVITY = 1580;
const ACCELERATION = 5000
const FRICTION = 9999

#Condiciones
var quequedJump : bool;
var quequedJumpFrames : int;
var additionalGravity;

#States
var state = "idle"  # Estado actual
var direction := 0.0

func _ready() -> void:
	quequedJump = false;
	additionalGravity = 0;

func _physics_process(delta: float) -> void:
	match state:
		"idle":
			update_input()
			velocity.x = 0
			if anim.animation != "idle":
				anim.play("idle")
			#Change
			jumpLogic()
			if direction != 0:
				state = "walk"
			if not is_on_floor():
				state = "falling"
		"walk":
			update_input()
			velocity.x += direction * ACCELERATION * delta
			if abs(velocity.x) > SPEED:
				velocity.x = sign(velocity.x) * SPEED
			if anim.animation != state:
				anim.play(state)
			#Change
			if direction == 0:
				state = "idle"
			jumpLogic();

		"jump":
			update_input()
			velocity.x = direction * SPEED * 0.8
			if not is_on_floor():
				velocity.y += (GRAVITY + additionalGravity) * delta;
				if velocity.y > 0:
					additionalGravity += 150;
			else:
				additionalGravity = 0;
			anim.play("idle")
			#Change
			if is_on_floor():
				state = "idle"
		"falling":
			update_input()
			velocity.x = direction * SPEED
			velocity.y += (GRAVITY + additionalGravity) * delta;
			#Change
			if not is_on_floor():
				velocity.y += (GRAVITY + additionalGravity) * delta;
				if velocity.y > 0:
					additionalGravity += 50;
			else:
				additionalGravity = 0;
				state = "idle"
	
	move_and_slide()
	


func update_input():
	direction = Input.get_axis("P1_Left", "P1_Right")
	if state == "jump" and velocity.y == 0 and is_on_floor():
		state = "idle"
	jumpLogic();
		
func jumpLogic():
	if Input.is_action_just_pressed("P1_Jump"):
		quequedJump = true;
		quequedJumpFrames = QUEQUE_JUMP_FRAMES;
	if quequedJump:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			quequedJump = false;
			state = "jump";
		else:
			quequedJumpFrames -= 1;
			if quequedJumpFrames <= 0:
				quequedJump = false;
