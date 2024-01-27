class_name Game
extends Node

var round_number: int = 0
var max_round_number: int = 7

var highlighted_slot: CardSlot

func _ready() -> void:
	for slot in get_tree().get_nodes_in_group("slots") as Array[CardSlot]:
		slot.connect("slot_highlighted", self._on_card_slot_highlighted)
	for card in get_tree().get_nodes_in_group("cards") as Array[Card]:
		card.connect("card_released", self._on_card_released)

func _on_card_slot_highlighted(slot: CardSlot) -> void:
	highlighted_slot = slot

func _on_card_released(card: Card) -> void:
	if highlighted_slot:
		card.snap_to_slot(highlighted_slot)
