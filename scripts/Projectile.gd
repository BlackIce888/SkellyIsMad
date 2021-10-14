extends Area2D

export (float, 100.0, 10000.0) var speed  : float
export (int, 0, 1000)          var damage : int

var hit_sx : Resource = load("res://assets/sound-fx/hit.wav")

func _ready():
	$DespawnTimer.start(4.0)

func _physics_process(delta):
	position += transform.x * speed * delta

func init(_transform : Transform2D, _damage : int, _speed : float, _rotation_degrees : float):
	transform = _transform
	damage = _damage
	speed = _speed
	rotation_degrees = _rotation_degrees     

func _on_Projectile_body_entered(body):
	if body.is_in_group("terrain") || body.is_in_group("player"):
		visible = false
		$SoundEffectPlayer.play()
		yield($SoundEffectPlayer, "finished")
		queue_free()

func _on_DespawnTimer_timeout():
	queue_free()
