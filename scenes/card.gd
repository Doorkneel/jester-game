class_name Card
extends Area2D

signal card_released(this: Card)

var card_id: String

# Track card being dragged across multiple card instances
static var card_being_dragged: Card

# Current interaction
var is_hovering = false
var is_being_dragged = false

# Where to return if let go
var pos_in_hand: int = -1
var origin_slot: CardSlot = null

# Target position & rotation for animation
var target_position: Vector2
var target_rotation: float
const animation_speed: float = 0.6

func load_card_data(id) -> void:
	card_id = id
	# TODO load card data

func _ready() -> void:
	target_position = position
	target_rotation = rotation

func _process(_delta) -> void:
	if is_being_dragged:
		position = get_global_mouse_position()
	else:
		# move towards target position
		var pos_delta = target_position - position
		if pos_delta.length() < animation_speed: position = target_position
		else: position += pos_delta * animation_speed
		
		# move towards target rotation
		var rot_delta = target_rotation - rotation
		if abs(rot_delta) < animation_speed: rotation = target_rotation
		else: rotation += rot_delta * animation_speed

func _on_mouse_entered() -> void:
	is_hovering = true

func _on_mouse_exited() -> void:
	is_hovering = false

func _input(_event) -> void:
	if Input.is_action_just_pressed("click"):
		if is_hovering and not card_being_dragged:
			is_being_dragged = true
			card_being_dragged = self
			rotation = 0
	elif Input.is_action_just_released("click"):
		if is_being_dragged:
			is_being_dragged = false
			card_released.emit(self)
			card_being_dragged = null

func snap_to_slot(slot: CardSlot) -> void:
	target_position = slot.position
	target_rotation = slot.rotation
	origin_slot = slot
