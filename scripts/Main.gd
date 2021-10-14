extends Node2D

var menu              = preload("res://scenes/MainMenu.tscn")
var level1            = preload("res://scenes/Level1.tscn")
var end_screen        = preload("res://scenes/GameCompleteScreen.tscn")
var gameover_screen   = preload("res://scenes/GameOverScreen.tscn")
onready var root = get_tree().get_root()

func _ready():
	add_child(menu.instance())
	#get_tree().change_scene_to(level1)

func _on_start_game(current):
	root.remove_child(current)
	current.call_deferred("free")
	add_child(level1.instance())
	#get_tree().change_scene_to(level1)
	
func _on_restart_game():
	root.remove_child($GameCompleteScreen)
	$GameCompleteScreen.call_deferred("free")
	add_child(level1.instance())
	#get_tree().change_scene_to(level1)
	
func _on_quit_game():
	get_tree().quit()

func _on_game_over():
	root.remove_child($Level1)
	$Level1.call_deferred("free")
	add_child(gameover_screen.instance())

func _on_game_complete():
	root.remove_child($Level1)
	$Level1.call_deferred("free")
	add_child(end_screen.instance())
