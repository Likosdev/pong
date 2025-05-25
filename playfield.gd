extends Node2D
class_name PlayField

@export
var ball : Ball = null
@export
var Player_A : PlayerPaddle = null
@export
var Player_B : PlayerPaddle = null
@export 
var Goal_Player_A : Goal = null
@export 
var Goal_Player_B : Goal = null
@export 
var points_to_win : int = 3
@export
var difficulty : int = 0

@onready
var initial_player_a_position : Vector2 = self.Player_A.position
@onready
var initial_player_b_position : Vector2 = self.Player_B.position
@onready
var initial_ball_position : Vector2 = self.ball.position
@onready
var camera_2d: Camera2D = %Camera2D
@onready 
var score_label: Label = %Score_Label
@onready 
var announce_win_label: Label = %Announce_Win_Label
@onready
var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var score_player_a : int = 0
var score_player_b : int = 0

func _ready() -> void:
	Goal_Player_A.scored.connect(self.on_goal_scored)
	Goal_Player_B.scored.connect(self.on_goal_scored)
	camera_2d.make_current()

func _on_paddle_collided_with_ball(global_position : Vector2):
	print("boom")
	var tween = create_tween().bind_node(camera_2d)
	tween.tween_property(
		camera_2d, "offset", Vector2.LEFT * 2, .05
	).from_current()
	tween.tween_property(
		camera_2d, "offset", Vector2.RIGHT * 2, .05
	).from_current()

func setup(
	mode : Main.GameMode, 
	points_to_win : int = self.points_to_win,
	difficulty : int = self.difficulty
	):
	self.points_to_win = points_to_win
	self.difficulty = difficulty
	match mode:
		Main.GameMode.PLAYER_VS_AI:
			set_up_vs_ai()
		Main.GameMode.PLAYER_VS_PLAYER:
			set_up_pvp()


func set_up_vs_ai():
	Player_A.controlled_by = PlayerPaddle.controller.PLAYER_A
	Player_B.controlled_by = PlayerPaddle.controller.AI
	print("Selected Difficuly = ", self.difficulty)
	Player_B.ai_difficulty = self.difficulty
	Player_B.ball = self.ball

func set_up_pvp():
	Player_A.controlled_by = PlayerPaddle.controller.PLAYER_A
	Player_B.controlled_by = PlayerPaddle.controller.PLAYER_B

func update_score_label():
	score_label.text = "{0} : {1}".format([score_player_a,score_player_b])

func on_goal_scored(side : String):
	print("Goal Scored against {0}".format([side]))
	audio_stream_player_2d.play()
	if side == "PLAYER_A":
		score_player_b += 1
	elif  side == "PLAYER_B":
		score_player_a += 1
	
	update_score_label()
	await get_tree().create_timer(2).timeout
	if score_player_a >= points_to_win or score_player_b >= points_to_win:
		_game_ended()
	else:
		reset_game()

func _game_ended():
	if score_player_a > score_player_b:
		announce_win_label.text = "PLAYER 1 WINS"
	else:
		announce_win_label.text = "PLAYER 2 WINS"
	announce_win_label.show()
	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_file("res://main.tscn")

func reset_game():
	ball.position = initial_ball_position
	ball.direction.x = -1 if ball.direction.x < 0 else 1 
	
	ball.ball_speed = ball.MIN_BALL_SPEED
	Player_A.position = initial_player_a_position
	Player_B.position = initial_player_b_position
