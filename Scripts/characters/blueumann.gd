extends Character

func _ready() -> void:
	super._ready();
	MAXHSPEED = 300;

func _physics_process(delta: float) -> void:
#State management
	match state:
		States.cantMove:
			stateCantMove();
		States.cantMoveFell:
			stateCantMoveFell(delta);
		States.hitstun:
			stateHitstun(delta);
		States.idle:
			stateIdle();
		States.walk:
			stateWalk(delta);
		States.dashStart:
			stateDashStart();
		States.dash:
			stateDash(delta);
		States.dashHold:
			stateDashHold();
		States.jump:
			stateJump(delta);
		States.doublejump:
			move = Moveset.testJumpKick
			stateDoubleJump(delta);
		States.fall:
			stateFall(delta);
		States.realfall:
			stateRealFall(delta);
	applyMovement(delta);
