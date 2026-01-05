extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func item_message(text):
	$Item.text = text
	$Item.show()
	$Timer.start()
	
func show_game_over():
	$Item.hide()
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "AD TO ROTATE
WS TO FORWARD/BACK
SPACE TO LAUNCH ASTEROIDS"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	
func update_score(score):
	$ScoreLabel.text = str(score)

func update_health(health):
	$Health.text = str(health)

func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_game.emit()

func _on_message_timer_timeout() -> void:
	$Message.hide()

func _on_timer_timeout() -> void:
	$Item.hide()
