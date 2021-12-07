extends Control

func _ready():
	$PlayButton.focus_mode = false
	
func _on_PlayButton_pressed():
	var _scene = get_tree().change_scene("res://Scenes/Game.tscn")
