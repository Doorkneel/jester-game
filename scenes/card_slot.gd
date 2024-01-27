class_name CardSlot
extends Area2D

signal slot_highlighted(this: CardSlot)

@onready var sprite: Sprite2D = $Sprite as Sprite2D

func _ready() -> void:
	pass # Replace with function body.

func _on_mouse_entered() -> void:
	# TODO highlight slot
	slot_highlighted.emit(self)

func _on_mouse_exited() -> void:
	# TODO unhighlight slot
	slot_highlighted.emit(null)
