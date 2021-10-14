extends KinematicBody2D

export (int, 0, 10000)         var health                 = 120
export (int, 0, 100)           var attack_dmg             = 20
export (float, 0.0, 10.0)      var attack_duration        = 2.0
export (float, 0.0,  5.0)      var attack_interval        = 0.5
export (float, 50.0, 1000.0)   var attack_speed           = 300.0 
export (float, 0.1, 10.0)      var attack_cooldown        = 2.0
export (Vector2)               var direction              = Vector2(-1, 0)
export (Vector2)               var speed                  = Vector2(20.0, 0.0)
export (PackedScene)           var projectile             = preload("res://scenes/projectiles/Projectile.tscn")
export (float, 0.0, 360.0)     var spawn_rotation         = 0
export (float, 0.0, 360.0)     var rotation_offset        = 30
export (float, 0.0, 360.0)     var rotation_increment     = 15

var player                : KinematicBody2D
var velocity              : Vector2        = Vector2.ZERO
var has_direction_changed : bool           = false
var is_searching          : bool           = true
var is_attack_on_cooldown : bool           = false


func _ready():
	roam()

func _physics_process(delta):
	if (health <= 0):
		die()
	if !is_searching && !is_attack_on_cooldown:
		followPlayer()
		if $AttackTimer.is_stopped():
			start_attack()
		elif $ShootTimer.is_stopped():
			shoot()
	elif $RoamTimer.is_stopped():
		roam()
	velocity = direction * speed
	velocity = move_and_slide(velocity)

func randomizeDirection() -> int:
	return int(randi() % 2 * sign(rand_range(-1, 1)))

func followPlayer():
	var distance : Vector2 = Vector2(
		player.position.x - position.x,
		player.position.y - position.y
	)
	var direction_change : Vector2 = Vector2(sign(distance.x), sign(distance.y))
	if distance.x <= 10.0 && distance.x >= -10.0:
		direction_change.x = 0
	if distance.y <= 10.0 && distance.y >= -10.0:
		direction_change.y = 0
	if direction.x != direction_change.x && speed.x > 0.0 || direction.y != direction_change.y && speed.y > 0.0:
		has_direction_changed = true
		direction = direction_change
		playMovementAnimation()
	else:
		has_direction_changed = false

func die():
	queue_free()

func start_attack():
	$AttackTimer.start(attack_duration)
	
func shoot():
	$ShootTimer.start(attack_interval)

func roam(duration : float = 2.0):
	$RoamTimer.start(duration)
	playMovementAnimation()

func playMovementAnimation():
	match int(direction.x):
		0:
			$AnimationPlayer.play("idle")
		1:
			$AnimationPlayer.play("walk_right")
		-1:
			$AnimationPlayer.play("walk_left")

func fire_projectile():
	var p : Area2D = projectile.instance()
	owner.add_child(p)
	p.init(
		$ProjectileSpawn.global_transform,
		attack_dmg,
		attack_speed,
		$ProjectileSpawn.rotation_degrees - rotation_offset + spawn_rotation
	)
	spawn_rotation += rotation_increment

func _on_PlayerDetectionArea_body_entered(body):
	if body.is_in_group("player"):
		is_searching = false
		player = body
		$RoamTimer.stop()
		followPlayer()
		playMovementAnimation()

func _on_PlayerDetectionArea_body_exited(body):
	if body.is_in_group("player"):
		is_searching = true

func _on_HitDetectionArea_projectile_entered(area):
	if area.is_in_group("projectile"):
		health -= area.damage

func _on_RoamTimer_timeout():
	direction = Vector2(randomizeDirection(), randomizeDirection())

func _on_AttackTimer_timeout():
	spawn_rotation = 0.0
	$ShootTimer.stop()
	is_attack_on_cooldown = true
	$CooldownTimer.start(attack_cooldown)

func _on_ShootTimer_timeout():
	$ProjectileSpawn.look_at(player.position)
	fire_projectile()
	$SoundEffectPlayer.play()

func _on_CooldownTimer_timeout():
	is_attack_on_cooldown = false
	$RoamTimer.stop()
