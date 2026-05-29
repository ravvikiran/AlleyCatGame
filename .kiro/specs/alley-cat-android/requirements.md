# Requirements Document

## Introduction

Alley Cat Android is a modern Android remake of the classic 1984 DOS game "Alley Cat" by Bill Williams. The player controls Freddy the Cat navigating an alleyway hub, entering open windows to complete minigames, and ultimately reaching Felicia in the Love Game bonus stage. The game features five distinct minigame rooms, progressive difficulty scaling, touch-optimized controls, and modern pixel art with a vibrant palette inspired by the original CGA/PCjr graphics.

## Glossary

- **Game_Engine**: The underlying game framework (Unity or Godot) responsible for rendering, physics, input handling, and game loop execution
- **State_Machine**: The core game flow controller managing transitions between ALLEYWAY_HUB, MINIGAME_ROOM, and LOVE_GAME states
- **Freddy**: The player-controlled cat character with distinct animation states
- **Felicia**: The female cat that Freddy must reach in the Love Game bonus stage
- **Alleyway_Hub**: The main navigation screen with three vertical levels, windows, hazards, and traversal mechanics
- **Minigame_Room**: One of five distinct gameplay rooms accessed through open windows in the Alleyway Hub
- **Love_Game**: The bonus stage with heart platforms, enemy cats, and Cupid arrows accessed after completing a minigame
- **Touch_Controller**: The virtual input system providing D-pad/joystick and action buttons for Android touch screens
- **Difficulty_System**: The progression system scaling game parameters across four tiers (Kitten, House Cat, Tomcat, Alley Cat)
- **Score_System**: The point tracking and display system integrated into the game UI
- **Save_System**: The local persistence layer using SharedPreferences or JSON for storing player progress
- **Air_Supply_Timer**: A countdown timer in the Fishbowl Room limiting how long Freddy can remain underwater
- **Awake_Meter**: A proximity-based alertness gauge on sleeping dogs in the Dogfood Room
- **Gift_Item**: A collectible object in the Love Game that can eliminate enemy cats and double the score multiplier

## Requirements

### Requirement 1: Game State Machine

**User Story:** As a player, I want the game to flow through distinct stages in a logical progression, so that I experience the full gameplay loop of exploration, challenge, and reward.

#### Acceptance Criteria

1. THE State_Machine SHALL manage three primary states: ALLEYWAY_HUB, MINIGAME_ROOM, and LOVE_GAME
2. WHEN the player enters an open window in the Alleyway Hub, THE State_Machine SHALL transition from ALLEYWAY_HUB to the corresponding MINIGAME_ROOM state
3. WHEN the player completes a minigame objective, THE State_Machine SHALL transition from MINIGAME_ROOM to ALLEYWAY_HUB with Felicia's window accessible
4. WHEN the player enters Felicia's window, THE State_Machine SHALL transition from ALLEYWAY_HUB to LOVE_GAME state
5. WHEN the player completes the Love Game, THE State_Machine SHALL transition to ALLEYWAY_HUB and increment the difficulty tier
6. IF the player loses all lives, THEN THE State_Machine SHALL transition to a GAME_OVER state and display the final score

### Requirement 2: Touch Controls

**User Story:** As a mobile player, I want responsive and intuitive touch controls, so that I can precisely control Freddy on a touchscreen device.

#### Acceptance Criteria

1. THE Touch_Controller SHALL display a virtual D-pad or floating joystick on the left side of the screen for horizontal movement and downward drop input
2. THE Touch_Controller SHALL display a Jump button on the right side of the screen
3. THE Touch_Controller SHALL display an Action button on the right side of the screen for minigame-specific interactions
4. WHEN the player performs a standing jump, THE Game_Engine SHALL apply a vertical arc trajectory with limited horizontal distance
5. WHEN the player performs a running jump, THE Game_Engine SHALL apply a trajectory covering greater horizontal distance than a standing jump
6. THE Touch_Controller SHALL register input within 16 milliseconds of touch contact
7. WHILE the player is in a minigame that does not require the Action button, THE Touch_Controller SHALL hide the Action button

### Requirement 3: Alleyway Hub Navigation

**User Story:** As a player, I want to explore a multi-level alleyway environment, so that I can find open windows and enter minigame rooms.

#### Acceptance Criteria

1. THE Alleyway_Hub SHALL render three vertical levels: street level with trash cans, fence level with graffiti displaying score and lives, and clothesline level with laundry items
2. THE Alleyway_Hub SHALL render an apartment facade above the clotheslines containing 12 windows
3. WHEN a window opens, THE Alleyway_Hub SHALL display the window in an open state for a randomized duration between 3 and 8 seconds
4. WHEN the player jumps into an open window while moving downward, THE State_Machine SHALL transition to the corresponding MINIGAME_ROOM
5. IF the player attempts to enter a closed window, THEN THE Alleyway_Hub SHALL block entry and Freddy SHALL bounce off the window
6. THE Alleyway_Hub SHALL open windows at random intervals with at least one window open at any given time

### Requirement 4: Alleyway Hub Hazards

**User Story:** As a player, I want environmental hazards in the alleyway, so that navigation is challenging and requires skill.

#### Acceptance Criteria

1. WHEN a window opens to throw an object, THE Alleyway_Hub SHALL spawn a hazard object (boot, telephone, or rolling pin) that falls with gravity
2. IF a hazard object hits Freddy, THEN THE Game_Engine SHALL knock Freddy down to the level below and deduct one life
3. WHILE the dog is active, THE Alleyway_Hub SHALL move the dog horizontally across the street level at a speed determined by the current difficulty tier
4. IF the dog contacts Freddy, THEN THE Game_Engine SHALL trigger instant death and deduct one life
5. WHEN Freddy is on the clothesline and a mouse runs across, THE Game_Engine SHALL cause Freddy to lose grip and fall to the level below
6. WHEN an enemy cat in a trash can contacts Freddy, THE Game_Engine SHALL knock Freddy down from the trash can

### Requirement 5: Cheese Room Minigame

**User Story:** As a player, I want to catch mice in a Swiss cheese maze, so that I experience a fast-paced pursuit challenge.

#### Acceptance Criteria

1. THE Minigame_Room SHALL display a Swiss cheese block with 16 holes arranged in a grid pattern
2. THE Minigame_Room SHALL spawn 4 mice that move between cheese holes using randomized paths
3. WHEN the player presses the Action button while Freddy is at a cheese hole, THE Game_Engine SHALL teleport Freddy to an adjacent connected hole
4. WHEN Freddy occupies the same hole as a mouse, THE Game_Engine SHALL register a catch and increment the caught mouse counter
5. WHEN the player catches all 4 mice, THE State_Machine SHALL mark the minigame as complete
6. WHILE the Cheese Room is active, THE Game_Engine SHALL spawn a Magic Broom hazard that sweeps horizontally across the room
7. WHILE the Cheese Room is active, THE Game_Engine SHALL spawn a Running Dog hazard that patrols the room floor
8. IF the Magic Broom or Running Dog contacts Freddy, THEN THE Game_Engine SHALL deduct one life and reset Freddy's position

### Requirement 6: Vase Room Minigame

**User Story:** As a player, I want to collect plants from a bookcase while avoiding a spider, so that I experience a tense evasion challenge.

#### Acceptance Criteria

1. THE Minigame_Room SHALL display a bookcase with 3 collectible plants placed on different shelves
2. THE Minigame_Room SHALL spawn a giant spider that tracks Freddy's horizontal position from above
3. WHEN the spider is directly above Freddy, THE Game_Engine SHALL cause the spider to drop vertically toward Freddy
4. IF the spider contacts Freddy, THEN THE Game_Engine SHALL trigger instant death and deduct one life
5. WHEN Freddy contacts a plant, THE Game_Engine SHALL collect the plant and increment the collected plant counter
6. WHEN the player collects all 3 plants, THE State_Machine SHALL mark the minigame as complete
7. THE Game_Engine SHALL scale the spider's movement speed based on the current difficulty tier

### Requirement 7: Dogfood Room Minigame

**User Story:** As a player, I want to drink from dog bowls while avoiding waking sleeping dogs, so that I experience a stealth-based challenge.

#### Acceptance Criteria

1. THE Minigame_Room SHALL display multiple dog bowls, each guarded by a sleeping dog
2. WHILE Freddy is within proximity of a sleeping dog, THE Game_Engine SHALL increase that dog's Awake_Meter proportionally to Freddy's distance (closer increases faster)
3. WHEN a dog's Awake_Meter reaches maximum, THE Game_Engine SHALL wake the dog and trigger an attack
4. IF an awake dog contacts Freddy, THEN THE Game_Engine SHALL trigger instant death and deduct one life
5. WHEN Freddy reaches a bowl and the player holds the Action button, THE Game_Engine SHALL animate Freddy drinking and mark that bowl as consumed
6. WHEN the player drinks from all bowls, THE State_Machine SHALL mark the minigame as complete
7. WHILE Freddy moves away from a sleeping dog, THE Game_Engine SHALL gradually decrease that dog's Awake_Meter

### Requirement 8: Fishbowl Room Minigame

**User Story:** As a player, I want to eat fish underwater while managing air supply and avoiding eels, so that I experience a time-pressure aquatic challenge.

#### Acceptance Criteria

1. THE Minigame_Room SHALL display an aquarium containing 12 fish swimming in randomized patterns
2. WHILE Freddy is underwater, THE Game_Engine SHALL enable 8-directional swimming movement with inertia-based physics
3. WHILE Freddy is underwater, THE Air_Supply_Timer SHALL count down from a starting value of 30 seconds
4. IF the Air_Supply_Timer reaches zero, THEN THE Game_Engine SHALL trigger instant death and deduct one life
5. WHEN Freddy surfaces above the water line, THE Air_Supply_Timer SHALL reset to the starting value
6. WHEN Freddy contacts a fish, THE Game_Engine SHALL consume the fish and increment the eaten fish counter
7. WHEN a fish is consumed, THE Game_Engine SHALL spawn one additional electric eel in the aquarium
8. THE Game_Engine SHALL move electric eels in linear paths that bounce off aquarium walls
9. IF an electric eel contacts Freddy, THEN THE Game_Engine SHALL trigger instant death and deduct one life
10. WHEN the player eats all 12 fish, THE State_Machine SHALL mark the minigame as complete

### Requirement 9: Birdcage Room Minigame

**User Story:** As a player, I want to free a bird from its cage and catch it, so that I experience a two-phase pursuit challenge.

#### Acceptance Criteria

1. THE Minigame_Room SHALL display a birdcage on a table containing one bird
2. WHEN Freddy pushes the birdcage off the table edge, THE Game_Engine SHALL release the bird and begin the pursuit phase
3. WHILE the bird is free, THE Game_Engine SHALL move the bird in a sine-wave flight pattern across the room
4. WHEN Freddy contacts the free bird, THE Game_Engine SHALL register a catch and mark the minigame as complete
5. WHILE the Birdcage Room is active, THE Game_Engine SHALL spawn a Magic Broom hazard that sweeps horizontally across the room
6. WHILE the Birdcage Room is active, THE Game_Engine SHALL spawn a Running Dog hazard that patrols the room floor
7. IF the Magic Broom or Running Dog contacts Freddy, THEN THE Game_Engine SHALL deduct one life and reset Freddy's position

### Requirement 10: Love Game Bonus Stage

**User Story:** As a player, I want to navigate heart platforms to reach Felicia, so that I experience a rewarding bonus stage after completing minigames.

#### Acceptance Criteria

1. THE Love_Game SHALL display 7 rows of Valentine heart platforms, each heart being either solid or broken
2. THE Love_Game SHALL spawn enemy cats that patrol each row, tracking Freddy's horizontal position
3. WHEN a Cupid shoots a diagonal arrow that hits a heart platform, THE Game_Engine SHALL toggle that heart between solid and broken states
4. IF Freddy steps on a broken heart, THEN THE Game_Engine SHALL cause Freddy to fall through to the row below
5. WHEN Freddy reaches the top row and contacts Felicia, THE Love_Game SHALL mark the bonus stage as complete
6. WHEN the player collects a Gift_Item and uses it near an enemy cat, THE Game_Engine SHALL temporarily eliminate that enemy cat for 5 seconds
7. WHEN the player reaches Felicia while holding a Gift_Item, THE Score_System SHALL apply a 2x score multiplier to the Love Game completion bonus
8. WHEN the Love Game is completed, THE Score_System SHALL award one extra life to the player
9. IF an enemy cat contacts Freddy, THEN THE Game_Engine SHALL knock Freddy down one row

### Requirement 11: Difficulty Progression System

**User Story:** As a player, I want the game to become progressively harder, so that I remain challenged as my skills improve.

#### Acceptance Criteria

1. THE Difficulty_System SHALL define four tiers: Kitten, House Cat, Tomcat, and Alley Cat
2. THE Difficulty_System SHALL start at the Kitten tier at the beginning of a new game
3. WHEN the player completes a Love Game stage, THE Difficulty_System SHALL advance to the next tier (capping at Alley Cat)
4. WHILE the difficulty tier increases, THE Difficulty_System SHALL decrease the number of trash cans available in the Alleyway Hub
5. WHILE the difficulty tier increases, THE Difficulty_System SHALL increase the dog's movement speed and spawn frequency in the Alleyway Hub
6. WHILE the difficulty tier increases, THE Difficulty_System SHALL increase the number of electric eels spawned per fish eaten in the Fishbowl Room
7. WHILE the difficulty tier increases, THE Difficulty_System SHALL increase the spider's tracking speed in the Vase Room
8. WHILE the difficulty tier increases, THE Difficulty_System SHALL increase enemy cat tracking accuracy in the Love Game

### Requirement 12: Scoring System

**User Story:** As a player, I want to earn and track points for my achievements, so that I have a measurable sense of progression and accomplishment.

#### Acceptance Criteria

1. THE Score_System SHALL award points when Freddy catches a mouse in the Cheese Room
2. THE Score_System SHALL award points when Freddy completes any minigame, including a time-based bonus for faster completion
3. THE Score_System SHALL apply the Love Game score multiplier to the completion bonus when applicable
4. THE Score_System SHALL display the current score integrated into the fence graffiti in the Alleyway Hub
5. THE Score_System SHALL display the current score as a modern overlay during minigames and the Love Game
6. THE Score_System SHALL persist the highest score across game sessions using the Save_System

### Requirement 13: Save and Persistence System

**User Story:** As a player, I want my progress and high scores saved locally, so that I can resume or review my achievements between sessions.

#### Acceptance Criteria

1. THE Save_System SHALL store the player's highest score using Android SharedPreferences or a local JSON file
2. WHEN the player achieves a new high score, THE Save_System SHALL update the stored high score immediately
3. WHEN the game launches, THE Save_System SHALL load the previously stored high score and display it on the title screen
4. IF the stored data is corrupted or missing, THEN THE Save_System SHALL initialize default values without crashing

### Requirement 14: Visual Presentation

**User Story:** As a player, I want modern pixel art visuals with smooth animations, so that the game feels polished and visually appealing on modern devices.

#### Acceptance Criteria

1. THE Game_Engine SHALL render all gameplay at a target frame rate of 60 frames per second
2. THE Game_Engine SHALL enforce landscape orientation for all game screens
3. THE Game_Engine SHALL scale the game viewport responsively to fit Android screen sizes ranging from 5-inch phones to 10-inch tablets without cropping gameplay elements
4. THE Game_Engine SHALL render Freddy with distinct sprite animations for: Idle, Walking, Running, Jumping, Falling, Hanging, Climbing, Eating/Drinking, Electrocuted, and Hurt/Dead states
5. THE Game_Engine SHALL use a high-resolution pixel art or clean 2D vector art style with a vibrant color palette inspired by the original CGA/PCjr graphics

### Requirement 15: Audio System

**User Story:** As a player, I want music and sound effects that evoke the original game with a modern twist, so that the audio enhances the gameplay experience.

#### Acceptance Criteria

1. THE Game_Engine SHALL play background music featuring a modern jazzy rendition with synth, upright bass, and brushed snare instrumentation
2. WHEN Freddy jumps, THE Game_Engine SHALL play a jump sound effect
3. WHEN Freddy lands on a surface, THE Game_Engine SHALL play a landing sound effect
4. WHEN Freddy is hit by a hazard, THE Game_Engine SHALL play a hurt sound effect
5. WHEN Freddy catches a mouse, THE Game_Engine SHALL play a catch sound effect
6. WHEN the dog barks, THE Game_Engine SHALL play a bark sound effect
7. WHEN the Magic Broom sweeps, THE Game_Engine SHALL play a sweeping sound effect
8. WHEN a vase breaks, THE Game_Engine SHALL play a breaking sound effect
9. WHEN Freddy enters water, THE Game_Engine SHALL play a splash sound effect
10. WHEN Freddy dies, THE Game_Engine SHALL play a meow death sound effect

### Requirement 16: Android Platform Compatibility

**User Story:** As a player, I want the game to run smoothly on my Android device, so that I have a reliable and performant gaming experience.

#### Acceptance Criteria

1. THE Game_Engine SHALL target Android API level 24 (Android 7.0) as the minimum supported version
2. THE Game_Engine SHALL maintain a consistent 60 frames per second on devices with mid-range hardware (Snapdragon 600 series or equivalent)
3. WHEN the Android system sends a pause lifecycle event, THE Game_Engine SHALL pause all gameplay and audio immediately
4. WHEN the Android system sends a resume lifecycle event, THE Game_Engine SHALL resume gameplay from the paused state without data loss
5. IF the application is terminated by the system, THEN THE Save_System SHALL preserve the current high score before shutdown
