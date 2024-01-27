class_name Game
extends Node

var round_number: int = 0
var max_round_number: int = 7

@onready var slots = get_tree().get_nodes_in_group("slots") as Array[CardSlot]

func _ready() -> void:
	for card in get_tree().get_nodes_in_group("cards") as Array[Card]:
		card.connect("card_released", self._on_card_released)
		card.connect("card_picked_up", self._on_card_picked_up)

func _on_card_released(card: Card) -> void:
	for slot in slots:
		slot.disconnect("slot_hovered", card._on_slot_hovered)

func _on_card_picked_up(card: Card) -> void:
	for slot in slots:
		slot.connect("slot_hovered", card._on_slot_hovered)
