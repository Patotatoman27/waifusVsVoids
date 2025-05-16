extends CharacterBody2D

const SPEED = 400.0
@export var JUMP_VELOCITY = -400.0;
const QUEQUE_JUMP_FRAMES = 10;
const GRAVITY = Vector2(0, 1580);
const ACCELERATION = 5000
const FRICTION = 9999

var quequedJump : bool;
var quequedJumpFrames : int;
var additionalGravity;

func _ready() -> void:
	quequedJump = false;
	additionalGravity = 0;

func _physics_process(delta: float) -> void:
	
	# Gravedad. Añade gravedad adicional si estás cayendo
	if not is_on_floor():
		velocity.y += (GRAVITY.y + additionalGravity) * delta;
		if velocity.y > 0:
			additionalGravity += 150;
	else:
		additionalGravity = 0;

	# Salto. Al darle al boton de salto guardalo hasta que sea usable por x frames.
	if Input.is_action_just_pressed("P1_Jump"):
		quequedJump = true;
		quequedJumpFrames = QUEQUE_JUMP_FRAMES;
	if quequedJump:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			quequedJump = false;
		else:
			quequedJumpFrames -= 1;
			if quequedJumpFrames <= 0:
				quequedJump = false;

	#Movimiento horizontal
	var direction := Input.get_axis("P1_Left", "P1_Right")

	if direction != 0:
		velocity.x += direction * ACCELERATION * delta
		if abs(velocity.x) > SPEED:
			velocity.x = sign(velocity.x) * SPEED
	else:
		velocity.x = 0
	
	move_and_slide()
