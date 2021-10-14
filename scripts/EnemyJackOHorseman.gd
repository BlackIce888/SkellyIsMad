extends "Enemy.gd"

signal game_complete

func _ready():
	connect("game_complete", owner.get_parent(), "_on_game_complete")
	
func _process(delta):
	direction = Vector2(0.0, 0.0)

func die():
	emit_signal("game_complete")

func fire_projectile():
	var distance = player.position.x - position.x
	var p : Area2D = projectile.instance()
	owner.add_child(p)
	if distance > 50.0 && $ProjectileSpawn.position.x < 0:
		$ProjectileSpawn.position.x *= -1
	if distance < 50.0 && $ProjectileSpawn.position.x > 0:
		$ProjectileSpawn.position.x *= -1
	if spawn_rotation > 70:
		rotation_increment *= -1
	elif spawn_rotation < -70:
		rotation_increment *= -1
	p.init(
		$ProjectileSpawn.global_transform,
		attack_dmg,
		attack_speed,
		$ProjectileSpawn.rotation_degrees - rotation_offset + spawn_rotation
	)
	spawn_rotation += rotation_increment
