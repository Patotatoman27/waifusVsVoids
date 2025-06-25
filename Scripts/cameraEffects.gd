extends Node
@onready var camera2D: Camera2D = $"."
var rng = RandomNumberGenerator.new()

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
