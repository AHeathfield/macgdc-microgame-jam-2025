extends Node2D
class_name Microgame

# VARIABLES
@export_group("Microgame Info")

## The name of your game.
@export var game_name : String

## You!
@export var creator_name : String

## Give a short description of your game, how to win/lose, controls, etc.
@export_multiline var game_description : String

@export_group("Microgame Settings")

## How long your game runs for in seconds. Try to keep it between 3-10 seconds!
@export_range(2, 10) var game_length : int = 4

## How long it takes before closing the game after a win/loss signal is emitted. Increase this if you want to play a win animation!
@export var post_game_time : float = 2.5

## If true, the game will be lost when the timer runs out. If false, the game will be won when the timer runs out.
@export var lose_on_timeout : bool = true

## The short message that briefly shows when your game starts. Try to limit its length to under 30 characters.
@export var message : String = "Message!"

enum ControlType {
	MOUSE,
	KEYBOARD,
	Both	
};
## The type of controls your game uses to be played. Also shows an icon of the control scheme when the game is played.
@export var control_type : ControlType

@export_group("Microgame Nodes")

@export var bomb_timer : BombTimer

# SIGNALS
@warning_ignore_start("unused_signal")
signal finish_game
signal win_game
signal lose_game
@warning_ignore_restore("unused_signal")

# METHODS
func _ready():
	if bomb_timer == null:
		push_error("Bomb timer is null! Remember to set it in \"Microgame Nodes\".")
		return
	
	bomb_timer.exploded.connect(on_bomb_timeout)
	bomb_timer.activate(game_length)
	
func on_bomb_timeout():
	finish_game.emit()
	
