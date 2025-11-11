extends Node2D
class_name Main

@export var microgames : Array[PackedScene]
@export var instruction_time : float = 2
@export var pre_warm_frames : int = 5

#var loaded_microgames = {}
var in_game : bool = false
var high_score : int = 0

var current_mg : Microgame
var mg_state_got : bool = false
var mg_won : bool = false
var score : int = 0
var lives : int = 4
var time_scale : float = 1
var is_current_game_done : bool = false

# Room
@onready var room_anim = $RoomAnimations
@onready var win_sound = $Win
@onready var lose_sound = $Loss
@onready var next_sound = $Next

# UI
@onready var main_menu_ui = $UI/MainMenu
@onready var game_ui = $UI/Game
@onready var high_score_label = $UI/MainMenu/HighScore
@onready var label_anim = $UI/Game/LabelAnimations
@onready var score_label = $UI/Game/ScoreLabel
@onready var lives_label = $UI/Game/LivesLabel
@onready var message_label = $UI/Game/MessageLabel
@onready var control_image = $UI/Game/ControlImage
const control_frames = { # frame number for the sprite
	Microgame.ControlType.MOUSE : 1,
	Microgame.ControlType.KEYBOARD : 0,
	Microgame.ControlType.Both : 2
}

var in_credits_menu = false
var credits_template = """
	[b][u]%s[/u][/b]
	by %s
	
	%s
	
"""
@onready var credits_ui = $UI/Credits
@onready var credits_label = $UI/Credits/Games

func _ready():
	Engine.time_scale = time_scale
	game_ui.modulate = Color(1.0, 1.0, 1.0, 0.0)
	# Warming up the cache by playing all games for a frame or 2 (hidden) to get rid of lag with some of the games
	var start_button = $UI/MainMenu/StartButton
	get_tree().root.set_disable_input(true)
	await pre_warm_minigames()
	get_tree().root.set_disable_input(false)
	start_button.text = "Start"
	
	load_credits()
	
	#Engine.time_scale = 1.5
	#AudioServer.playback_speed_scale = 1.5

func load_credits():
	credits_label.text = "Thank you to everyone who participated!\n"
	for i in range(microgames.size()):
		var inst = microgames[i].instantiate() as Microgame
		credits_label.text += credits_template % [inst.game_name, inst.creator_name, inst.game_description]
		

func start_new_microgame():
	is_current_game_done = false
	if microgames.size() == 0:
		push_error("No microgames loaded! Add one to Main -> Microgames.")
		return
	var rand_idx = randi() % microgames.size()
	#var rand_idx = 9
	load_microgame(microgames[rand_idx])
	
	message_label.text = current_mg.message
	control_image.frame = control_frames[current_mg.control_type]
	room_anim.play("change_to_message")
	
	next_sound.play()
	await get_tree().create_timer(instruction_time).timeout
	room_anim.play("zoom_in")
	add_child(current_mg)

	
func load_microgame(microgame : PackedScene):
	var inst = microgame.instantiate() as Microgame
	#var inst = loaded_microgames[microgame.resource_path]
	inst.finish_game.connect(on_microgame_done)
	inst.win_game.connect(on_game_won)
	inst.lose_game.connect(on_game_lost)
	mg_state_got = false
	mg_won = false
	current_mg = inst
	

func on_microgame_done():
	# Added a check so we don't get multiple game dones
	if not is_current_game_done:
		is_current_game_done = true
		# CHANGE: Making all wins and losses immediately close curtains. (Calling this on win/loss now)
		# Need going to wait n seconds if there is still n or more seconds on clock
		if (current_mg.bomb_timer.tick_count > current_mg.post_game_time / current_mg.bomb_timer.tick_timer.wait_time):
			await get_tree().create_timer(current_mg.post_game_time).timeout
		
		# if not already won, look at the timeout setting
		var won = mg_won if mg_state_got else !current_mg.lose_on_timeout
		
		room_anim.play("zoom_out")
		await room_anim.animation_finished
		unload_current_microgame()

		if won:
			print("Won game!")
			win_sound.play()
			label_anim.play("increment_score") # the animation calls increment_score()
		else:
			print("Lost game!")
			lose_sound.play()
			label_anim.play("lose_life") # the animation calls lose_life()
		
		await label_anim.animation_finished
		
		if lives == 0:
			game_over()
			return
		start_new_microgame()


func unload_current_microgame():
	current_mg.queue_free()
	current_mg = null


func increment_score():
	score += 1
	score_label.text = str(score)

func lose_life():
	lives -= 1
	lives_label.text = "Lives: " + str(lives)

func on_game_won():
	if not mg_state_got:
		mg_state_got = true
		mg_won = true
		print("Ticks remaining:")
		print(current_mg.bomb_timer.tick_count)
		if current_mg.bomb_timer.tick_count > current_mg.post_game_time / current_mg.bomb_timer.tick_timer.wait_time:
			on_microgame_done()
		
	
func on_game_lost():
	if not mg_state_got:
		mg_state_got = true
		mg_won = false
		print("Ticks remaining:")
		print(current_mg.bomb_timer.tick_count)
		if current_mg.bomb_timer.tick_count > current_mg.post_game_time / current_mg.bomb_timer.tick_timer.wait_time:
			on_microgame_done()

func game_start():
	in_game = true
	mg_state_got = false
	mg_won = false
	score = 0
	lives = 4
	
	score_label.text = "0"
	lives_label.text = "Lives: " + str(lives)
	
	room_anim.play("game_start")
	win_sound.play()
	await get_tree().create_timer(1.75).timeout
	start_new_microgame()

func game_over():
	in_game = false
	high_score = max(score, high_score)
	high_score_label.text = "High Score: " + str(high_score)
	
	room_anim.play("game_over")

func pre_warm_minigames():
	# Muting since we don't need want to hear games
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	
	# Creates a subview port so we can render the scenes hiddenly, doing instance.hide() doesn't run some methods so that won't warm up the game (cache)
	# This viewport is invisible bc we don't put it inside a SubViewPortContainer or assign a ViewportTexture
	var warmup_viewport = SubViewport.new()
	warmup_viewport.size = Vector2i(1, 1)
	warmup_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(warmup_viewport)
	
	for game in microgames:
		var inst = game.instantiate() as Microgame
		warmup_viewport.add_child(inst)
		# wait x frames
		for i in range(pre_warm_frames):
			await get_tree().process_frame
		warmup_viewport.remove_child(inst)
		inst.queue_free()
	
	warmup_viewport.queue_free()
	# Unmuting
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)


func _on_start_button_pressed():
	if not in_game and not in_credits_menu:
		game_start()


func _on_back_button_pressed():
	if not in_game and in_credits_menu:
		in_credits_menu = false
		main_menu_ui.visible = true
		credits_ui.visible = false

func _on_credits_button_pressed():
	if not in_game and not in_credits_menu:
		in_credits_menu = true
		main_menu_ui.visible = false
		credits_ui.visible = true
		
