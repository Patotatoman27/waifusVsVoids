extends Camera2D

#@onready var p1: CharacterBody2D = $"../Player1"
#@onready var p2: CharacterBody2D = $"../Player2"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#self.position.x = (p1.position.x + p2.position.x) / 2
	#self.position.y = ((p1.position.y + p2.position.y) / 2)-150
	#self.zoom = Vector2(((p1.position.x + p2.position.x)/2300), zoom.x);
	pass
