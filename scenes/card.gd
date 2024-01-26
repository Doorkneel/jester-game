extends Area2D

var card_id
var is_mouse_hovering = false

func load_card_data(card_id):
	pass

func _process(delta):
	if is_mouse_hovering == true && Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		position = get_global_mouse_position()

func _on_mouse_entered():
		is_mouse_hovering = true

func _on_mouse_exited():
	is_mouse_hovering = false
