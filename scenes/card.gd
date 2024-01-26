extends Area2D

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

func _on_mouse_exit():
	is_hovering = false

func _input(event):
	if Input.is_action_just_pressed("click"):
		if is_hovering:
			is_selected = true
	elif Input.is_action_just_released("click"):
		is_selected = false
