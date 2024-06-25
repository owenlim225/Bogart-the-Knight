extends Node

# Important import
@onready var player = $Player
@onready var camera_2d = $Camera2D
@onready var ground = $Ground
@onready var hud = $HUD
@onready var gameOver = $GameOver
@onready var animation_player = $AnimationPlayer
@onready var music = $Music
@onready var world_envi = $WorldEnvi
@onready var mile_score = $mileScore

# Flying obstacles
var bird_scene = preload("res://scenes/bird.tscn")
var bat_scene = preload("res://scenes/bat.tscn")
var wonwon_scene = preload("res://scenes/wonwon.tscn")

var flying_obstacles_types := [bird_scene, bat_scene, wonwon_scene]
var flying_obstacles_height := [200, 390]

# Ground obstacles
var barrel_scene = preload("res://scenes/barrel.tscn")
var stone_scene = preload("res://scenes/stone.tscn")
var stump_scene = preload("res://scenes/stump.tscn")
var ground_obstacles_types := [barrel_scene, stone_scene, stump_scene]
var obstacles : Array
var difficulty
var obs

const MAX_DIFFICULTY : int = 2
const PLAYER_START_POS := Vector2i(150, 185)
const CAM_START_POS := Vector2i(576, 324)

const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER : int = 5000
const SCORE_MODIFIER : int = 10

var score : int
var high_score : int
var last_score_milestone : int
var speed : float
var screen_size : Vector2i
var ground_height : int
var game_run: bool
var last_obs 

func _ready():
	screen_size = get_window().size
	ground_height = ground.get_node("Sprite2D").texture.get_height()
	gameOver.get_node("Restart").pressed.connect(new_game)
	gameOver.get_node("Quit").pressed.connect(quit)
	new_game()

func _process(delta):
	if game_run:
		# Speed up and adjust difficulty
		speed = START_SPEED + score / SPEED_MODIFIER
		print(speed)
		# Limit speed level 
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		
		# Generate obstacles infinitely
		generate_obs()

		# Move player position and camera
		player.position.x += speed
		camera_2d.position.x += speed

		# Update score
		score += speed
		show_score()

		# Update ground position
		if camera_2d.position.x - ground.position.x > screen_size.x * 1.5:
			ground.position.x += screen_size.x
			
		
		# remove obstacles off screen
		for obs in obstacles:
			if obs.position.x < (camera_2d.position.x - screen_size.x):
				remove_obs(obs)
				
	else:
		if Input.is_action_just_pressed("ui_accept"):
			game_run = true
			hud.get_node("StartLbl").hide()
			hud.get_node("TitleLbl").hide()

func new_game():
	# reset game
	score = 0
	show_score()
	game_run = false
	get_tree().paused = false
	difficulty = 0

	# reset obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	# reset nodes
	player.position = PLAYER_START_POS
	player.velocity = Vector2i(0, 0)
	camera_2d.position = CAM_START_POS
	ground.position = Vector2i(0, -5)
	
	# reset HUD and game over screen
	hud.get_node("StartLbl").show()
	hud.get_node("TitleLbl").show()
	gameOver.hide()

func generate_obs():
	# generate ground obstacles
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_ground_type = ground_obstacles_types[randi() % ground_obstacles_types.size()]
		var max_ground_obs = difficulty + 1
		
		for i in range(randi() % max_ground_obs + 1):        
			obs = obs_ground_type.instantiate() 
			
			# get obstacle scene height and scale of obstacle scenes
			var obs_height = obs.get_node("Sprite2D").texture.get_height() 
			var obs_scale = obs.get_node("Sprite2D").scale 
			
			# coordinates of obstacles in the main scene
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) -15
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
			
		# add flying obstacle
		if difficulty == MAX_DIFFICULTY:
				var obs_flying_type = flying_obstacles_types[randi() % flying_obstacles_types.size()]
				var max_flying_obs = difficulty + 1
			
				if (randi() % 2) == 0:
					obs = obs_flying_type.instantiate() 
					var obs_x : int = screen_size.x + score + 100
					var obs_y : int = flying_obstacles_height[randi() % flying_obstacles_height.size()]
					add_obs(obs, obs_x, obs_y)
					night_envi() # WorldEnvironment change backgruond to night

func night_envi():
	print("sex")
	world_envi.play("WorldEnvi")


func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)   
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func hit_obs(body):
	if body.name == "Player": 
		game_over()

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	check_high_score()
	get_tree().paused = true
	game_run = false
	animation_player.play()
	gameOver.show()

func quit():
	get_tree().quit()

func show_score():
	hud.get_node("ScoreLbl").text = str(score / SCORE_MODIFIER)
	
	# Check if the score has reached the next milestone
	var mod_score = score / SCORE_MODIFIER
	if mod_score >= (last_score_milestone + 1) * 500:
		last_score_milestone += 1
		mile_score.play()

	
func check_high_score():
	gameOver.get_node("ScoreLbl").text = str(score / SCORE_MODIFIER)
	
	if score > high_score:
		high_score = score
		gameOver.get_node("BestScoreLbl").text = str(score / SCORE_MODIFIER)
