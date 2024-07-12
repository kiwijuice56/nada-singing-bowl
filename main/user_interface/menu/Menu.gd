class_name Menu
extends Control
# Parent class for all menus, with basic API to reduce repitition.

# Contains slots for UI sounds that some menus use for extra feedback.

@export var audio1: Resource = preload("res://main/audio/sound_effects/menu1.ogg")
@export var audio2: Resource = preload("res://main/audio/sound_effects/menu2.ogg")
@export var transition_time: float = 0.09

signal exited
signal entered

func _ready() -> void:
	modulate.a = 0 

# Show this menu.
func enter() -> void:
	entered.emit()
	visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, transition_time)
	await tween.finished

# Hide this menu.
func exit() -> void:
	exited.emit()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, transition_time)
	await tween.finished
	visible = false

func play_sound(sound: Resource) -> void:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(player)
	player.stream = sound
	player.playing = true
