extends Node2D

var click_all = false
var ignore_unclickable = true

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var params = PhysicsPointQueryParameters2D.new()
		params.position = get_global_mouse_position()
		params.collide_with_areas = true
		var shapes = get_world_2d().direct_space_state.intersect_point(params, 32)
		
		for shape in shapes:
			if shape["collider"].has_method("on_click"):
				shape["collider"].on_click()
				
				if !click_all and ignore_unclickable:
					break # Thus clicks only the topmost clickable
			
			if !click_all and !ignore_unclickable:
				break # Thus stops on the first shape
