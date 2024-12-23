extends KinematicBody

signal orb_collected

export var invert_look = false
onready var look_dir = 1 if invert_look else -1
#const GRAVITY = -24.8
var vel = Vector3()
const MAX_SPEED = 7
#const JUMP_SPEED = 18
const ACCEL = 3.5

var dir = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

onready var camera = $CameraPivot/Camera
onready var rotation_helper = $CameraPivot
onready var flashlight = $CameraPivot/Flashlight

onready var flashlight_on_sfx = $Sfx/FlashlightClickOnSound
onready var flashlight_off_sfx = $Sfx/FlashlightClickOffSound
onready var footsteps_sfx = $Sfx/FootstepsSound
var footsteps_sfx_seek_pos = 0
onready var orb_collected_sfx = $Sfx/OrbCollectSound

var MOUSE_SENSITIVITY = 0.05

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)

func process_input(delta):

	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()
	
	var is_walking = input_movement_vector.x != 0 or input_movement_vector.y != 0
	if is_walking and not footsteps_sfx.playing:
		footsteps_sfx.play(footsteps_sfx_seek_pos)
	elif not is_walking and footsteps_sfx.playing:
		footsteps_sfx_seek_pos = footsteps_sfx.get_playback_position()
		footsteps_sfx.stop()

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
#	if is_on_floor():
#		if Input.is_action_just_pressed("movement_jump"):
#			vel.y = JUMP_SPEED
	# ----------------------------------

	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------
	
	# ----------------------------------
	# Toggle flashlight
	if Input.is_action_just_pressed('toggle_flashlight'):
		if flashlight.visible:
			flashlight_off_sfx.play()
		else:
			flashlight_on_sfx.play()
		flashlight.visible = not(flashlight.visible)
	# ----------------------------------

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

#	vel.y += delta * GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))


func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * look_dir))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot


func _on_area_entered(area):
	if area.is_in_group('orbs'):
		area.queue_free()
		orb_collected_sfx.play()
		emit_signal('orb_collected')
