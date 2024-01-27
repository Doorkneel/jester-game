class_name Sounds
extends Node

@onready var laughs = [
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

func laugh(magnitude: float) -> void:
	badumtss.play()
	laughs[int(magnitude * len(laughs))].play()

func gasp(severity: float) -> void:
	gasps[int(severity * len(gasps))].play()

func boo() -> void:
	booing.play()

func card_draw() -> void:
	card.pitch_scale = randf_range(0.7, 1.3)
	card.play()

func card_play() -> void:
	play.pitch_scale = randf_range(0.9, 1.1)
	play.play()
