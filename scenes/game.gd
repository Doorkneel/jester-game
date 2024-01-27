class_name Game
extends Node

@onready var slots = get_tree().get_nodes_in_group("slots") as Array[CardSlot]

@onready var rounds_label = $CanvasLayer/Rounds as Label
@onready var humour_bar = $CanvasLayer/Humour as ProgressBar
@onready var card_draw_timer = $CardDrawTimer as Timer
@onready var card_spawn = $CardSpawn as Marker2D
@onready var hand_pos = $Path2D/HandPos as PathFollow2D

@onready var stage_slots = [$Stage/Stage1, $Stage/Stage2, $Stage/Stage3] as Array[CardSlot]
@onready var court_slots = [$Court/Court1, $Court/Court2] as Array[CardSlot]
@onready var commoner_slots = [$Commoners/Commoners1, $Commoners/Commoners2] as Array[CardSlot]
@onready var king_slot = $King/King as CardSlot

const card_scene = preload("res://scenes/card.tscn")

# starting cards
@export var starting_cards = {
	"quip": 3,
	"improv": 2,
	"setup": 2,
	"toilet_humour": 1,
	"audience_participation": 1
}

# crowd attitudes (range between -40 and 40)
var commoner_attitude: int = 0
var court_attitude: int = 0

# main game counters
var humour: int = 5
var rounds_remaining: int = 7

# current deck and hand
var deck: Array[String] = []
var hand: Array[Card] = []
var cards_left_to_draw: int = 5

func _ready() -> void:
	# initialize UI
	rounds_label.text = str(rounds_remaining)
	humour_bar.value = humour
	
	# connect card signals
	for card in get_tree().get_nodes_in_group("cards") as Array[Card]:
		card.connect("card_released", self._on_card_released)
		card.connect("card_picked_up", self._on_card_picked_up)
	
	# inititalize deck
	for card in starting_cards:
		for i in range(starting_cards[card]): deck.append(card)
	deck.shuffle()
	
	# draw initial hand
	card_draw_timer.start()

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

func adjust_attitude(audience, favour) -> void:
	if audience == "court":
		court_attitude = clamp(court_attitude + favour, -50, 50)
	else: # audience == "commoner"
		commoner_attitude = clamp(commoner_attitude + favour, -50, 50)

func get_audience_cards(audience) -> Array[String]:
	var attitude: int = court_attitude if audience == "court" else commoner_attitude
	var sentiment: String = "GOOD" if attitude >= 0 else "BAD"
	
	var cards: Array[String] = []
	for i in range(2):
		if randf() < ease_in_out(abs(attitude) / 40): cards.append(sentiment)
		else: cards.append("NONE")
	return cards

func ease_in_out(x: float) -> float:
	return 2 * x * x if 0 < 0.5 else 1 - pow(-2 * x + 2, 2) / 2

func draw_card() -> void:
	var new_card: Card = card_scene.instantiate()
	new_card.connect("card_released", self._on_card_released)
	new_card.connect("card_picked_up", self._on_card_picked_up)
	new_card.connect("card_played_to_slot", self._on_card_played_to_slot)
	
	hand.append(new_card)
	new_card.pos_in_hand = len(hand) - 1
	new_card.position = card_spawn.position
	layout_hand()
	add_child(new_card)

func _on_card_played_to_slot(card: Card) -> void:
	hand.remove_at(card.pos_in_hand)
	card.pos_in_hand = -1
	for i in range(len(hand)): hand[i].pos_in_hand = i
	layout_hand()

func layout_hand() -> void:
	for i in range(len(hand)):
		var width_proportion: float = 1 - exp(-len(hand) / 6.0)
		hand_pos.progress_ratio = 0.5 - 0.5 * width_proportion + width_proportion * (i + 0.5) / len(hand)
		hand[i].desired_position = hand_pos.global_position
		hand[i].desired_rotation = hand_pos.rotation

func _on_card_draw_timer_timeout() -> void:
	draw_card()
	cards_left_to_draw -= 1
	if cards_left_to_draw > 0: card_draw_timer.start()
