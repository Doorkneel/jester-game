class_name Card
extends Area2D

signal card_picked_up(this: Card)
signal card_released(this: Card)
signal card_played_to_slot(this: Card)
signal card_returned_to_hand(this: Card)

@onready var card_art: Sprite2D = $Art as Sprite2D
@onready var card_frame: Sprite2D = $Frame as Sprite2D
@onready var card_name: Label = $Name as Label
@onready var rules_text: Label = $RulesText as Label

@export var card_list_json: JSON
var card_data

const card_art_loc: String = "res://assets/art/"
const card_frame_loc: String = "res://assets/frames/"

var card_id

var pos_in_hand: int = -1
var current_slot: CardSlot

# Track card being dragged across multiple card instances
static var card_being_dragged: Card
var highlighted_slot: CardSlot

# Current interaction
var interactable: bool = true
var being_hovered: bool = false
var being_dragged: bool = false
var should_return_to_hand: bool = false

# Target position & rotation for animation
var desired_position: Vector2
var desired_rotation: float = 0
const slide_speed: float = 0.6
const rotation_speed: float = 0.2
const snap_strength: float = 0.7

func load_card():
	card_data = card_list_json.get_data()[card_id]
	card_art.texture = load(card_art_loc + card_id + ".png")
	card_frame.texture = load(card_frame_loc + card_data["type"] + "_frame.png")
	card_name.text = card_data["name"]
	rules_text.text = card_data["rules_text"]

func _ready() -> void:
	if not desired_position: desired_position = position
	load_card()

func _process(_delta) -> void:
	var target_pos: Vector2 = desired_position
	var target_rot: float = desired_rotation

	if being_dragged:
		if highlighted_slot:
			target_pos = snap_strength * highlighted_slot.global_position + (1 - snap_strength) * get_global_mouse_position()
			target_rot = highlighted_slot.global_rotation
		else:
			target_pos = get_global_mouse_position()
			target_rot = 0
		
	# move towards target position
	var pos_delta = target_pos - position
	if pos_delta.length() < slide_speed: position = target_pos
	else: position += pos_delta * slide_speed
	
	# move towards target rotation
	var rot_delta = target_rot - rotation
	if abs(rot_delta) < rotation_speed: rotation = target_rot
	else: rotation += rot_delta * rotation_speed

func _on_mouse_entered() -> void:
	if interactable: being_hovered = true

func _on_mouse_exited() -> void:
	being_hovered = false

func _input(_event) -> void:
	if Input.is_action_just_pressed("click"):
		if being_hovered and not card_being_dragged and interactable:
			being_dragged = true
			z_index = 1000
			card_picked_up.emit(self)
			card_being_dragged = self
	elif Input.is_action_just_released("click"):
		if being_dragged:
			being_dragged = false
			z_index = 0 if pos_in_hand < 0 else pos_in_hand
			card_released.emit(self)
			card_being_dragged = null
			
			if highlighted_slot: play_to_slot(highlighted_slot)
			elif should_return_to_hand: play_to_slot(null)

func _on_slot_hovered(id: int, slot: CardSlot) -> void:
	# do not unhighlight unless currently-highlighted slot is requesting it;
	# this avoids a race condition where we enter another slot before the first
	# emits the signal to be unhighlighted
	if not slot and highlighted_slot and id != highlighted_slot.get_instance_id(): return
	
	# TODO do some logic to check whether card can be placed here
	highlighted_slot = slot

func _on_hand_hitbox_entered() -> void:
	if pos_in_hand < 0: should_return_to_hand = true

func _on_hand_hitbox_exited() -> void:
	should_return_to_hand = false

func play_to_slot(slot: CardSlot) -> void:
	# remove card from old slot
	if current_slot: current_slot.contents.pop_front()
	current_slot = slot
	
	if slot:
		# add card to new slot
		desired_position = slot.global_position
		desired_rotation = slot.global_rotation
		slot.contents.append(self)
		card_played_to_slot.emit(self)
		highlighted_slot = null
	else:
		# return card to hand
		card_returned_to_hand.emit(self)
		should_return_to_hand = false
