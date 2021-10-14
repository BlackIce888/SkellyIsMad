extends KinematicBody2D

export (int,       0,   1000) var health        = 250
export (float,   0.0,  100.0) var min_speed     = 50.0
export (float, 100.0, 1000.0) var max_speed     = 400.0
export (float,   0.0,   50.0) var stop_distance = 5.0
export (float,   0.0,  100.0) var camera_speed  = 50.0 
#export var pistol_cap    : int = 6
#export var shotgun_cap   : int = 2
#export var rifle_cap     : int = 30

var bullet                    : PackedScene = preload("res://scenes/projectiles/Bullet.tscn")
var move_icon                 : Resource    = load("res://assets/icons/circle_01.png")
var crosshair                 : Resource    = load("res://assets/icons/magic_03.png")
var pistolSX                  : Resource    = load("res://assets/sound-fx/revolver.wav")
var shotgunSX                 : Resource    = load("res://assets/sound-fx/shotgun.wav")
var rifleSX                   : Resource    = load("res://assets/sound-fx/rifle.wav")
var emptySX                   : Resource    = load("res://assets/sound-fx/empty.wav")
var direction                 : Vector2     = Vector2.ZERO
var cursor_origin             : Vector2     = Vector2.ZERO
var last_cursor_move_position : Vector2     = Vector2.ZERO
var is_in_shooting_mode       : bool        = false
var is_shooting_pistol        : bool        = false
var is_shooting_shotgun       : bool        = false
var is_shooting_rifle         : bool        = false
#var pistol_bullets            : int = pistol_cap
#var shotgun_bullets           : int = shotgun_cap
#var rifle_bullets             : int = rifle_cap

enum Weapon {PISTOL, SHOTGUN, RIFLE}

signal game_over

func _ready():
	Input.set_custom_mouse_cursor(move_icon, Input.CURSOR_POINTING_HAND)
	Input.set_custom_mouse_cursor(crosshair, Input.CURSOR_CROSS)
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	connect("game_over", owner.get_parent(), "_on_game_over")
	
func _physics_process(delta):
	if health <= 0:
		game_over()
	if Input.is_action_just_pressed("action_rmb") || Input.is_action_just_released("action_rmb"):
		_toggle_mouse_mode()
	if !is_in_shooting_mode:
		if position.distance_to(get_global_mouse_position()) > stop_distance:
			direction = get_global_mouse_position() - position
		else:
			direction = Vector2.ZERO
	$MainCamera.position = lerp(cursor_origin, $Cursor.position, camera_speed / 100.0)
	move_and_collide(direction.normalized() * max(min_speed, min(direction.length(), max_speed)) * delta)

func _input(event):
	if event is InputEventMouseButton:
		handle_mouse_button_input(event)
	if event is InputEventMouseMotion:
		handle_mouse_motion_input(event)
	if event is InputEventKey:
		handle_key_input(event)

func handle_mouse_motion_input(event : InputEventMouseMotion):
	if !is_in_shooting_mode:
		last_cursor_move_position = event.position
	$Cursor.position = get_local_mouse_position()
	if $Cursor.position.x < 0 :
		$Body.set_scale(Vector2(-1, 1))
	else:
		$Body.set_scale(Vector2(1, 1))
	$BulletSpawn.look_at(get_global_mouse_position())
	$BulletSpawn.position = $Cursor.position.normalized() * 10.0
	
func handle_key_input(event : InputEventKey):
	if event.get_action_strength("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func handle_mouse_button_input(event : InputEventMouseButton):
	if event.is_action("action_lmb"):
		if event.is_doubleclick():
			is_shooting_pistol = false
			is_shooting_shotgun = true
			is_shooting_rifle = false
			$GunTimer.start(.3)
		if event.is_action_pressed("action_lmb") && !is_shooting_shotgun:
			is_shooting_pistol = false
			is_shooting_shotgun = false
			$GunTimer.start(.25)
		if event.is_action_released("action_lmb") && !is_shooting_shotgun && !is_shooting_rifle:
			is_shooting_pistol = true
			is_shooting_shotgun = false
			is_shooting_rifle = false

	if event.is_action_released("action_rmb"):
		$Cursor.position = last_cursor_move_position

func shoot_pistol():
	$SoundEffectPlayer.stream = pistolSX
	var b : Area2D = bullet.instance()
	owner.add_child(b)
	b.init(
		b.BulletType.PISTOL,
		$BulletSpawn.global_transform
	)
	$SoundEffectPlayer.play()
	
func shoot_shotgun():
	$SoundEffectPlayer.stream = shotgunSX
	for count in ceil(rand_range(3.0, 7.0)):
		var b : Area2D = bullet.instance()
		owner.add_child(b)
		b.init(
			b.BulletType.SHOTGUN,
			$BulletSpawn.global_transform
		)
	$SoundEffectPlayer.play()

func shoot_rifle():
	$SoundEffectPlayer.stream = rifleSX
	var b : Area2D = bullet.instance()
	owner.add_child(b)
	b.init(
		b.BulletType.RIFLE,
		$BulletSpawn.global_transform
	)
	$SoundEffectPlayer.play()


func toggle_weapon_visibility(weapon : int):
	$Body/Pistol.visible = false
	$Body/Shotgun.visible = false
	$Body/Rifle.visible = false
	match weapon:
		Weapon.PISTOL:
			$Body/Pistol.visible = true
			$Body/Pistol.set_frame(0)
			$Body/Pistol.look_at(get_global_mouse_position())
		Weapon.SHOTGUN:
			$Body/Shotgun.visible = true
			$Body/Shotgun.set_frame(0)
			$Body/Shotgun.look_at(get_global_mouse_position())
		Weapon.RIFLE:
			$Body/Rifle.visible = true
			$Body/Rifle.set_frame(0)
			$Body/Rifle.look_at(get_global_mouse_position())

func _toggle_mouse_mode():
	if is_in_shooting_mode:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		#Input.warp_mouse_position($Cursor.position)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_CROSS)
	is_in_shooting_mode = !is_in_shooting_mode

func _on_GunTimer_timeout():
	if is_shooting_rifle:
		toggle_weapon_visibility(Weapon.RIFLE)
		$Body/Rifle.play()
		shoot_rifle()
		is_shooting_rifle = false
		$GunTimer.start(.00000001)
	elif is_shooting_shotgun:
		toggle_weapon_visibility(Weapon.SHOTGUN)
		$Body/Shotgun.play()
		shoot_shotgun()
		$GunTimer.stop()
		is_shooting_shotgun = false
	elif is_shooting_pistol:
		toggle_weapon_visibility(Weapon.PISTOL)
		$Body/Pistol.play()
		shoot_pistol()
		$GunTimer.stop()
		is_shooting_pistol = false
	elif Input.is_action_pressed("action_lmb"):
		is_shooting_rifle = true
		$GunTimer.start(.2)
	else:
		is_shooting_rifle = false
		$GunTimer.stop()

func game_over():
	emit_signal("game_over")

func _on_HitDetectionArea_area_entered(area):
	if area.is_in_group("projectile"):
		health -= area.damage
		if health >= 0:
			var health_percentage = float(health)/250
			modulate = Color(1, health_percentage, health_percentage, health_percentage)


