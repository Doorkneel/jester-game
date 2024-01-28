class_name Sounds
extends Node

@onready var laughs = [
	$Crickets,
	$Smallest,
	$Small,
	$Medium,
	$Large,
	$Huge
] as Array[AudioStreamPlayer2D]
@onready var gasps = [
	$GaspNeutral,
	$GaspSurprise,
	$GaspWorry,
	$GaspShock
] as Array[AudioStreamPlayer2D]
@onready var badumtss = $Badumtss as AudioStreamPlayer2D
@onready var play = $Play as AudioStreamPlayer2D
@onready var booing = $Boo as AudioStreamPlayer2D
@onready var card = $Card as AudioStreamPlayer2D
@onready var music = $Music as AudioStreamPlayer2D
@onready var party = $Party as AudioStreamPlayer2D
@onready var sad_horn = $SadHorn as AudioStreamPlayer2D

@export var play_music: bool
@export var play_party: bool
@export var play_sad_horn: bool

func _ready() -> void:
	if play_music: music.play()
	if play_party: party.play()
	if play_sad_horn:
		sad_horn.play()
		boo()

func laugh(magnitude: float) -> void:
	badumtss.play()
	laughs[round(magnitude * (len(laughs) - 1))].play()

func gasp(severity: float) -> void:
	gasps[round(severity * (len(gasps) - 1))].play()

func boo() -> void:
	booing.play()

func card_draw() -> void:
	card.pitch_scale = randf_range(0.7, 1.3)
	card.play()

func card_play() -> void:
	play.pitch_scale = randf_range(0.9, 1.1)
	play.play()
