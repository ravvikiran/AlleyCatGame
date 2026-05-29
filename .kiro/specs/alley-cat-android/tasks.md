# Implementation Tasks

## Task 1: Project Setup and Godot Configuration

- [x] Create Godot 4 project with project.godot configured for Android export
- [x] Set display resolution to 1920x1080 with stretch mode `canvas_items` and aspect `keep_height`
- [x] Enforce landscape orientation in project settings
- [x] Create folder structure: scenes/, scripts/, assets/, scripts/autoloads/, scripts/player/, scripts/entities/, scripts/ui/, scripts/rooms/, scripts/alleyway/
- [x] Configure Android export preset targeting API level 24 minimum
- [x] Set target framerate to 60fps in project settings

**Requirements:** Req 14 (Visual Presentation), Req 16 (Android Platform Compatibility)

## Task 2: GameManager Autoload

- [x] Create `scripts/autoloads/game_manager.gd` with GameState enum (TITLE_SCREEN, ALLEYWAY_HUB, MINIGAME_CHEESE, MINIGAME_VASE, MINIGAME_DOGFOOD, MINIGAME_FISHBOWL, MINIGAME_BIRDCAGE, LOVE_GAME, GAME_OVER)
- [x] Implement `change_state(new_state)` method that handles scene transitions using `get_tree().change_scene_to_packed()`
- [x] Implement lives management: `lives` variable (default 9), `lose_life()`, `gain_life()`
- [x] Implement `minigame_completed` flag and `felicia_window_active` flag
- [x] Register as autoload in project.godot
- [x] Implement `reset_game()` to initialize all state for a new game

**Requirements:** Req 1 (Game State Machine)

## Task 3: DifficultyManager Autoload

- [x] Create `scripts/autoloads/difficulty_manager.gd` with DifficultyTier enum (KITTEN, HOUSE_CAT, TOMCAT, ALLEY_CAT)
- [x] Define difficulty parameter dictionary with values per tier: trash_cans (6,5,4,3), dog_speed (1.0,1.3,1.6,2.0), dog_freq (1.0,1.2,1.5,1.8), eel_per_fish (1,1,2,2), spider_speed (1.0,1.3,1.6,2.0), cat_accuracy (0.5,0.65,0.8,0.95)
- [x] Implement `advance_tier()` that increments tier capping at ALLEY_CAT
- [x] Implement `get_param(key: String) → float` to retrieve current tier's parameter
- [x] Register as autoload in project.godot

**Requirements:** Req 11 (Difficulty Progression System)

## Task 4: ScoreManager Autoload

- [x] Create `scripts/autoloads/score_manager.gd` with current_score, high_score, love_game_multiplier
- [x] Define point values: MOUSE_CATCH=100, MINIGAME_BASE=500, TIME_BONUS_PER_SECOND=10, LOVE_GAME_BASE=1000, ALLEY_MOUSE_CATCH=50
- [x] Implement `award_points(type, bonus)` method
- [x] Implement `apply_multiplier()` for Love Game bonus
- [x] Implement `check_high_score()` that updates high_score if current_score exceeds it
- [x] Emit signal `score_changed` for UI updates
- [x] Register as autoload in project.godot

**Requirements:** Req 12 (Scoring System)

## Task 5: SaveManager Autoload

- [x] Create `scripts/autoloads/save_manager.gd` with save_path = "user://alleycat_save.json"
- [x] Implement `save()` method writing JSON with high_score, highest_difficulty, total_games_played, settings
- [x] Implement `load()` method reading JSON with fallback to default values on error/corruption
- [x] Implement `reset()` method to clear save data
- [x] Handle Android lifecycle: connect to `notification` for NOTIFICATION_WM_GO_BACK_REQUEST and NOTIFICATION_WM_CLOSE_REQUEST to auto-save
- [x] Register as autoload in project.godot

**Requirements:** Req 13 (Save and Persistence System), Req 16 (Android Platform Compatibility)

## Task 6: AudioManager Autoload

- [x] Create `scripts/autoloads/audio_manager.gd` with Music and SFX audio buses
- [x] Implement MusicPlayer with crossfade support (1.0s transition between tracks)
- [x] Implement SFX pool (8 AudioStreamPlayer nodes) with `play_sfx(clip)` method
- [x] Create placeholder audio files in assets/audio/sfx/ for: jump, land, hurt, catch_mouse, dog_bark, broom_sweep, vase_break, splash, meow_death, eel_zap
- [x] Create placeholder music tracks in assets/audio/music/ for each game state
- [x] Implement `play_track(state)` that maps GameState to music track
- [x] Register as autoload in project.godot

**Requirements:** Req 15 (Audio System)

## Task 7: Touch Controller UI

- [x] Create `scenes/ui/touch_controller.tscn` as CanvasLayer
- [x] Implement `scripts/ui/virtual_joystick.gd` with dead_zone (20px), max_radius (80px), outputting Vector2 direction
- [x] Implement drop detection when joystick y > 0.7
- [x] Create `scripts/ui/action_button.gd` for Jump button (60px radius) emitting jump_pressed/jump_released signals
- [x] Create Action button (50px radius) with visibility toggle, emitting action_pressed and action_held signals
- [x] Implement `scripts/ui/touch_controller.gd` aggregating all input signals
- [x] Ensure input registration within 16ms (use _input() not _process())
- [x] Scale touch controls based on screen DPI using anchor margins

**Requirements:** Req 2 (Touch Controls)

## Task 8: Player State Machine Framework

- [x] Create `scripts/player/state_machine.gd` as generic state machine with current_state, transition_to(state), and _physics_process delegation
- [x] Create base State class with enter(), exit(), update(), physics_update() virtual methods
- [x] Create `scripts/player/freddy.gd` as CharacterBody2D with physics constants (GRAVITY=980, WALK_SPEED=200, RUN_SPEED=350, STANDING_JUMP_VELOCITY=-450, RUNNING_JUMP_VELOCITY=-520, RUNNING_JUMP_H_BOOST=1.4, CLIMB_SPEED=150, MAX_FALL_SPEED=600)
- [x] Create `scenes/player/freddy.tscn` with AnimatedSprite2D, CollisionShape2D, and StateMachine child nodes
- [x] Connect TouchController signals to Freddy's input handling

**Requirements:** Req 2 (Touch Controls), Req 14 (Visual Presentation)

## Task 9: Player States Implementation

- [x] Implement `idle_state.gd`: tail twitch animation, transition to Walk on input, transition to Jump on jump_pressed
- [x] Implement `walk_state.gd`: WALK_SPEED movement, transition to Run after 0.3s sustained input, transition to Jump on jump_pressed
- [x] Implement `run_state.gd`: RUN_SPEED movement, transition to Jump with RUNNING_JUMP_VELOCITY and H_BOOST
- [x] Implement `jump_state.gd`: apply jump velocity (standing vs running), apply gravity, transition to Fall when velocity.y > 0
- [x] Implement `fall_state.gd`: apply gravity capped at MAX_FALL_SPEED, transition to Idle/Walk on floor, transition to Hang near hangable surface
- [x] Implement `hang_state.gd`: cling to surface, transition to Climb on up input, transition to Fall on down input
- [x] Implement `climb_state.gd`: CLIMB_SPEED vertical movement, transition to Idle at top
- [x] Implement `swim_state.gd`: 8-directional movement with inertia (drag=0.92), max_speed=250, acceleration=400
- [x] Implement `action_state.gd`: context-dependent action (teleport/drink/drop gift), transition back to Idle on complete
- [x] Implement `hurt_state.gd`: knockback animation, brief invulnerability, transition to Dead or respawn
- [x] Implement `dead_state.gd`: death animation, signal GameManager.lose_life()

**Requirements:** Req 2 (Touch Controls), Req 14 (Visual Presentation)

## Task 10: Alleyway Hub Scene

- [x] Create `scenes/alleyway_hub.tscn` with layered Node2D structure
- [x] Build street level (y:500-600) with TrashCan StaticBody2D nodes (count from DifficultyManager)
- [x] Build fence level (y:350-500) with graffiti sprite overlay for score/lives display
- [x] Build clothesline level (y:200-350) with hangable platform collision shapes
- [x] Build window level (y:0-200) with 12 Window Area2D nodes (3 rows x 4 columns)
- [x] Create `scripts/alleyway/alleyway_hub.gd` managing scene initialization and Freddy spawn point
- [x] Add ParallaxBackground for depth effect

**Requirements:** Req 3 (Alleyway Hub Navigation)

## Task 11: Window Manager

- [x] Create `scripts/alleyway/window_manager.gd` managing window open/close cycles
- [x] Implement random window opening with interval 2-5s, duration 3-8s per window
- [x] Implement `ensure_one_open()` guaranteeing at least one window is always open
- [x] Implement window entry detection: Area2D overlap + Freddy falling (velocity.y > 0)
- [x] Implement closed window bounce (apply upward impulse on collision)
- [x] Implement Felicia window activation after minigame completion (distinct visual indicator)
- [x] Implement object throwing: spawn Boot/Telephone/RollingPin with gravity (600 px/s²) when window opens

**Requirements:** Req 3 (Alleyway Hub Navigation), Req 4 (Alleyway Hub Hazards)

## Task 12: Alleyway Hazards

- [x] Create `scripts/alleyway/hazard_spawner.gd` managing dog and enemy cat spawning
- [x] Implement DogHazard: horizontal movement across street level, speed scaled by difficulty, spawn interval scaled by difficulty
- [x] Implement dog collision → instant death (signal GameManager.lose_life())
- [x] Implement enemy cats popping from trash cans: random timer, knock Freddy off can on contact
- [x] Implement clothesline mice: random spawn, horizontal movement, cause Freddy to lose grip on paw contact
- [x] Implement thrown object collision detection → instant death
- [x] Connect all hazard deaths to AudioManager for appropriate SFX

**Requirements:** Req 4 (Alleyway Hub Hazards)

## Task 13: Minigame Room Base Class

- [x] Create `scripts/rooms/minigame_room_base.gd` as abstract base with objective_count, objectives_completed, time_limit, elapsed_time
- [x] Implement `on_objective_completed()` checking if objectives_completed >= objective_count
- [x] Implement `on_room_complete()` calculating time bonus and calling ScoreManager.award_points()
- [x] Implement `on_player_death()` calling GameManager.lose_life() and handling respawn vs game over
- [x] Implement Magic Broom entity with AI states (CHASE_FREDDY, CLEAN_PRINTS, IDLE), speed=180, push_force=Vector2(400,-200)
- [x] Implement paw print system: Freddy leaves prints on floor, Broom prioritizes cleaning prints over chasing
- [x] Implement Running Dog entity: speed=250, patrols floor, kills on contact

**Requirements:** Req 5-9 (All Minigame Rooms)

## Task 14: Cheese Room Implementation

- [x] Create `scenes/minigames/cheese_room.tscn` with cheese block, 16 hole positions, table, chair
- [x] Create `scripts/rooms/cheese_room.gd` extending MinigameRoomBase
- [x] Implement 4x4 hole connection map (each hole connects to adjacent holes)
- [x] Implement teleport logic: Action button → move Freddy to random connected hole
- [x] Implement Mouse AI: move between holes randomly (1.5s interval), accelerate (2x) when Freddy is within 2 holes
- [x] Implement mouse catch detection: Freddy and mouse at same hole → catch
- [x] Spawn 4 mice, track catches, complete room when all 4 caught
- [x] Enable Magic Broom and Running Dog hazards

**Requirements:** Req 5 (Cheese Room Minigame)

## Task 15: Vase Room Implementation

- [x] Create `scenes/minigames/vase_room.tscn` with bookcase, shelves, 3 plants, chairs, lamps
- [x] Create `scripts/rooms/vase_room.gd` extending MinigameRoomBase
- [x] Implement bookcase with hangable shelf collision boxes
- [x] Implement Spider AI: TRACKING state (move toward freddy.x at horizontal_speed), DROPPING state (when abs(x-freddy.x)<10, drop at drop_speed), ASCENDING state (when abs(x-freddy.x)>60, return to ceiling)
- [x] Scale spider speeds by DifficultyManager.get_param("spider_speed")
- [x] Implement plant collection: Area2D overlap → collect, increment counter
- [x] Complete room when 3 plants collected
- [x] Spider contact → instant death

**Requirements:** Req 6 (Vase Room Minigame)

## Task 16: Dogfood Room Implementation

- [x] Create `scenes/minigames/dogfood_room.tscn` with 4 rows, sleeping dogs, dog bowls
- [x] Create `scripts/rooms/dogfood_room.gd` extending MinigameRoomBase
- [x] Implement row-based navigation: jump = +2 rows, drop = -1 row
- [x] Implement SleepingDog with awake_meter (0-1), proximity_radius=80px, fill_rate scaling by distance, drain_rate=0.2/s
- [x] Implement dog state transitions: SLEEPING → WAKING (meter > 0.8, visual warning) → ATTACKING (meter = 1.0)
- [x] Implement DogBowl with drink mechanic: hold Action for 1.5s → mark consumed
- [x] Complete room when all bowls consumed
- [x] Awake dog contact → instant death

**Requirements:** Req 7 (Dogfood Room Minigame)

## Task 17: Fishbowl Room Implementation

- [x] Create `scenes/minigames/fishbowl_room.tscn` with table, fishbowl, underwater area
- [x] Create `scripts/rooms/fishbowl_room.gd` extending MinigameRoomBase
- [x] Implement two-phase room: ROOM_PHASE (jump into bowl) → UNDERWATER_PHASE
- [x] Implement swim physics: 8-directional, acceleration=400, drag=0.92, max_speed=250
- [x] Implement AirSupply: max=30s, drain=1/s, surface touch resets, depleted → death
- [x] Implement Fish entities: random swim patterns, speed 80-150 px/s
- [x] Implement fish eating: contact → consume, spawn eel, increment counter
- [x] Implement ElectricEel: speed=120+(difficulty*20), bounce off walls, kills on contact
- [x] Spawn eel count based on DifficultyManager.get_param("eel_per_fish")
- [x] Complete room when 12 fish eaten
- [x] Display air meter in HUD during underwater phase

**Requirements:** Req 8 (Fishbowl Room Minigame)

## Task 18: Birdcage Room Implementation

- [x] Create `scenes/minigames/birdcage_room.tscn` with table, birdcage, room environment
- [x] Create `scripts/rooms/birdcage_room.gd` extending MinigameRoomBase
- [x] Implement two-phase room: PUSH_PHASE → CHASE_PHASE
- [x] Implement birdcage physics: push_force=150px per impact, track x-position vs table edge
- [x] Implement cage fall detection: x past table_edge → free bird, break cage animation
- [x] Implement Bird flight AI: sine-wave pattern (amplitude=60, frequency=2.0Hz), horizontal_speed=200, random direction changes every 1.5-3.0s
- [x] Implement bird catch: contact with Freddy → complete room
- [x] Enable Magic Broom and Running Dog hazards

**Requirements:** Req 9 (Birdcage Room Minigame)

## Task 19: Love Game Implementation

- [x] Create `scenes/love_game.tscn` with 7 rows of 8 heart platforms, Felicia at top, Cupid positions
- [x] Create `scripts/rooms/love_game.gd`
- [x] Implement HeartPlatform: SOLID/BROKEN states, toggle() method, disable collision when BROKEN
- [x] Implement EnemyCat AI: patrol row, track freddy.x with accuracy from DifficultyManager, speed=150, contact → knock down one row
- [x] Implement Cupid: positioned at screen edges, shoot diagonal arrows every 3s, arrow_speed=300
- [x] Implement arrow-heart collision: toggle heart state on hit
- [x] Implement arrow-Freddy collision: knock down one row
- [x] Implement GiftItem: Freddy starts with gift, Action button drops it, enemy contact → both disappear 5s
- [x] Implement Felicia contact: complete stage, check if gift held for 2x multiplier
- [x] On completion: award extra life, advance difficulty, play dancing cats animation, return to hub

**Requirements:** Req 10 (Love Game Bonus Stage)

## Task 20: HUD and Score Display

- [x] Create `scripts/ui/hud.gd` managing score, lives, and contextual displays
- [x] Implement score display integrated into fence graffiti (Alleyway Hub) using Label with custom font
- [x] Implement modern overlay score display for minigames and Love Game
- [x] Implement lives display (cat head icons)
- [x] Implement air meter bar (visible only in Fishbowl underwater phase)
- [x] Implement awake meter indicator (visible near dogs in Dogfood Room)
- [x] Connect to ScoreManager.score_changed signal for real-time updates
- [x] Implement high score display on title screen loaded from SaveManager

**Requirements:** Req 12 (Scoring System), Req 14 (Visual Presentation)

## Task 21: Title Screen and Game Over

- [x] Create `scenes/title_screen.tscn` with game logo, high score display, start button
- [x] Create `scenes/game_over.tscn` with final score, high score comparison, restart button
- [x] Implement title screen loading high score from SaveManager
- [x] Implement game over screen with new high score celebration if applicable
- [x] Implement restart flow: reset GameManager, ScoreManager, DifficultyManager, transition to ALLEYWAY_HUB
- [x] Add touch-to-start interaction on title screen

**Requirements:** Req 1 (Game State Machine), Req 13 (Save and Persistence System)

## Task 22: Placeholder Art Assets

- [x] Create placeholder sprites for Freddy (all animation states) in assets/sprites/freddy/
- [x] Create placeholder sprites for enemies (dog, spider, mice, eels, bird, enemy cats, cupid, broom) in assets/sprites/enemies/
- [x] Create placeholder environment sprites (alleyway, cheese, bookcase, fishbowl, birdcage, hearts) in assets/sprites/environments/
- [x] Create placeholder UI sprites (joystick, buttons, hearts for lives, air meter) in assets/sprites/ui/
- [x] Set up AnimatedSprite2D SpriteFrames resources for all animated entities
- [x] Use CGA-inspired color palette (cyan, magenta, white, black base with modern vibrant additions)

**Requirements:** Req 14 (Visual Presentation)

## Task 23: Android Lifecycle and Pause System

- [x] Implement pause menu (CanvasLayer overlay) with resume, restart, and quit options
- [x] Handle Android pause notification (NOTIFICATION_APPLICATION_PAUSED): pause game tree, pause audio
- [x] Handle Android resume notification (NOTIFICATION_APPLICATION_RESUMED): resume from paused state
- [x] Handle back button: show pause menu if in gameplay, quit if on title screen
- [x] Implement auto-save on pause/terminate (SaveManager.save() on lifecycle events)
- [x] Ensure no data loss on unexpected termination

**Requirements:** Req 16 (Android Platform Compatibility)

## Task 24: Integration Testing and Polish

- [x] Test full game loop: Title → Alleyway → Minigame → Alleyway (Felicia) → Love Game → Alleyway (next difficulty)
- [x] Test all death scenarios: dog, spider, eel, drowning, thrown objects, awake dogs
- [x] Test difficulty scaling across all 4 tiers
- [x] Test score persistence: play → die → verify high score saved → restart → verify loaded
- [x] Test touch controls responsiveness on multiple screen sizes
- [x] Test Android lifecycle: pause/resume mid-gameplay, verify state preserved
- [x] Performance profiling: verify 60fps on target hardware
- [x] Fix any collision edge cases or state machine deadlocks
