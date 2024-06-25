extends CharacterBody2D

const GRAVITY : int = 4200
const JUMP_SPEED : int = -1500
@onready var jump_sound = $JumpSound
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var run_col = $RunCol
@onready var bgm = $BGM
@onready var hurt = $Hurt
@onready var mile_score = $mileScore
@onready var duck_particles = $DuckParticles

# Called when the node enters the scene tree for the first time.
func _ready():
	bgm.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.y += GRAVITY * delta
	duck_particles.emitting = false

	
	if is_on_floor():
		if not get_parent().game_run:
			animated_sprite_2d.play("Idle")
		else:
			run_col.disabled = false
			if Input.is_action_pressed("ui_accept"):
				velocity.y = JUMP_SPEED
				jump_sound.play()
			elif Input.is_action_pressed("ui_down"):
				animated_sprite_2d.play("Duck")
				duck_particles.emitting = true
				run_col.disabled = true
			else:
				animated_sprite_2d.play("Run")
				duck_particles.emitting = false

	else:
		animated_sprite_2d.play("Jump")

	move_and_slide()


func _on_main_score_sound():
	pass # Replace with function body.
