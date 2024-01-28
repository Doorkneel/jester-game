class_name MainMenu
extends CanvasLayer

const game_scene = preload("res://scenes/game.tscn")

func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)

func _on_quit_pressed() -> void:
	get_tree().quit()
