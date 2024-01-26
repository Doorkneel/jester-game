class_name Game
extends Node

# Tracks which setup is currently active and pending resolution
var current_setup: String = ""

var round_number: int = 0
var max_round_number: int = 7

var highlighted_slot: CardSlot
var dragged_card: Card

func _ready():
	pass # Replace with function body.

func _process(delta):
	pass

func _on_card_slot_highlighted(slot: CardSlot) -> void:
	highlighted_slot = slot

func _on_card_slot_unhighlighted() -> void:
	highlighted_slot = null

func _on_card_dragged(card: Card) -> void:
	pass

func _on_card_released(card: Card) -> void:
	pass
