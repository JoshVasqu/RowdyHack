extends CharacterBody2D

enum {
	NORMAL,
	ATTACK01
}

var TAG = "entity"

var SPEED : int = 100.0
const JUMP_VELOCITY = -225.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 0
var look_direction = 0
@export var dmgper : int = 1

@export var health = 100
var curHealth = health
var checkpoint : Vector2

var state = NORMAL
func _physics_process(delta):
	GlobalManager.playerPosition = self.position
	GlobalManager.playerHealth = health
	GlobalManager.currentHealth = curHealth
	
	if is_on_floor():
		checkpoint = self.position
	
	$ProgressBar.min_value = curHealth
	
	handle_direction()
	
	match state:
		NORMAL:
			SPEED = 100
			look_direction = direction
			if Input.is_action_pressed("ui_accept"):
				state = ATTACK01
		ATTACK01:
			attack01()
	
	handle_gravity(delta)
	handle_animation()
	movement()

func handle_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func movement():
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
				velocity.y = JUMP_VELOCITY
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func handle_direction():
	direction = Input.get_axis("ui_left", "ui_right")
	
	if look_direction > 0:
		get_node("direction_handler").set_scale(Vector2(1, 1))
	elif look_direction < 0:
		get_node("direction_handler").set_scale(Vector2(-1, 1))

func handle_animation():
	if not is_on_floor():
		$direction_handler/Bottom.play("Jump")
	elif direction == 0:
		$direction_handler/Bottom.play("Idle")
	elif direction != 0:
		$direction_handler/Bottom.play("Run")
	
	if state == NORMAL:
		if not is_on_floor():
			$direction_handler/Top.play("Jump")
		elif direction == 0:
			$direction_handler/Top.play("Idle")
		elif direction != 0:
			$direction_handler/Top.play("Run")

func attack01():
	SPEED = 50
	$attack01Timer.start()
	$direction_handler/Top.play("Shoot")
	state = null

func _on_attack_01_timer_timeout():
	if Input.is_action_pressed("ui_accept"):
		state = ATTACK01
	else:
		state = NORMAL

func _on_hitbox_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area.name == "out_of_bounds":
		health -= 10
		self.position = checkpoint + Vector2(0, -20)
	if area.name == "checkPoint":
		checkpoint = self.position
