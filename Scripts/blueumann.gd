extends Character


func _ready() -> void:
	super._ready();
	MAXHSPEED = 100;

func _physics_process(delta: float) -> void:
#State management
	match state:
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
			stateDoubleJump(delta);
		States.fall:
			stateFall(delta);
		States.realfall:
			stateRealFall(delta);
	applyMovement(delta);
