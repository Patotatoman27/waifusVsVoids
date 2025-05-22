class_name AttackData

var damage: int #Numero de puntos de daño que quita un ataque. Valor positivo
var hitstun: int #Numero de frames (ANIMFPS) que dura el hitstun enemigo
var hitstop: float #Numero de segundos que dura el hitstop
var knockbackH : float;
var knockbackV : float;

func _init(_damage: int, _hitstun: int, _hitstop: float, _knockbackH : float, _knockbackV : float) -> void:
	damage = _damage
	hitstun = _hitstun
	hitstop = _hitstop
	knockbackH = _knockbackH
	knockbackV = _knockbackV
