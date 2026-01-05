extends Area2D
var direction = Vector2.ZERO
var speed = 500


func _setDirection(playerDirection: Vector2):
	direction = playerDirection


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = speed*direction
	position += velocity * delta
