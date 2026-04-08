extends CharacterBody3D

var base_head_y = 0.0
var bob_time = 0.0
var bob_amount = 0.05
var bob_speed = 10.0
var can_move = false
var tracer_speed = 50
var tracer_active = false

@export var sprint_speed: float = 9.0
@onready var tracer = get_node_or_null("Head/Camera3D/Tracer")
@onready var raycast = $Head/Camera3D/RayCast3D
@onready var cam = $Head/Camera3D
@export var speed: float = 5.0
@export var mouse_sensitivity: float = 0.0022
@export var jump_velocity: float = 3.75
@export var gravity: float = 9.8

var head: Node3D
var pitch: float = 0.0
var crosshair

func _ready():
	head = $Head
	base_head_y = head.position.y
	can_move = get_tree().current_scene.name == "World"

	crosshair = get_tree().get_current_scene().find_child("Crosshair", true, false)

	if can_move:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$Head/Camera3D.current = true
		if crosshair:
			crosshair.visible = true
			crosshair.queue_redraw()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$Head/Camera3D.current = false
		if crosshair:
			crosshair.visible = false

func _unhandled_input(event) -> void:
	if not can_move:
		return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		pitch = clamp(
			pitch - event.relative.y * mouse_sensitivity,
			deg_to_rad(-89),
			deg_to_rad(89)
		)
		head.rotation.x = pitch

func _physics_process(delta: float) -> void:
	if not can_move:
		return

	var direction = Vector3.ZERO

	var forward = -transform.basis.z
	var right = transform.basis.x

	if Input.is_action_pressed("move_forward"):
		direction += forward
	if Input.is_action_pressed("move_back"):
		direction -= forward
	if Input.is_action_pressed("move_left"):
		direction -= right
	if Input.is_action_pressed("move_right"):
		direction += right

	direction = direction.normalized()

	var current_speed = speed
	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed

	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	move_and_slide()

func _process(delta):
	if not can_move:
		return
		
	if Input.is_action_just_pressed("click"):
		shoot()
	
	var result = raycast.get_collider()

	if crosshair:
		if result and result.has_method("hit"):
			crosshair.set_color(Color.RED)
		else:
			crosshair.set_color(Color.WHITE)
	
	var velocity_horizontal = Vector3(velocity.x, 0, velocity.z).length()

	var speed_multiplier = 1.0
	if Input.is_action_pressed("sprint"):
		speed_multiplier = 1.8

	if velocity_horizontal > 0 and is_on_floor():
		bob_time += delta * bob_speed * speed_multiplier
		
		var bob_y = sin(bob_time) * bob_amount * speed_multiplier
		head.position.y = base_head_y + bob_y
	else:
		bob_time = 0.0
		head.position.y = lerp(head.position.y, base_head_y, delta * 10)

func shoot():
	var from = cam.global_transform.origin
	var to = from + -cam.global_transform.basis.z * 1000

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_bodies = true

	var result = get_world_3d().direct_space_state.intersect_ray(query)

	if result:
		if result.collider.has_method("hit"):
			result.collider.hit()
			
			var hitmarker = get_tree().get_current_scene().find_child("Hitmarker", true, false)
			if hitmarker:
				hitmarker.show_hitmarker()

	if tracer:
		tracer.position = Vector3(0.3, -0.3, -5)
		tracer.visible = true
		
		tracer.scale.z = 0.5
		
		await get_tree().create_timer(0.02).timeout
		tracer.scale.z = 3
		
		await get_tree().create_timer(0.05).timeout
		tracer.visible = false

func _on_tracer_timer_timeout() -> void:
	pass
