extends Control

signal start_game
signal quit_game

func _ready():
	connect("start_game", get_parent(), "_on_start_game")
	connect("quit_game", get_parent(), "_on_quit_game")

func _on_ButtonNewGame_pressed():
	emit_signal("start_game", self)

func _on_ButtonQuit_pressed():
	emit_signal("quit_game")
