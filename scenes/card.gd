class_name Card
extends Area2D

signal card_dragged(this: Card)
signal card_released(this: Card)

var card_id
var is_hovering = false
var is_selected = false

func load_card_data(card_id):
	pass

func _process(delta):
	if is_selected:
		position = get_global_mouse_position()

func _on_mouse_entered():
	is_hovering = true

func _on_mouse_exited():
	is_hovering = false

func _input(event):
	if Input.is_action_just_pressed("click"):
		print("pressed")
		if is_hovering:
			is_selected = true
	elif Input.is_action_just_released("click"):
		print("released")
		is_selected = false
