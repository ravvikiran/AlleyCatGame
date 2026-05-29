# Midnight Prowl

**A stray cat's quest for love under the city lights.**

A retro-modern 2D platformer for Android where you play as Freddy, a scrappy alley cat navigating rooftops, dodging hazards, and completing challenges to win the heart of Felicia. Inspired by classic 80s arcade platformers, reimagined with modern touch controls and vibrant pixel art.

## Features

- **Alleyway Hub** — Navigate a multi-level urban environment with trash cans, fences, clotheslines, and apartment windows
- **5 Unique Minigames** — Cheese maze, spider evasion, stealth dogfood heist, underwater fishbowl, and birdcage escape
- **Love Game Bonus Stage** — Platform across heart-shaped tiles to reach your sweetheart
- **Progressive Difficulty** — Four tiers: Kitten → House Cat → Tomcat → Alley Cat
- **Local Leaderboard** — Track scores with player names/emails, share via social media
- **Touch Optimized** — Virtual joystick + dedicated jump/action buttons
- **Retro-Modern Aesthetic** — CGA-inspired palette with smooth 60fps animations

## Requirements

- [Godot Engine 4.2+](https://godotengine.org/download)
- Android SDK (for mobile export)
- Android export templates installed in Godot

## Quick Start

1. Open Godot Engine
2. Import this project (select `project.godot`)
3. Press F5 to run

## Running Tests

```bash
godot --headless --script tests/test_runner.gd
godot --headless --script tests/test_game_flow.gd
```

## Project Structure

```
midnight_prowl/
├── project.godot          # Engine configuration
├── export_presets.cfg     # Android export settings
├── icon.svg               # App icon (cat on rooftop + moon)
├── scenes/                # Godot scene files
│   ├── main.tscn          # Entry point / loading
│   ├── title_screen.tscn  # Title with leaderboard access
│   ├── player_registration.tscn  # Name/email setup
│   ├── leaderboard_screen.tscn   # Score rankings
│   ├── alleyway_hub.tscn  # Main hub level
│   ├── love_game.tscn     # Bonus stage
│   ├── game_over.tscn     # End screen with share
│   ├── minigames/         # 5 challenge rooms
│   └── ui/                # Pause menu
├── scripts/
│   ├── autoloads/         # Singleton managers
│   │   ├── game_manager.gd
│   │   ├── difficulty_manager.gd
│   │   ├── score_manager.gd
│   │   ├── save_manager.gd
│   │   ├── audio_manager.gd
│   │   ├── leaderboard_manager.gd
│   │   └── placeholder_assets.gd
│   ├── player/            # Freddy controller + states
│   ├── entities/          # Enemy AI (9 types)
│   ├── rooms/             # Minigame logic
│   ├── alleyway/          # Hub mechanics
│   ├── ui/                # Touch controls + HUD
│   └── scenes/            # Screen scripts
├── assets/                # Art, audio, fonts
└── tests/                 # Automated test suite
```

## Controls

| Input | Location | Action |
|-------|----------|--------|
| Virtual Joystick | Left side | Move, drop down |
| Jump Button | Right (lower) | Jump (standing/running) |
| Action Button | Right (upper) | Context action |

## Scoring & Leaderboard

- Scores saved locally with player name + email as unique ID
- Share scores via Android share intent (email, social media, messaging)
- Export full leaderboard as text file
- No internet or backend server required

## Building for Android

1. Install Android export templates (Editor > Manage Export Templates)
2. Configure Android SDK path in Editor Settings
3. Project > Export > Android > Export Project
4. Target: API 24+ (Android 7.0), ARM64 + ARMv7

## Difficulty Tiers

| Tier | Effect |
|------|--------|
| Kitten | Slow hazards, generous timing |
| House Cat | Moderate speed increase |
| Tomcat | Fast hazards, more enemies |
| Alley Cat | Maximum challenge |

## License

This is an original game. All code, assets, and design are new creations.
