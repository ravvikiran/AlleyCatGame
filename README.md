# Alley Cat - Modern Android Remake

A modern Android remake of the classic 1984 DOS game "Alley Cat" by Bill Williams, built with Godot 4.x.

## Requirements

- [Godot Engine 4.2+](https://godotengine.org/download)
- Android SDK (for mobile export)
- Android export templates installed in Godot

## Project Setup

1. Open Godot Engine
2. Click "Import" and navigate to this project folder
3. Select `project.godot` and click "Import & Edit"

## Running the Game

- Press F5 in the Godot Editor to run the project
- The game starts at the Title Screen
- Touch/click anywhere to start

## Running Tests

Run the integration test suite from the command line:

```bash
# Run core logic tests
godot --headless --script tests/test_runner.gd

# Run game flow tests
godot --headless --script tests/test_game_flow.gd
```

## Project Structure

```
alley_cat/
├── project.godot          # Godot project configuration
├── export_presets.cfg     # Android export settings
├── scenes/                # Scene files (.tscn)
│   ├── main.tscn
│   ├── title_screen.tscn
│   ├── alleyway_hub.tscn
│   ├── love_game.tscn
│   ├── game_over.tscn
│   └── minigames/        # 5 minigame room scenes
├── scripts/               # GDScript source files
│   ├── autoloads/         # Singleton managers
│   ├── player/            # Freddy + state machine
│   ├── entities/          # Enemy AI scripts
│   ├── rooms/             # Minigame logic
│   ├── alleyway/          # Hub scene logic
│   ├── ui/                # Touch controls + HUD
│   └── scenes/            # Scene-specific scripts
├── assets/                # Art, audio, fonts
│   ├── sprites/
│   ├── audio/
│   └── fonts/
└── tests/                 # Automated test scripts
```

## Game Controls (Touch)

| Control | Location | Action |
|---------|----------|--------|
| Virtual Joystick | Left side | Move horizontally, drop down |
| Jump Button | Right (lower) | Jump (standing or running) |
| Action Button | Right (upper) | Context action (teleport, drink, drop gift) |

## Difficulty Tiers

| Tier | Unlocked After |
|------|---------------|
| Kitten | Game start |
| House Cat | 1st Love Game |
| Tomcat | 2nd Love Game |
| Alley Cat | 3rd Love Game |

## Building for Android

1. Install Android export templates in Godot (Editor > Manage Export Templates)
2. Configure Android SDK path in Editor Settings
3. Project > Export > Android > Export Project
4. Sign the APK with your keystore for release builds

## Architecture

The game uses 5 autoload singletons:
- **GameManager** - State machine, lives, scene transitions
- **DifficultyManager** - 4-tier difficulty scaling
- **ScoreManager** - Points, bonuses, high score
- **SaveManager** - JSON persistence
- **AudioManager** - Music crossfading, SFX pool

Player movement uses a custom state machine (11 states) with hand-tuned physics for precise platforming feel.
