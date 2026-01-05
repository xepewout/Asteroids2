extends CharacterBody2D

@export var speed = 400
@export var rotation_speed = 1.5
@export var orbit_speed = 300
@export var gravity_value = 300
var asteroidsOrbiting = []
var radiusToAsteroid
var isOrbiting = false
var rotation_direction = 0
signal hit
signal item(itemNum: int)
const LASER = preload("res://laser.tscn")
var controlType = 1

func get_input():
	rotation_direction = Input.get_axis("move_LEFT", "move_RIGHT")
	velocity = transform.x * Input.get_axis("move_DOWN", "move_UP") * speed
	if(Input.is_action_just_released("SPACE")):
		_asteroid_fired()

func _physics_process(delta):
	if controlType == 1:
		get_input()
		rotation += rotation_direction * rotation_speed * delta
		move_and_slide()
	if controlType == 2:
		var direction: Vector2 = Vector2.ZERO
		if Input.is_action_pressed("move_RIGHT"):
			direction.x += 1
		if Input.is_action_pressed("move_LEFT"):
			direction.x -= 1
		if Input.is_action_pressed("move_DOWN"):
			direction.y += 1
		if Input.is_action_pressed("move_UP"):
			direction.y -= 1
		direction = direction.normalized()
		if direction != Vector2.ZERO:
			velocity = direction * speed
		else:
			velocity = Vector2.ZERO 
		move_and_slide()
		
	if isOrbiting:
		for i in asteroidsOrbiting.size(): 
			if(asteroidsOrbiting[i]):
				radiusToAsteroid = (global_position - asteroidsOrbiting[i].position) 
				var accel = radiusToAsteroid.normalized() * gravity_value
				asteroidsOrbiting[i].linear_velocity += accel * delta

func _on_gravity_field_body_entered(body: Node2D) -> void:
	if (body.is_in_group("asteroid") and !asteroidsOrbiting.has(body)):
		var to_center = global_position - body.global_position
		if to_center.length() > 0.0:
			var tangent = Vector2(-to_center.y, to_center.x).normalized()
			body.linear_velocity = tangent * orbit_speed
		asteroidsOrbiting.append(body)
		isOrbiting = true

func _on_area_2d_area_entered(area: Area2D) -> void:
	if(area.is_in_group("enemy") or area.is_in_group("bullet")):
		_hit()
	if(area.is_in_group("item")):
		item.emit(area.itemNum)
		area.queue_free()

func _hit():
	hit.emit()
	
func remove_orbiting_asteroid(asteroid: Node2D):
	if asteroidsOrbiting.has(asteroid):
		asteroidsOrbiting.erase(asteroid)
	
func _asteroid_fired():
	if isOrbiting:
		isOrbiting = false
		for i in asteroidsOrbiting.size():
			asteroidsOrbiting[i].linear_velocity = asteroidsOrbiting[i].linear_velocity * 5
		asteroidsOrbiting = []
		


func _on_laser_timer_timeout() -> void:
	var laser = LASER.instantiate()
	laser.position = self.position 
	laser._setDirection(transform.x.normalized())
	get_parent().add_child(laser)
