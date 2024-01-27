class_name Game
extends Node

var rounds_remaining: int = 7

@onready var slots = get_tree().get_nodes_in_group("slots") as Array[CardSlot]

@onready var rounds_label = $CanvasLayer/Rounds as Label
@onready var humour_bar = $CanvasLayer/Humour as ProgressBar

# card slots
@onready var stage_slots = [
	$Stage/Stage1,
	$Stage/Stage2,
	$Stage/Stage3
] as Array[CardSlot]

@onready var court_slots = [
	$Court/Court1,
	$Court/Court2
] as Array[CardSlot]

@onready var commoner_slots = [
	$Commoners/Commoners1,
	$Commoners/Commoners2
] as Array[CardSlot]

@onready var king_slot = $King/King as CardSlot

# crowd attitudes (range between -1 and 1)
var commoner_attitude: float = 0
var court_attitudes: float = 0

# current humour level
var humour: int = 5

func _ready() -> void:
	# initialize UI
	rounds_label.text = str(rounds_remaining)
	humour_bar.value = humour
	
	# connect card signals
	for card in get_tree().get_nodes_in_group("cards") as Array[Card]:
		card.connect("card_released", self._on_card_released)
		card.connect("card_picked_up", self._on_card_picked_up)

func _on_card_released(card: Card) -> void:
	for slot in slots:
		slot.disconnect("slot_hovered", card._on_slot_hovered)

func _on_card_picked_up(card: Card) -> void:
	for slot in slots:
		slot.connect("slot_hovered", card._on_slot_hovered)

func advance_round() -> void:
	rounds_remaining -= 1
	
	if rounds_remaining <= 0:
		# TODO Game over state!
		pass
	else:
		rounds_label.text = str(rounds_remaining)
		
		for slot in stage_slots + court_slots + commoner_slots:
			# TODO take card effects
			pass
		
		# TODO take king card effect
