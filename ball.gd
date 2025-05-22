extends CharacterBody2D
class_name Ball

@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer

var MAX_BALL_SPEED : float = 600
var MIN_BALL_SPEED : float = 200

@export
var ball_speed : float = 200 :
	set(value): #clamp the value via setter is better than later forgetter
		ball_speed = clamp(value,MIN_BALL_SPEED,MAX_BALL_SPEED)

var direction := Vector2.LEFT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.direction.y = [-1,1].pick_random()
	self.direction = self.direction.normalized()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var movement = direction * delta * ball_speed
	var collision = move_and_collide(movement)
	if collision:
		audio_stream_player.play()
		var collider = collision.get_collider()

		# collision response calculation is done at the paddle - is that bad?
		if collider is PlayerPaddle:
			var collision_position = collision.get_position()
			var paddle : PlayerPaddle = collider
			paddle.calculate_speed_and_direction(collision_position, self)
		else:
			# ball collided with a wall so we can simply bounce around the normal
			direction = direction.bounce(collision.get_normal())
