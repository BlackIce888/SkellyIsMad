extends Area2D

var speed : float
var damage : int

enum BulletType {
	PISTOL,
	SHOTGUN,
	RIFLE,
}

func _ready():
	$DespawnTimer.start(2.0)

func _physics_process(delta):
	position += transform.x * speed * delta

func init(_bulletType : int, _transform : Transform2D):
	transform = _transform
	match _bulletType:
		BulletType.PISTOL:
			damage = 65
			speed = rand_range(900.0, 950.0)
			rotation_degrees += rand_range(0.0, 1.0)  
		BulletType.SHOTGUN:
			damage = 15
			speed = rand_range(650.0, 850.0)
			rotation_degrees += rand_range(0.0, 8.0)  
		BulletType.RIFLE:
			damage = 35
			speed = rand_range(900.0, 950.0)
			rotation_degrees += rand_range(0.0, 4.0)     
	
func _on_Bullet_body_entered(body):
	if body.is_in_group("terrain") || body.is_in_group("enemies"):
		visible = false
		$HitEffectPlayer.play()
		yield ($HitEffectPlayer, "finished")
		queue_free()

func _on_DespawnTimer_timeout():
	queue_free()
