extends Node

var screen_size : Vector2i

var game_running : bool
var game_over : bool
var game_time : int
var score : int
var high_scores = []
const SCORE_TEXT = "SCORE: "
const HIGH_SCORE_TEXT = "HIGH SCORES: "

var scroll : int
const INIT_SCROLL_SPEED = 6
var scroll_speed : int
@export var obstacle_scenes = []
@export var item_scenes = []
var obstacles = []
var items = []
const OBSTACLE_DELAY = 100
const OBSTACLE_MIN_TIME = 0.2
const OBSTACLE_TIMER_AUX_INIT = 3.0
var obstacle_timer_aux = 3.0
const ITEM_MIN_TIME = 0.1
const ITEM_TIMER_AUX_INIT = 2.6
var item_timer_aux = 2.6

# UI signals
signal display_score
signal display_high_scores
# audio signals
signal sfx_hit
signal sfx_click
signal sfx_coin
signal sfx_powerup

# Called when the node enters the scene tree for the first time.
func _ready():
	scroll_speed = INIT_SCROLL_SPEED
	$Ground/Ceiling.hit.connect(bird_hit)
	new_game()
	screen_size = get_window().size
	load_high_scores()
	
func new_game():
	$PlayerBird.setup()
	
	game_time = 0
	score = 0
	scroll = 0
	scroll_speed = INIT_SCROLL_SPEED
	obstacle_timer_aux = OBSTACLE_TIMER_AUX_INIT
	item_timer_aux = ITEM_TIMER_AUX_INIT
	
	game_running = false
	game_over = false
	for ob in obstacles:
		ob.queue_free()
	obstacles.clear()
	for it in items:
		it.queue_free()
	items.clear()
	display_score.emit(SCORE_TEXT + str(score))
	$GameOver.hide()
	
func game_start():
	game_running = true
	$PlayerBird.flying = true
	$ObstacleTimer.start(OBSTACLE_MIN_TIME + obstacle_timer_aux)
	$ItemTimer.start(ITEM_MIN_TIME + item_timer_aux)
	$ScoreTimer.start(5 / scroll_speed)
	sfx_click.emit()
	$MusicPlayer.play()
	
func stop_game():
	game_over = true
	game_running = false
	
	save_score()
	
	$PlayerBird.flying = false
	$ObstacleTimer.stop()
	$ItemTimer.stop()
	$ScoreTimer.stop()
	$GameOver.show()
	$MusicPlayer.stop()

func _input(event):
	if not game_over:
		if event.is_action("click"):
			if event.pressed:
				if not game_running:
					game_start()
				$PlayerBird.flap()
			elif not event.pressed and game_running:
				$PlayerBird.stop_flap()
				

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		game_time += delta
		scroll += scroll_speed
		if scroll >= screen_size.x:
			scroll = 0
		$Ground.position.x = -scroll
		for ob in obstacles:
			if ob.position.x <= -OBSTACLE_DELAY:
				obstacles.erase(ob)
				ob.queue_free()
			ob.position.x -= scroll_speed
		for it in items:
			if it.position.x <= -OBSTACLE_DELAY:
				items.erase(it)
				it.queue_free()
			it.position.x -= scroll_speed

func generate_obstacle():
	var index = randi_range(0, obstacle_scenes.size() - 1)
	var type = obstacle_scenes[index]
	var obstacle = type.instantiate()
	obstacle.position.x = screen_size.x + OBSTACLE_DELAY
	obstacle.position.y = randi_range(140, screen_size.y - 140)
	obstacle.hit.connect(bird_hit)
	$Obstacles.add_child(obstacle)
	obstacles.append(obstacle)
	
func generate_item():
	var index = randi_range(0, item_scenes.size() - 1)
	var type = item_scenes[index]
	var item = type.instantiate()
	item.position.x = screen_size.x + OBSTACLE_DELAY
	item.position.y = randi_range(160, screen_size.y - 160)
	
	item.pickup.connect(pickup_item)
	$Items.add_child(item)
	items.append(item)

func bird_hit():
	sfx_hit.emit()
	$PlayerBird.falling = true
	if game_running:
		stop_game()
	
func pickup_item(item):
	if not $PlayerBird.flying:
		return
	score_change(item.score)
	if "speed_inc" in item:
		scroll_speed += item.speed_inc
		sfx_powerup.emit()
	else:
		sfx_coin.emit()
	item.queue_free()
	items.erase(item)
	
func score_change(score_mod):
	var score_mod_speed = 1 + 0.2*(scroll_speed - INIT_SCROLL_SPEED)
	score += round(score_mod * score_mod_speed)
	display_score.emit(SCORE_TEXT + str(score) + "\n x" + str(score_mod_speed))
	
	
func _on_ground_hit():
	sfx_hit.emit()
	$PlayerBird.falling = false
	if game_running:
		stop_game()

func _on_item_timer_timeout():
	generate_item()
	item_timer_aux *= 0.97
	$ItemTimer.start(ITEM_MIN_TIME + item_timer_aux * randf_range(0.4, 1.3))

func _on_score_timer_timeout():
	score_change(1)
	if scroll_speed > INIT_SCROLL_SPEED:
		scroll_speed -= 1
	$ScoreTimer.start(5 / scroll_speed)

func _on_obstacle_timer_timeout():
	generate_obstacle()
	obstacle_timer_aux *= 0.97
	$ObstacleTimer.start(OBSTACLE_MIN_TIME + obstacle_timer_aux * randf_range(0.4, 1.3))

func _on_game_over_restart():
	new_game()
	
func load_high_scores():
	high_scores.clear()
	
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	if save_file == null:
		return
	while save_file.get_position() < save_file.get_length():
		#score_aux = int(save_file.get_line())
		high_scores.append(save_file.get_line())
	save_file.close()
	
	var hscore_text = HIGH_SCORE_TEXT
	for s in high_scores:
		hscore_text += s + "\n"
	display_high_scores.emit(hscore_text)
	
func save_score():
	# decide on on new high scores
	high_scores.append(str(score))
	high_scores.sort_custom(func(a, b): return a.naturalnocasecmp_to(b) > 0)
	
	# save new high scores to file
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	for s in min(high_scores.size(), 3):
		save_file.store_line(str(high_scores[s]))
		# display high score
		
	save_file.close()
	
	load_high_scores()
	
	
	
