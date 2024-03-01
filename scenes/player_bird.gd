extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
const GRAVITY_MOD = 1.5

const START_POS = Vector2(50, 440)
const MIN_VEL = -600.0
const MAX_VEL = 600.0
const FLAP_ACCEL = -3500.0
const FLAP_BOOST = -120.0

var flapping : bool
var flying : bool
var falling : bool


func _physics_process(delta):
	if flying or falling:
		velocity.y += gravity * delta * GRAVITY_MOD
		velocity.y = clamp(velocity.y, MIN_VEL, MAX_VEL)
		if flying:
			set_rotation(deg_to_rad(velocity.y * 0.05))
			$AnimatedSprite2D.play()
			if flapping:
				velocity.y += FLAP_ACCEL * delta
		elif falling:
			velocity.y = clamp(velocity.y, 0, MAX_VEL)
			set_rotation(PI/2)
			$AnimatedSprite2D.stop()
		move_and_collide(velocity * delta)
	else:
		$AnimatedSprite2D.stop()
		
func setup():
	falling = false
	flying = false
	flapping = false
	position = START_POS
	set_rotation(0)
	velocity = Vector2.ZERO
	
	
func flap():
	velocity.y += FLAP_BOOST
	flapping = true
	
func stop_flap():
	flapping = false

	
