class_name CardSlot
extends Area2D

signal slot_hovered(id: int, this: CardSlot)

@export_enum("Stage", "Commoners", "Court", "King") var location: int

@onready var sprite: Sprite2D = $Sprite as Sprite2D

var contents: Array[Card] = []

func _ready() -> void:
	# TODO set visuals depending on location
	match location:
		0: sprite.modulate = Color(0.6, 0.6, 0)
		1: sprite.modulate = Color(0.5, 0.3, 0.4)
		2: sprite.modulate = Color(0, 0.6, 0.6)
		3: sprite.modulate = Color(0.8, 0, 1)

func _on_mouse_entered() -> void:
	slot_hovered.emit(self.get_instance_id(), self)

func _on_mouse_exited() -> void:
	slot_hovered.emit(self.get_instance_id(), null)

func highlight() -> void:
	# TODO visually highlight slot; told to do so by the card being dragged
	# if that card may be placed here
	pass
