extends Area2D
@onready var timer: Timer = $Timer

const BULLET = preload("res://bullet.tscn")
signal UFOhit
var linear_velocity = Vector2(0,0)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()
	
func _physics_process(delta):
	position += linear_velocity * delta

func bulletSpawn() -> void:
	var bullet = BULLET.instantiate()
	add_child(bullet)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("asteroid"):
		UFOhit.emit()
		self.queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("laser"):
		UFOhit.emit()
		self.queue_free()
