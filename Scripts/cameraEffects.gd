extends Node
@onready var camera2D: Camera2D = $"."
var rng = RandomNumberGenerator.new()

func _process(delta: float) -> void:

	var player1: CharacterBody2D = get_node_or_null("../Players/Player1")
	var player2: CharacterBody2D = get_node_or_null("../Players/Player2")
	if player1 != null and player2 != null:
		camera2D.position.x = (player1.position.x + player2.position.x) / 2
		if camera2D.position.x > 1054:
			camera2D.position.x = 1054;
		elif camera2D.position.x < -1054:
			camera2D.position.x = -1054;
		print(camera2D.position.x)
		camera2D.position.y = 381 - abs(player1.position.y - player2.position.y)/3
	else:
		camera2D.position.x = 0


func shake(amount : float, randomStrenght : float, fadeout : float):
	var randomStrngth : float = randomStrenght;
	var fadeOut : float = fadeout;
	var shakeStrngth = randomStrngth;
	_shakeEffect(randomStrngth, fadeOut, shakeStrngth);

func _shakeEffect(randomStrngth, fadeOut, shakeStrngth):
	if shakeStrngth > 0:
		shakeStrngth = lerpf(shakeStrngth, 0, fadeOut);
		camera2D.offset = _randomOffset(shakeStrngth)
		_shakeEffect(randomStrngth, fadeOut, shakeStrngth);

func _randomOffset(shakeStrngth : float) -> Vector2:
	return Vector2(rng.randf_range(-shakeStrngth, shakeStrngth), rng.randf_range(-shakeStrngth, shakeStrngth));
