class_name Card
extends Area2D

@onready var card_art: Sprite2D = $Art as Sprite2D
@onready var card_name: Label = $Name as Label
@onready var rules_text: Label = $RulesText as Label

signal card_dragged(this: Card)
signal card_released(this: Card)

var card_data_loc = "res://cards/"
var card_art_loc = "res://assets/"

var card_id = "test_card"
var card_data

var is_hovering = false
var is_selected = false

func _ready():
	load_card()

func _process(delta):
	if is_selected:
		position = get_global_mouse_position()

func load_card():
	var file_name = card_data_loc + card_id + ".json"
	var file = FileAccess.open(file_name, FileAccess.READ)
	var json_object = JSON.new()
	var parse_err = json_object.parse(file.get_as_text())
	
	card_data = json_object.get_data()
	
	card_art.texture = load(card_art_loc + card_id + ".png")
	card_name.text = card_data["name"]
	rules_text.text = card_data["rules_text"]

func _on_mouse_entered():
	is_hovering = true

func _on_mouse_exit():
	is_hovering = false

func _input(event):
	if Input.is_action_just_pressed("click"):
		if is_hovering:
			is_selected = true
	elif Input.is_action_just_released("click"):
		is_selected = false
