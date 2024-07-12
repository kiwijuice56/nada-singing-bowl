class_name BowlPreset
extends Resource

## The audio file to play as the sesstion is starting.
@export var transition_in: AudioStream

## The audio file to play as the sesstion is ending.
@export var transition_out: AudioStream

## The audio file to play as the sesstion is undergoing. Should
## loop and have ends that can blend reasonably well with transition_in
## and transition_out.
@export var sustain: AudioStream


## How many seconds before the end of the clip to start fading into
## the sustain loop.
@export_range(0, 60, 0.001, "suffix: seconds") var in_trim_length: float

## How many seconds before the end of the clip to start fading out
## entirely.
@export_range(0, 60, 0.001, "suffix: seconds") var end_trim_length: float

## The title of this bowl.
@export var display_name: String

## A short 1-2 sentence description on this bowl.
@export var description: String

## The color that the app changes to when this bowl is selected.
@export var color_1: Color

## Secondary color for a gradient.
@export var color_2: Color

## Color for bineural options only. Leave black if not bineural.
@export var color_3: Color

## Color for bineural options only. Leave black if not bineural.
@export var color_4: Color

@export_range(0, 1200, 1, "suffix: Hz")  var frequency: int

## See FractalNavigation.gd for what uniforms this shader should have.
@export var fractal: Shader

