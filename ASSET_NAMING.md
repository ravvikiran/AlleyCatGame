# Asset Naming Convention — Midnight Prowl

Drop files into the correct folder with the correct name, and the game automatically uses them. No code changes required.

---

## Directory Structure

```
res://assets/
├── sprites/
│   ├── characters/     ← Player and NPC full sprite sheets
│   ├── entities/       ← Enemies, hazards, items (single images)
│   ├── environments/   ← Backgrounds, tiles, platforms
│   └── ui/             ← HUD elements, buttons, icons
├── audio/
│   ├── music/          ← Background music tracks (.ogg)
│   └── sfx/            ← Sound effects (.ogg or .wav)
├── vfx/                ← Particle effect scenes (.tscn)
└── tilesets/           ← TileSet resources (.tres)
```

---

## Character Sprites

**Folder:** `assets/sprites/characters/`

| Filename | Description |
|----------|-------------|
| `freddy.tres` | Full SpriteFrames resource with all animations |
| `freddy_idle.png` | Static idle frame (fallback if no .tres) |
| `freddy_walk.png` | Walking sprite/sheet |
| `freddy_jump.png` | Jumping sprite |
| `freddy_fall.png` | Falling sprite |
| `freddy_hang.png` | Hanging from ledge |
| `freddy_climb.png` | Climbing |
| `freddy_swim.png` | Swimming |
| `freddy_hurt.png` | Taking damage |
| `freddy_dead.png` | Death animation |
| `felicia_idle.png` | Felicia the female cat |

**Recommended sprite size:** 64x64 or 128x128 pixels per frame

---

## Entity Sprites

**Folder:** `assets/sprites/entities/`

| Filename | Description | Approx Size |
|----------|-------------|-------------|
| `dog.png` | Running dog hazard | 80x50 |
| `spider.png` | Ceiling spider | 50x50 |
| `mouse.png` | Cheese room mouse | 30x20 |
| `electric_eel.png` | Fishbowl eel | 60x20 |
| `bird.png` | Birdcage room bird | 40x30 |
| `magic_broom.png` | Magic broom entity | 30x80 |
| `enemy_cat.png` | Love game enemy cat | 50x60 |
| `cupid.png` | Love game cupid | 40x40 |
| `sleeping_dog.png` | Dogfood room dog | 70x40 |
| `arrow.png` | Cupid's arrow | 30x10 |
| `heart_solid.png` | Solid heart platform | 50x45 |
| `heart_broken.png` | Broken heart platform | 50x45 |
| `gift.png` | Love game gift item | 30x30 |
| `trash_can.png` | Alleyway trash can | 40x50 |
| `boot.png` | Thrown boot hazard | 25x25 |
| `telephone.png` | Thrown telephone | 25x25 |
| `rolling_pin.png` | Thrown rolling pin | 30x10 |
| `fish.png` | Fishbowl fish | 25x15 |
| `bowl.png` | Dog food bowl | 30x15 |
| `cage.png` | Birdcage | 50x60 |
| `plant.png` | Collectible plant | 25x30 |
| `cheese_block.png` | Swiss cheese wedge | 400x300 |

---

## Environment Art

**Folder:** `assets/sprites/environments/`

| Filename | Description |
|----------|-------------|
| `alleyway_bg.png` | Full alleyway background (1920x1080) |
| `building_facade.png` | Apartment building with windows |
| `fence.png` | Wooden fence (tileable) |
| `street.png` | Street/ground (tileable) |
| `clothesline.png` | Clothesline rope with laundry |
| `window_open.png` | Open window frame |
| `window_closed.png` | Closed window frame |
| `cheese_room_bg.png` | Cheese room background |
| `vase_room_bg.png` | Library/vase room background |
| `dogfood_room_bg.png` | Kennel room background |
| `fishbowl_room_bg.png` | Aquarium room background |
| `birdcage_room_bg.png` | Aviary room background |
| `love_game_bg.png` | Love game background |
| `night_sky.png` | Starry night sky (parallax) |

---

## UI Elements

**Folder:** `assets/sprites/ui/`

| Filename | Description |
|----------|-------------|
| `joystick_base.png` | Virtual joystick background (circular) |
| `joystick_knob.png` | Joystick thumb (smaller circle) |
| `button_jump.png` | Jump button |
| `button_action.png` | Action button |
| `life_icon.png` | Cat head icon for lives display |
| `splash_screen.png` | Boot splash image |
| `title_logo.png` | "Midnight Prowl" stylized title |

---

## Audio — Music

**Folder:** `assets/audio/music/`
**Format:** `.ogg` (OGG Vorbis, recommended for looping music)

| Filename | When It Plays |
|----------|---------------|
| `title_theme.ogg` | Title screen |
| `alleyway.ogg` | Alleyway hub gameplay |
| `minigame.ogg` | All 5 minigame rooms |
| `love_game.ogg` | Love game bonus stage |
| `game_over.ogg` | Game over screen |

---

## Audio — Sound Effects

**Folder:** `assets/audio/sfx/`
**Format:** `.ogg` or `.wav`

| Filename | Trigger |
|----------|---------|
| `jump.ogg` | Freddy jumps |
| `land.ogg` | Freddy lands on surface |
| `hurt.ogg` | Freddy takes damage |
| `catch_mouse.ogg` | Catching a mouse |
| `dog_bark.ogg` | Dog appears/barks |
| `broom_sweep.ogg` | Broom cleaning |
| `vase_break.ogg` | Birdcage breaks / vase breaks |
| `splash.ogg` | Entering water |
| `meow_death.ogg` | Freddy dies |
| `eel_zap.ogg` | Electric eel contact |
| `window_open.ogg` | Window opens |
| `score_tick.ogg` | Points awarded |
| `level_complete.ogg` | Room completed |
| `love_complete.ogg` | Love game won |

---

## VFX Scenes

**Folder:** `assets/vfx/`
**Format:** `.tscn` (Godot scene with GPUParticles2D)

| Filename | Effect |
|----------|--------|
| `dust_puff.tscn` | Landing dust |
| `sparkle.tscn` | Collectible grabbed |
| `heart_burst.tscn` | Love game completion |
| `electrocute.tscn` | Eel zap effect |
| `splash_vfx.tscn` | Water splash particles |

---

## How It Works

1. The game checks `assets/sprites/characters/freddy.tres` on startup
2. If found → uses real animated sprite
3. If NOT found → draws a procedural cyan cat shape using code
4. Same pattern for every visual element in the game

**You never need to edit code.** Just drop correctly-named files into the right folders.

---

## Tips for Creating Assets

- **Pixel art** at 2x or 4x resolution works best (e.g., 64x64 character at 4x = crisp on 1080p)
- **Use transparent backgrounds** (PNG with alpha)
- **Keep consistent style** — CGA-inspired palette: cyan, magenta, yellow, white on dark backgrounds
- **SpriteFrames .tres** files can be created in Godot's SpriteFrames editor (select AnimatedSprite2D → Inspector → SpriteFrames → New → add frames)
- **Audio:** Keep SFX under 2 seconds, music loops should have clean loop points
