# 🐱 Midnight Prowl

**A stray cat's quest for love under the city lights.**

A retro-modern 2D platformer for Android where you play as Freddy, a scrappy stray cat navigating rooftops, dodging hazards, and completing challenges to win the heart of Felicia. Inspired by classic 80s arcade platformers, reimagined with modern touch controls and vibrant visuals.

## Features

- 🏙️ **Alleyway Hub** — Navigate a multi-level urban environment with trash cans, fences, clotheslines, and apartment windows
- 🎮 **5 Unique Minigames** — Cheese maze, spider evasion, stealth dogfood heist, underwater fishbowl, and birdcage escape
- 💕 **Love Game Bonus Stage** — Platform across heart-shaped tiles to reach your sweetheart
- 📈 **Progressive Difficulty** — Four tiers: Kitten → House Cat → Tomcat → Alley Cat
- 🏆 **Local Leaderboard** — Track scores with player names/emails, share via social media
- 📱 **Touch Optimized** — Virtual joystick + dedicated jump/action buttons
- 📖 **Interactive Tutorial** — 11-step guided introduction for new players
- 🎨 **Plug-and-Play Assets** — Drop PNG/OGG files into folders, game auto-loads them
- 🔇 **No Ads, No IAP, No Internet Required** — Pure offline gaming

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Engine | Godot 4.6 (GDScript) |
| Target | Android (API 24+, ARM64) |
| Rendering | Godot 2D Mobile Renderer |
| Persistence | Local JSON files |
| Audio | OGG Vorbis / WAV |

## Getting Started

### Prerequisites

- [Godot Engine 4.6+](https://godotengine.org/download) (Standard, not .NET)
- Android SDK (via Android Studio) — only for Android export
- JDK 17+ — only for Android export

### Run on Desktop

```bash
# Open Godot → Import → select project.godot → Press F5
```

### Run on Android Device

1. Set Android SDK path in Godot: Editor → Editor Settings → Export → Android
2. Install export templates: Editor → Manage Export Templates → Download
3. Connect phone via USB with USB Debugging enabled
4. Click the 📱 icon in Godot toolbar

### Export APK

```
Godot → Project → Export → Android → Export Project
```

## Project Structure

```
MidnightProwl/
├── project.godot              # Godot project config
├── export_presets.cfg         # Android export settings
├── icon.svg                   # App icon
├── ASSET_NAMING.md            # Asset naming conventions
├── README.md                  # This file
│
├── scenes/                    # Godot scenes (.tscn)
│   ├── main.tscn              # Loading screen (entry point)
│   ├── title_screen.tscn      # Title with leaderboard/tutorial buttons
│   ├── tutorial.tscn          # Interactive 11-step tutorial
│   ├── player_registration.tscn  # Name/email setup
│   ├── leaderboard_screen.tscn   # Score rankings + share
│   ├── alleyway_hub.tscn      # Main gameplay hub
│   ├── love_game.tscn         # Bonus stage
│   ├── game_over.tscn         # End screen with share/restart
│   ├── minigames/             # 5 challenge rooms
│   │   ├── cheese_room.tscn
│   │   ├── vase_room.tscn
│   │   ├── dogfood_room.tscn
│   │   ├── fishbowl_room.tscn
│   │   └── birdcage_room.tscn
│   └── ui/
│       └── pause_menu.tscn    # Pause overlay (autoload)
│
├── scripts/
│   ├── autoloads/             # Singleton managers (always active)
│   │   ├── game_manager.gd        # State machine, lives, transitions
│   │   ├── difficulty_manager.gd   # 4-tier scaling system
│   │   ├── score_manager.gd       # Points, bonuses, high score
│   │   ├── save_manager.gd        # JSON persistence
│   │   ├── audio_manager.gd       # Music crossfade + SFX pool
│   │   ├── leaderboard_manager.gd # Local leaderboard + sharing
│   │   ├── asset_loader.gd        # Plug-and-play resource loading
│   │   ├── visual_factory.gd      # Creates sprites or procedural fallbacks
│   │   └── placeholder_assets.gd  # Runtime texture generation
│   ├── player/
│   │   ├── freddy.gd             # Player controller (11 states)
│   │   ├── state_machine.gd      # Structural placeholder node
│   │   └── state.gd              # Legacy base class
│   ├── entities/                  # Enemy AI scripts (9 types)
│   │   ├── bird.gd, cupid.gd, electric_eel.gd
│   │   ├── enemy_cat.gd, magic_broom.gd, mouse.gd
│   │   ├── running_dog.gd, sleeping_dog.gd, spider.gd
│   ├── rooms/                     # Minigame logic
│   │   ├── minigame_room_base.gd  # Abstract base class
│   │   ├── cheese_room.gd, vase_room.gd
│   │   ├── dogfood_room.gd, fishbowl_room.gd
│   │   ├── birdcage_room.gd, love_game.gd
│   ├── visuals/                   # Procedural drawing scripts
│   │   ├── procedural_cat.gd, procedural_dog.gd
│   │   ├── procedural_spider.gd, procedural_mouse.gd
│   │   ├── procedural_bird.gd, procedural_broom.gd
│   ├── alleyway/                  # Hub scene logic
│   │   ├── alleyway_hub.gd, window_manager.gd
│   │   └── hazard_spawner.gd
│   ├── ui/                        # Input and display
│   │   ├── touch_controller.gd, hud.gd
│   │   ├── pause_menu.gd, action_button.gd
│   │   └── virtual_joystick.gd
│   └── scenes/                    # Screen-specific scripts
│       ├── main.gd, title_screen.gd, game_over.gd
│       ├── tutorial.gd, player_registration.gd
│       └── leaderboard_screen.gd
│
├── assets/                        # Drop real assets here
│   ├── sprites/
│   │   ├── characters/            # Player sprite sheets
│   │   ├── entities/              # Enemy/item sprites
│   │   ├── environments/          # Backgrounds, tiles
│   │   └── ui/                    # Buttons, icons
│   ├── audio/
│   │   ├── music/                 # .ogg music tracks
│   │   └── sfx/                   # .ogg/.wav sound effects
│   ├── vfx/                       # Particle scenes (.tscn)
│   ├── tilesets/                  # TileSet resources
│   └── fonts/                     # Custom fonts
│
├── android/
│   └── icons/                     # Adaptive launcher icons
│
├── tests/                         # Automated test suite
│   ├── test_runner.gd             # Core logic tests (35+)
│   └── test_game_flow.gd         # End-to-end flow tests
│
└── docs/                          # Documentation
    ├── GODOT_BEGINNER_GUIDE.md    # How to use Godot
    ├── HOW_TO_RUN.md              # Running/exporting guide
    ├── GOOGLE_PLAY_PUBLISHING_GUIDE.md  # Play Store checklist
    └── FREE_ASSET_SOURCES.md      # Where to get free art/audio
```

## Controls

| Input | Area | Action |
|-------|------|--------|
| Drag | Left 1/3 of screen | Move (virtual joystick) |
| Tap | Bottom-right | Jump |
| Tap | Upper-right | Action (context-dependent) |
| Escape | — | Pause menu |

## Game Flow

```
Loading → Title Screen → [Registration] → [Tutorial] → Alleyway Hub
                                                            │
                              ┌──────────────────────────────┤
                              │                              │
                         Enter Window                   Enter Felicia's Window
                              │                              │
                              ▼                              ▼
                        Minigame Room                    Love Game
                         (1 of 5)                      Bonus Stage
                              │                              │
                              ▼                              ▼
                     Complete → Back to Hub      Complete → Difficulty Up + Extra Life
```

## Adding Real Art Assets

The game uses a plug-and-play system. Drop files into the correct folder and they're used automatically:

```
assets/sprites/characters/freddy_idle.png  →  Freddy uses this instead of cyan shape
assets/audio/sfx/jump.ogg                  →  Jump plays this sound
assets/audio/music/title_theme.ogg         →  Title screen plays this music
```

See `ASSET_NAMING.md` for the full naming convention.

## Running Tests

```bash
godot --headless --script tests/test_runner.gd
godot --headless --script tests/test_game_flow.gd
```

Tests cover: state machine transitions, difficulty scaling, score calculations, physics parameters, cheese hole connectivity, air supply countdown, awake meter proximity, heart toggle involution, and full game loop flow.

## Documentation

| File | Contents |
|------|----------|
| `ASSET_NAMING.md` | Exact filenames the game expects for every asset |
| `docs/HOW_TO_RUN.md` | Step-by-step running/exporting guide |
| `docs/GODOT_BEGINNER_GUIDE.md` | Godot editor tutorial for beginners |
| `docs/GOOGLE_PLAY_PUBLISHING_GUIDE.md` | Complete Play Store submission checklist |
| `docs/FREE_ASSET_SOURCES.md` | Where to find free sprites, audio, music |

## License

MIT License. This is an original game — all code is new, no third-party code included. Art assets you add may have their own licenses (see `docs/FREE_ASSET_SOURCES.md` for guidance).

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Acknowledgments

- Inspired by the spirit of classic 80s arcade platformers
- Built with [Godot Engine](https://godotengine.org) (MIT License)
- Retro aesthetic inspired by CGA/PCjr color palettes
