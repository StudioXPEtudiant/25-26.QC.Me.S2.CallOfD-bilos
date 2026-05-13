extends CharacterBody3D

var base_head_y = 0.0
var bob_time = 0.0
var bob_amount = 0.05
var bob_speed = 10.0
var can_move = false
var ammo_label

var tracer_speed = 50
var tracer_active = false

@export var sprint_speed: float = 9.0
@onready var tracer = get_node_or_null("Head/Camera3D/Tracer")
@onready var raycast = $Head/Camera3D/RayCast3D
@onready var cam = $Head/Camera3D

@export var speed: float = 5.0
var mouse_sensitivity := 0.002
@export var jump_velocity: float = 4
@export var gravity: float = 9.8

var base_sensitivity := 0.002
var ads_multiplier := 0.3
var target_sensitivity := 0.002

@export var fire_rate: float = 0.1
var can_shoot := true

var max_ammo := 30
var ammo := 30

var reloading := false
var reload_time := 1.5
var reload_progress := 0.0

var head: Node3D
var pitch: float = 0.0
var crosshair

func _ready():
	add_to_group("player")
	ammo_label = get_tree().current_scene.find_child("AmmoLabel", true, false)

	mouse_sensitivity = Global.sensitivity
	base_sensitivity = Global.sensitivity
	target_sensitivity = base_sensitivity

	head = $Head
	base_head_y = head.position.y

	can_move = get_tree().current_scene.name == "World"

	crosshair = get_tree().current_scene.find_child("Crosshair", true, false)

	if can_move:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$Head/Camera3D.current = true
		if crosshair:
			crosshair.visible = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$Head/Camera3D.current = false
		if crosshair:
			crosshair.visible = false

func _on_sens_changed(value):
	mouse_sensitivity = Global.sensitivity
	base_sensitivity = Global.sensitivity

func _unhandled_input(event):
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

func _physics_process(delta):
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

	if ammo_label:
		ammo_label.text = str(ammo) + "/" + str(max_ammo)

	if Input.is_action_pressed("aim"):
		target_sensitivity = base_sensitivity * ads_multiplier
	else:
		target_sensitivity = base_sensitivity

	mouse_sensitivity = lerp(mouse_sensitivity, target_sensitivity, delta * 10.0)

	if Input.is_action_pressed("click") and can_shoot and ammo > 0 and not reloading:
		shoot()

	if Input.is_action_just_pressed("reload") and ammo < max_ammo and not reloading:
		start_reload()

	if reloading:
		reload_progress += delta

	var result = raycast.get_collider()

	if crosshair:
		crosshair.reloading = reloading
		crosshair.reload_progress = reload_progress / reload_time
		crosshair.queue_redraw()

		if result and result.has_method("hit"):
			crosshair.set_color(Color.RED)
		else:
			crosshair.set_color(Color.WHITE)

	var velocity_horizontal = Vector3(velocity.x, 0, velocity.z).length()

	var speed_mult = 1.0
	if Input.is_action_pressed("sprint"):
		speed_mult = 1.8

	if velocity_horizontal > 0 and is_on_floor():
		bob_time += delta * bob_speed * speed_mult
		head.position.y = base_head_y + sin(bob_time) * bob_amount * speed_mult
	else:
		bob_time = 0.0
		head.position.y = lerp(head.position.y, base_head_y, delta * 10.0)

	if crosshair:
		if Input.is_action_pressed("aim"):
			crosshair.set_gap(0.0)
		else:
			var target_gap = 10.0

			if velocity_horizontal > 0:
				target_gap = 18.0

			if Input.is_action_pressed("sprint"):
				target_gap = 24.0

			crosshair.set_gap(lerp(float(crosshair.gap), float(target_gap), delta * 12.0))

func shoot():
	can_shoot = false
	ammo -= 1

	var from = cam.global_transform.origin
	var to = from + -cam.global_transform.basis.z * 1000

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_bodies = true

	var result = get_world_3d().direct_space_state.intersect_ray(query)

	if result and result.collider.has_method("hit"):
		result.collider.hit()

	if crosshair:
		crosshair.set_gap(crosshair.gap + 6.0)

	if tracer:
		tracer.position = Vector3(0.3, -0.225, -5)
		tracer.visible = true
		tracer.scale.z = 0.5

		await get_tree().create_timer(0.02).timeout
		tracer.scale.z = 3
		await get_tree().create_timer(0.05).timeout
		tracer.visible = false

	if ammo <= 0:
		start_reload()

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func start_reload():
	reloading = true
	reload_progress = 0.0

	await get_tree().create_timer(reload_time).timeout

	ammo = max_ammo
	reloading = false
