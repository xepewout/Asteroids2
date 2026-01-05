extends Node2D
const PLAYER = preload("res://player.tscn")
const ASTEROID = preload("res://asteroid.tscn")
const ENEMY = preload("res://enemy.tscn")
const ITEM = preload("res://item.tscn")
var player
var player_spawn = Vector2(640,480)
var enemy_spawn = Vector2(300,300)
var numberOfAsteroids = 0
var numberOfUFOs = 0
var playerHealth = 3
var score = 0
var finalscore = 0
var itemOverride = false
var maxUFOS = 10


# Called when the node enters the scene tree for the first time.
func _new_game() -> void:
	score = 0
	playerHealth = 3
	$HUD.update_health(playerHealth)
	if !player:
		player = PLAYER.instantiate()
		player.hit.connect(_playerHit)
		player.item.connect(_useItem)
	player.global_position = player_spawn
	add_child(player)
	spawnUFO()
	spawnAsteroid()
	$HUD.update_score(score)
	$HUD.show_message("")
	
#for when the something hits the borders
func _on_border_entered(body: Node2D, newPosition: Vector2) -> void:
	if(body.name == "Player"):
		if newPosition.y == 0:
			body.position.x = 0
			body.position = body.position + newPosition
		if newPosition.x == 0:
			body.position.y = 0
			body.position = body.position + newPosition
	if (body.is_in_group("asteroid")):
		removeAsteroid(body)
		
#for when an area hits the border
func _area_on_border_entered(area: Area2D):
	if(area.is_in_group("enemy")):
		area.queue_free()
		_UFOhit()
	if(area.is_in_group("bullet") or area.is_in_group("laser")):
		area.queue_free()
	
		
func removeAsteroid(body):
	if player:
		player.remove_orbiting_asteroid(body)
	body.queue_free()
	numberOfAsteroids -= 1
	
func spawnUFO():
	if numberOfUFOs < maxUFOS:
		var enemy = ENEMY.instantiate()
		var EnemySpawnLocation = $"Asteroid Path/AsteroidSpawnLocation"
		EnemySpawnLocation.progress_ratio = randf()
		enemy.position = EnemySpawnLocation.position
		var direction = EnemySpawnLocation.rotation + PI/2
		direction += randf_range(-PI/4, PI/4)
		enemy.rotation = direction
		var velocity = Vector2(randf_range(150,250), 0.0)
		enemy.linear_velocity = velocity.rotated(direction)
		call_deferred("add_child", enemy)
		enemy.UFOhit.connect(_UFOhit)
		numberOfUFOs += 1
		
func spawnAsteroid():
	if numberOfAsteroids < 5 or itemOverride:
		var asteroid = ASTEROID.instantiate()
		var AsteroidSpawnLocation =  $"Asteroid Path/AsteroidSpawnLocation"
		AsteroidSpawnLocation.progress_ratio = randf()
		asteroid.position = AsteroidSpawnLocation.position
		var direction = AsteroidSpawnLocation.rotation + PI/2
		direction += randf_range(-PI/4, PI/4)
		asteroid.rotation = direction
		var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
		asteroid.linear_velocity = velocity.rotated(direction)
		numberOfAsteroids += 1
		call_deferred("add_child", asteroid)
		

func _UFOhit():
	score += 500
	numberOfUFOs -= 1
	spawnUFO()

func spawnItem():
	var item = ITEM.instantiate()
	item.position = Vector2(randf_range(0, 1280), randf_range(0, 960))
	add_child(item)
	
#debug
func _physics_process(_delta: float) -> void:
	score += 1
	if player:
		$HUD.update_score(score)
	
func _playerHit():
	$HitSound.play()
	playerHealth -= 1
	$HUD.update_health(playerHealth)
	if playerHealth == 0:
		_gameOver()
		
func _useItem(itemNum: int):
	$ItemSound.play()
	score+=100
	if(itemNum == 1):
		playerHealth += 1
		$HUD.update_health(playerHealth)
		$HUD.item_message("Health Pack")
	if(itemNum == 2):
		itemOverride = true
		for i in 10:
			spawnAsteroid()
		itemOverride = false
		$HUD.item_message("Asteroid Barrage")
	if(itemNum == 3):
		player.scale = Vector2(.5,.5)
		$ItemScaleTimer.start()
		$ItemScaleTimer.wait_time += 4
		$HUD.item_message("Shrink!")
	if(itemNum == 4):
		$ItemLaserTimer.start()
		$Player/LaserTimer.start()
		$HUD.item_message("Lasers")
	if(itemNum == 5):
		maxUFOS -=1
		$ItemUFOTimer.start()
		$HUD.item_message("UFOS Down")
	
func _gameOver():
	finalscore = score
	player.asteroidsOrbiting = []
	player.queue_free()
	$HUD.update_score(finalscore)
	$HUD.show_game_over()

func _on_scale_timer_timeout() -> void:
	if player:
		player.scale = Vector2(1,1)

func _on_laser_timer_timeout() -> void:
	if player:
		$Player/LaserTimer.stop()

func _on_item_ufo_timer_timeout() -> void:
	maxUFOS += 1
