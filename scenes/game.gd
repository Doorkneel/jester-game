class_name Game
extends Node

@onready var slots = get_tree().get_nodes_in_group("slots") as Array[CardSlot]
@export var card_list_json: JSON

@onready var rounds_label = $CanvasLayer/Rounds as Label
@onready var humour_bar = $CanvasLayer/Humour as ProgressBar
@onready var card_draw_timer = $CardDrawTimer as Timer
@onready var card_spawn = $CardSpawn as Marker2D
@onready var hand_pos = $Path2D/HandPos as PathFollow2D
@onready var hand_hitbox = $HandHitbox as Area2D
@onready var sounds = $Sounds as Sounds

@onready var stage_zone = $Stage
@onready var court_zone = $Court
@onready var commoner_zone = $Commoners

@onready var stage_slots = [$Stage/Stage1, $Stage/Stage2, $Stage/Stage3] as Array[CardSlot]
@onready var court_slots = [$Court/Court1, $Court/Court2] as Array[CardSlot]
@onready var commoner_slots = [$Commoners/Commoners1, $Commoners/Commoners2] as Array[CardSlot]
@onready var king_slot = $King/King as CardSlot

@export var commoner_json: JSON
@export var court_json: JSON
@onready var court_cards_data = court_json.get_data() if court_json else null
@onready var commoner_cards_data = commoner_json.get_data() if commoner_json else null

const card_scene = preload("res://scenes/card.tscn")

const pause_on_card: float = 0.8
const initial_humour: int = 5

# starting cards
@export var starting_cards = {
	"quip": 3,
	"naughty_joke": 2,
	"setup": 2,
	"toilet_humour": 1,
	"crowd_work": 1
}

# crowd attitudes (range between -40 and 40)
var commoner_attitude: int = 0
var court_attitude: int = 0

# main game counters
# (humour level is found in humour_bar.value)
var rounds_remaining: int = 7

# current deck and hand
var deck: Array[String] = []
var hand: Array[Card] = []
var cards_to_draw: int = 5

func _ready() -> void:
	# initialize UI
	rounds_label.text = str(rounds_remaining)
	humour_bar.value = initial_humour
	
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
	hand_hitbox.disconnect("mouse_entered", card._on_hand_hitbox_entered)
	hand_hitbox.disconnect("mouse_exited", card._on_hand_hitbox_exited)

func _on_card_picked_up(card: Card) -> void:
	sounds.card_draw()
	for slot in slots:
		slot.connect("slot_hovered", card._on_slot_hovered)
	hand_hitbox.connect("mouse_entered", card._on_hand_hitbox_entered)
	hand_hitbox.connect("mouse_exited", card._on_hand_hitbox_exited)
	
func _on_card_returned_to_hand(card: Card) -> void:
	hand.append(card)
	card.pos_in_hand = len(hand) - 1
	layout_hand()

func get_slot_data(slot: CardSlot) -> Variant:
	if len(slot.contents) == 0: return null
	return slot.contents[len(slot.contents) - 1].card_data

func free_slot(slot: CardSlot) -> void:
	while len(slot.contents) > 0:
		var c = slot.contents.pop_front()
		c.queue_free()

func precalculate_net_humour() -> int:
	var net_humour: int = 0
	for slot in stage_slots + court_slots + commoner_slots: # TODO loop over king too?
		var data = get_slot_data(slot)
		if not data: continue
		net_humour += data["effect"]["comedy"]
	return net_humour

func advance_round() -> void:
	var net_humour: int = precalculate_net_humour()
	if humour_bar.value + net_humour <= 0: sounds.boo()
	else: sounds.laugh(min(net_humour / 40.0, 1)) # TODO tweak formula
	
	# stage cards
	for slot in stage_slots:
		var data = get_slot_data(slot)
		if not data: continue
		
		slot.show_highlight(true)
		humour_bar.value += data["effect"]["comedy"]
		if data["effect"]["commonerFavour"]: commoner_attitude += data["effect"]["commonerFavour"]
		if data["effect"]["courtFavour"]: court_attitude += data["effect"]["courtFavour"]
		
		await get_tree().create_timer(pause_on_card).timeout # TODO rather await Daniel's +10 animation
		slot.show_highlight(false)
		free_slot(slot)
	
	# commoner cards
	for slot in commoner_slots:
		var data = get_slot_data(slot)
		if not data: continue
		
		slot.show_highlight(true)
		humour_bar.value += data["effect"]["comedy"]
		if data["effect"]["commonerFavour"]: commoner_attitude += data["effect"]["commonerFavour"]
		if data["effect"]["courtFavour"]: court_attitude += data["effect"]["courtFavour"]
		
		await get_tree().create_timer(pause_on_card).timeout
		slot.show_highlight(false)
		free_slot(slot)
	
		# court cards
	for slot in court_slots:
		var data = get_slot_data(slot)
		if not data: continue
		
		slot.show_highlight(true)
		humour_bar.value += data["effect"]["comedy"]
		if data["effect"]["commonerFavour"]: commoner_attitude += data["effect"]["commonerFavour"]
		if data["effect"]["courtFavour"]: court_attitude += data["effect"]["courtFavour"]
		
		await get_tree().create_timer(pause_on_card).timeout
		slot.show_highlight(false)
		free_slot(slot)
	
	# king card
	pass
	
	check_for_win_or_loss()

func check_for_win_or_loss() -> void:
	rounds_remaining -= 1
	if humour_bar.value >= 100: pass # TODO trigger WIN!
	elif rounds_remaining <= 0 or humour_bar.value <= 0: pass # TODO trigger LOSS!
	else: begin_next_round()

func begin_next_round() -> void:
	rounds_label.text = str(rounds_remaining)
	draw_card()
	populate_audience()

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
	if len(deck) <= 0: return # TODO indicate empty deck
	var card_id = deck.pop_back()
	
	var new_card: Card = card_scene.instantiate()
	hand.append(new_card)
	new_card.position = card_spawn.position
	new_card.card_id = card_id
	
	new_card.connect("card_released", self._on_card_released)
	new_card.connect("card_picked_up", self._on_card_picked_up)
	new_card.connect("card_played_to_slot", self._on_card_played_to_slot)
	new_card.connect("card_returned_to_hand", self._on_card_returned_to_hand)
	
	layout_hand()
	add_child(new_card)
	sounds.card_draw()

func populate_audience():
	var commoner_card_quality = get_audience_cards("commoner")
	var court_card_quality = get_audience_cards("court")
	
	for i in range(len(commoner_slots)):
		var slot = commoner_slots[i]
		var new_card: Card = card_scene.instantiate()
		
		new_card.card_id = "heckle"
		new_card.interactable = false
		
		await get_tree().create_timer(0.25).timeout
		add_child(new_card)
		new_card.play_to_slot(slot)
		
	for i in range(len(court_slots)):
		var slot = court_slots[i]
		var new_card: Card = card_scene.instantiate()
		
		new_card.card_id = "offense"
		new_card.interactable = false
		if new_card.card_id == "offense": sounds.gasp(randf())
		
		await get_tree().create_timer(0.25).timeout
		add_child(new_card)
		new_card.play_to_slot(slot)

func _on_card_played_to_slot(card: Card) -> void:
	sounds.card_play()
	if card.pos_in_hand >= 0:
		hand.remove_at(card.pos_in_hand)
		card.pos_in_hand = -1
		layout_hand()

func layout_hand() -> void:
	for i in range(len(hand)):
		var width_proportion: float = 1 - exp(-len(hand) / 6.0)
		hand_pos.progress_ratio = 0.5 - 0.5 * width_proportion + width_proportion * (i + 0.5) / len(hand)
		hand[i].pos_in_hand = i
		hand[i].z_index = i
		hand[i].desired_position = hand_pos.global_position
		hand[i].desired_rotation = hand_pos.rotation

func _on_card_draw_timer_timeout() -> void:
	draw_card()
	cards_to_draw -= 1
	if cards_to_draw > 0: card_draw_timer.start()
