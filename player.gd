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
@export var jump_velocity: float = 4.0
@export var gravity: float = 9.8

var base_sensitivity := 0.002
var ads_multiplier := 0.3
var target_sensitivity := 0.002

@export var fire_rate: float = 0.1
var can_shoot := true

var reloading := false
var reload_time := 1.5
var reload_progress := 0.0

var head: Node3D
var pitch: float = 0.0
var crosshair

@onready var fx05 = $Head/Camera3D/FX05
@onready var pistol = $Head/Camera3D/Pistol
@onready var sniper = $Head/Camera3D/Sniper

var current_weapon = "fx05"

var weapons = {
	"fx05": {
		"fire_rate": 0.09,
		"max_ammo": 30,
		"ammo": 30,
		"tracer_y": -0.225
	},
	"pistol": {
		"fire_rate": 0.2,
		"max_ammo": 12,
		"ammo": 12,
		"tracer_y": -0.28
	},
	"sniper": {
		"fire_rate": 1.0,
		"max_ammo": 5,
		"ammo": 5,
		"tracer_y": -0.25
	}
}

func _ready():
	add_to_group("player")

	ammo_label = get_tree().current_scene.find_child("AmmoLabel", true, false)

	equip_weapon("fx05")

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
		ammo_label.text = str(
			weapons[current_weapon]["ammo"]
		) + "/" + str(
			weapons[current_weapon]["max_ammo"]
		)

	if Input.is_action_pressed("aim"):
		target_sensitivity = base_sensitivity * ads_multiplier
	else:
		target_sensitivity = base_sensitivity

	mouse_sensitivity = lerp(
		mouse_sensitivity,
		target_sensitivity,
		delta * 10.0
	)

	if Input.is_action_pressed("click") and can_shoot and weapons[current_weapon]["ammo"] > 0 and not reloading:
		shoot()

	if Input.is_action_just_pressed("reload") and weapons[current_weapon]["ammo"] < weapons[current_weapon]["max_ammo"] and not reloading:
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

	var velocity_horizontal = Vector3(
		velocity.x,
		0,
		velocity.z
	).length()

	var speed_mult = 1.0

	if Input.is_action_pressed("sprint"):
		speed_mult = 1.8

	if velocity_horizontal > 0 and is_on_floor():
		bob_time += delta * bob_speed * speed_mult

		head.position.y = base_head_y + sin(bob_time) * bob_amount * speed_mult
	else:
		bob_time = 0.0

		head.position.y = lerp(
			head.position.y,
			base_head_y,
			delta * 10.0
		)

	if crosshair:
		if Input.is_action_pressed("aim"):
			crosshair.set_gap(0.0)
		else:
			var target_gap = 10.0

			if velocity_horizontal > 0:
				target_gap = 18.0

			if Input.is_action_pressed("sprint"):
				target_gap = 24.0

			crosshair.set_gap(
				lerp(
					float(crosshair.gap),
					float(target_gap),
					delta * 12.0
				)
			)

	if Input.is_action_just_pressed("weapon1"):
		equip_weapon("fx05")

	if Input.is_action_just_pressed("weapon2"):
		equip_weapon("pistol")

	if Input.is_action_just_pressed("weapon3"):
		equip_weapon("sniper")

func shoot():
	can_shoot = false

	weapons[current_weapon]["ammo"] -= 1

	var from = cam.global_transform.origin

	var to = from + -cam.global_transform.basis.z * 1000

	var query = PhysicsRayQueryParameters3D.create(from, to)

	query.collide_with_bodies = true

	var result = get_world_3d().direct_space_state.intersect_ray(query)

	if result and result.collider.has_method("hit"):
		result.collider.hit()
	else:
		var score = get_tree().current_scene.find_child("Score", true, false)

		if score:
			score.text = str(int(score.text) - 1)

	if crosshair:
		crosshair.set_gap(crosshair.gap + 6.0)

	if tracer:
		tracer.position = Vector3(
			0.3,
			weapons[current_weapon]["tracer_y"],
			-6
		)

		tracer.visible = true
		tracer.scale.z = 0.5

		await get_tree().create_timer(0.02).timeout

		tracer.scale.z = 3

		await get_tree().create_timer(0.05).timeout

		tracer.visible = false

	if weapons[current_weapon]["ammo"] <= 0:
		start_reload()

	await get_tree().create_timer(fire_rate).timeout

	can_shoot = true

func start_reload():
	reloading = true

	reload_progress = 0.0

	await get_tree().create_timer(reload_time).timeout

	weapons[current_weapon]["ammo"] = weapons[current_weapon]["max_ammo"]

	reloading = false

func equip_weapon(name):
	current_weapon = name

	fx05.visible = false
	pistol.visible = false
	sniper.visible = false

	match name:
		"fx05":
			fx05.visible = true

		"pistol":
			pistol.visible = true

		"sniper":
			sniper.visible = true

	fire_rate = weapons[name]["fire_rate"]
