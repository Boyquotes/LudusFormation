extends CharacterBody2D
class_name Player

# on prend la référence de la scène des particules pour les instantier
@onready var HIT_PARTICLE_SCENE = preload("res://Scenes/Player/hit_particle.tscn")

# doit être emit quand la vie du joueur change
signal life_changed

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

# statistiques de déplacement du joueur
@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
var max_fall_velocity = abs(JUMP_VELOCITY) * 3:
	set(mfv):
		max_fall_velocity = mfv if mfv != -1 else abs(JUMP_VELOCITY) * 3
@export var jumps : int = 2

# statique de la vie du joueur
@export var max_life : int = 10
var life : int = max_life:
	set(l):
		if l != life:
			life = clampi(l, 0, max_life)
			life_bar.value = life
			life_changed.emit()

# noeuds du joueur
@onready var life_bar: ProgressBar = $CanvasLayer/LifeBar
@onready var player_camera: Camera2D = $PlayerCamera
@onready var frog: AnimatedSprite2D = $Frog
@onready var player_collision: CollisionShape2D = $PlayerCollision
@onready var player_animations: AnimationPlayer = $PlayerAnimations
@onready var wall_jump_raycast: RayCast2D = $WallJumpRaycast

var start_point := Vector2.ZERO
var hit_particles_array : Array = []

func _ready():
	# connexion des signaux
	life_changed.connect(_on_player_life_changed)
	
	life_bar.max_value = max_life
	
	set_physics_process(false)
	start_point = global_position
	
	frog.play("Appear_Disappear")
	await frog.animation_finished
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_on_floor():
		jumps = 2
		gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and jumps > 0:
		if wall_jump_raycast.is_colliding() and not is_on_floor():
			return
		velocity.y = JUMP_VELOCITY
		jumps -= 1
	elif Input.is_action_just_pressed("fastdown") and not is_on_floor() and frog.animation != "WallJump":
		gravity *= 20.0
	
	if wall_jump_raycast.is_colliding():
		jumps = 1
		
	var direction := Input.get_axis("left", "right")
	if frog.animation != "WallJump":
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if not can_wall_jump():
		max_fall_velocity = -1
	
	# vérifie si le joueur change de direction
	if direction != 0:
		frog.flip_h = false if direction == 1 else true
		wall_jump_raycast.target_position.x = 12 if not frog.flip_h else -12
	
	velocity.y = clamp(velocity.y, -max_fall_velocity, max_fall_velocity)
	move_and_slide()
	
	if can_wall_jump():
		frog.play("WallJump")
		
		if velocity.y > 1.0:
			max_fall_velocity = 100
	
	# vérifie si le joueur saute, son premier saut
	elif velocity.y < 0 and jumps == 1:
		frog.play("Jump")
	
	# vérifie si le joueur saute, son deuxième saut
	elif velocity.y < 0 and jumps == 0:
		frog.play("DoubleJump")
	
	# vérifie si le joueur n'est pas sur le sol
	elif not is_on_floor():
		frog.play("Fall")
		if jumps == 2:
			jumps = 1
	
	# vérifie si le joueur est entrain de se déplacer au sol (gauche/droite)
	elif abs(velocity.x) != 0.0:
		frog.play("Run")
	
	# vérifie si le joueur ne fait rien
	else:
		frog.play("Idle")

func take_damage(damage : int) -> void:
	life -= damage
	
	var new_hit_particle = HIT_PARTICLE_SCENE.instantiate()
	add_child(new_hit_particle, true)
	(new_hit_particle as GPUParticles2D).emitting = true
	hit_particles_array.append((new_hit_particle as GPUParticles2D))
	
	player_animations.play("RESET")
	player_animations.play("damage_taken")

func death(instant_respawn : bool = false) -> void:
	frog.play("Appear_Disappear", 1.0, true)
	player_collision.disabled = true
		
	set_physics_process(false)
	await frog.animation_finished
	
	var respawn_tween := get_tree().create_tween()
	respawn_tween.tween_property(self, "global_position", start_point, 1.0)
	await respawn_tween.finished
	
	life = max_life
	set_physics_process(true)
	player_collision.disabled = false
	player_animations.play("RESET")
	player_animations.stop()
	
	for hit_particle in hit_particles_array:
		hit_particle.queue_free()
	hit_particles_array.clear()

func can_wall_jump() -> bool:
	return wall_jump_raycast.is_colliding() and not is_on_floor()

func _on_player_life_changed() -> void:
	if life <= 0:
		call("death")
