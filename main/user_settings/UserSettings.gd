class_name UserSettings
extends Resource
# Stores the settings selected by a user.

@export var version: String
@export var volume: float = 0.0
@export var session_duration: float
@export var bowl_type: int
@export var phys_readings: bool = true
@export var first_opened_app: bool = true
