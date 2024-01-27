class_name Card
extends Area2D

signal card_picked_up(this: Card)
signal card_released(this: Card)

@onready var sprite: Sprite2D = $Art as Sprite2D
@onready var name_label: Label = $Name as Label

var card_data_loc = "res://cards/"
var card_art_loc = "res://assets/"

var card_id = "test_card"
var card_data

# Track card being dragged across multiple card instances
static var card_being_dragged: Card
var highlighted_slot: CardSlot

# Current interaction
var being_hovered = false
var being_dragged = false

# Where to return if let go
var pos_in_hand: int = -1
var origin_slot: CardSlot = null

# Target position & rotation for animation
var target_position: Vector2
const slide_speed: float = 0.6
const snap_strength: float = 0.7

func load_card():
	var file_name = card_data_loc + card_id + ".json"
	var file = FileAccess.open(file_name, FileAccess.READ)
	var json_object = JSON.new()
	var parse_err = json_object.parse(file.get_as_text())
	
	card_data = json_object.get_data()
	
	sprite.texture = load(card_art_loc + card_id + ".png")
	name_label.text = card_data["name"]

func _ready() -> void:
	target_position = position
	load_card()

func _process(_delta) -> void:
	if being_dragged:
		if highlighted_slot:
			target_position = snap_strength * highlighted_slot.global_position + (1 - snap_strength) * get_global_mouse_position()
			rotation = highlighted_slot.global_rotation
		else:
			target_position = get_global_mouse_position()
			rotation = 0
		
	# move towards target position
	var pos_delta = target_position - position
	if pos_delta.length() < slide_speed: position = target_position
	else: position += pos_delta * slide_speed

func _on_mouse_entered() -> void:
	being_hovered = true

func _on_mouse_exited() -> void:
	being_hovered = false

func _input(_event) -> void:
	if Input.is_action_just_pressed("click"):
		if being_hovered and not card_being_dragged:
			being_dragged = true
			card_picked_up.emit(self)
			card_being_dragged = self
	elif Input.is_action_just_released("click"):
		if being_dragged:
			being_dragged = false
			card_released.emit(self)
			card_being_dragged = null
			
			if highlighted_slot:
				play_to_slot(highlighted_slot)
			else:
				# TODO add logic to return to hand using 'pos_in_hand'
				pass

func _on_slot_hovered(slot: CardSlot) -> void:
	# TODO do some logic to check whether card can be placed here
	highlighted_slot = slot

func play_to_slot(slot: CardSlot) -> void:
	target_position = slot.global_position
	rotation = slot.global_rotation
	slot.contents.append(self)
	origin_slot = slot
