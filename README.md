# Meditation App

## Overview
This repository contains the Godot 4.2.1 project and code for a meditation app
created by Eric Alfaro (ealfaro@mit.edu) in an undergraduate research opportunity
under Dr. Richard Fletcher. Please reach out to me via email if you have any
questions about the app!

## Editing the Project
### Running in Godot
1. Install [Godot 4.2.1](https://godotengine.org/download/archive/4.2.1-stable/).
2. Clone this repository or download the project folder.
3. Open Godot and import the Godot project in this repository.

### Building for Google Play Store
[not yet implemented]

## Documentation
### Terminology
Listed below are some common terms used throughout the app code and documentation.
- `Session`: The 2-10 minute state where the user listens to the singing bowl 
sounds and watches the fractal visuals evolve. A user starts a session
by moving their finger in a circle around the singing bowl while they are in 
the title screen. When a session ends, the app switches back to the
title screen.
- `Resonance`: A measure of how effectively the user is moving their finger around
the circle input widget. Gradually increases towards `1.0` as the user moves
their finger at the correct pace (not too fast or too slow) and decreases
towards `0.0` if the user stops moving their finger. 

### Project Structure
`main/Main.tscn` is the main scene of the app. `main/Main.gd` controls the
main app loop, such as the UI and session state. `main/SessionHandler.gd` controls
the finer details of each session, such as the visuals and sounds as
a session progresses.

The singing bowl sound is controlled by `main/audio/SingingBowl.gd`.
Each sound setting is configured using a `BowlPreset` resource, which requires
three audio files (one for transitioning in, one for sustaining, and one for transitioning
out). To create a new preset, make a new `BowlPreset` resource and initialize its
sound and offset values. Then, add it to the `SingingBowl`'s `preset_mappings` 
array in `main/Main.tscn`. The widget in the user interface should update
automatically.

Visuals are controlled by `main/visuals/session_visual/FractalNavigation.gd` and the GLSL shader file in the same folder. The shader uses chaotic transformations to make a
unique animated image, which is controlled by parameters that are dynamically updated throughout a session.

The user interface is composed of many different scripts, one for each menu.
To make the code more flexible and less repetitive, every submenu extends `main/user_interface/menu/Menu.gd`,
which has some basic functionality (such as fading in and out, or menu sounds) that
can be built upon for more complex menus.

## Attribution
- https://luos.gumroad.com/l/bouSt (free noise images)
