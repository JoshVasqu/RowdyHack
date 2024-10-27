extends CharacterBody2D

enum {
	IDLE,
	HIT,
	ATTACK,
	CHASE,
	DIED
}

var TAG = "entity"

var SPEED : int = 55.0
const JUMP_VELOCITY = -225.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction : Vector2 = Vector2(0, 0)
var target = null

var health : int = 100

var state = IDLE

func _process(delta):
	
	$ProgressBar.min_value = health
	
	handle_gravity(delta)
	handle_direction()
	match state:
		CHASE:
			animation_handler()
			movement()
			if $direction_handler/AttackBox.has_overlapping_bodies():
				state = ATTACK
			pass
		ATTACK:
			$direction_handler/AnimatedSprite2D.play("Idle")
			velocity.x = 0
			direction.x = 0
			$AttackTimeStart.start()
			state = null
			pass
		HIT:
			pass
		DIED:
			pass
	
	move_and_slide()

func handle_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func movement():
	var targetPosition = (target.position - self.position)
	if targetPosition.x < -0.2:
		direction.x = -1
	elif targetPosition.x > 0.2:
		direction.x = 1
	else:
		direction.x = 0
	
	if (is_on_wall() or not $direction_handler/GroundDetection.has_overlapping_bodies()) and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	velocity.x = direction.x * SPEED
	

func handle_direction():
	
	if direction.x > 0:
		get_node("direction_handler").set_scale(Vector2(1, 1))
	elif direction.x < 0:
		get_node("direction_handler").set_scale(Vector2(-1, 1))

func animation_handler():
	if direction.x != 0:
		$direction_handler/AnimatedSprite2D.play("Run")
	else:
		$direction_handler/AnimatedSprite2D.play("Idle")

func _on_attack_time_start_timeout():
	if state == null:
		$direction_handler/AnimatedSprite2D.play("Attack")
		$AttackTime.start()

func _on_attack_time_timeout():
	if state == null:
		state = CHASE



func _on_detection_box_body_entered(body):
	target = body
	state = CHASE
