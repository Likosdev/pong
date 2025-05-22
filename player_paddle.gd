extends CharacterBody2D
class_name PlayerPaddle

@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var polygon_2d: Polygon2D = $Polygon2D

@export
var controlled_by : controller = controller.PLAYER_A

@export
var upper_limit : float = 0

@export
var lower_limit : float = 0

@export 
var speed = 300.0

@export var ball : Ball = null

var BALL_SPEED_MODIFIER : int = 75
var BALL_Y_DIRECTION_MODIFIER : float = .5

var direction = Vector2.ZERO

enum controller {
	PLAYER_A,
	PLAYER_B,
	AI
}

const button_map : Dictionary = {
	controller.PLAYER_A: {
		"up":"up_player_a",
		"down":"down_player_a"
	},
	controller.PLAYER_B: {
		"up":"up_player_b",
		"down":"down_player_b"
	}
}

func _process(delta: float) -> void:
	match controlled_by:
		controller.AI:
			_process_ai(delta)
		_: # default case, so paddle is controlled by either player a or b
			_process_player_input(delta)

func _process_player_input(delta : float):
	direction = Vector2(0, Input.get_axis(
		button_map[controlled_by]["up"],
		button_map[controlled_by]["down"]
	))

	velocity = direction * speed * delta
	@warning_ignore("unused_variable")
	# i will need this! 
	var col = move_and_collide(velocity)
	
func _process_ai(delta : float):
	if ball.position.y > self.position.y + 32: # paddle_height
		direction.y = 1
	elif ball.position.y < self.position.y - 32: # paddle_height
		direction.y = -1
	else:
		# avoid stuttering around zero and make ai acutally beatable
		direction.y = lerp(direction.y, .0 , delta / 2) 

	velocity = direction * ( speed * .65 ) * delta
	@warning_ignore("unused_variable") # i will need this!
	var col = move_and_collide(velocity)


	
func _move_ai_via_lerp(delta: float):
	self.position.y = clamp(
		lerpf(self.position.y, ball.position.y, 2 * delta),
		0 + 32,
		get_viewport().size.y - 32
	)


func calculate_speed_and_direction(contact_position: Vector2, body : PhysicsBody2D):
	var distance_to_center : Vector2 = contact_position - self.global_position 
	
	if body is Ball:
		if distance_to_center.length() >= 18:
			# near either edge of the paddel
			body.ball_speed += BALL_SPEED_MODIFIER
			# ugly ahhh ternary statement
			body.direction.y += BALL_Y_DIRECTION_MODIFIER if \
			contact_position.y >= self.global_position.y \
			else -BALL_Y_DIRECTION_MODIFIER
			 
			body.direction.y = body.direction.normalized().y
		# x can always be reversed after a paddle collision
		body.direction.x = -body.direction.x
