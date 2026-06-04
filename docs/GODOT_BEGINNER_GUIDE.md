# Godot 4.6 Beginner Guide — For Midnight Prowl

A step-by-step guide for someone new to Godot Engine to open, run, and test this game project.

---

## Step 1: Install Godot 4.6

1. Go to https://godotengine.org/download
2. Download **Godot Engine - Standard** (not .NET version) for Windows
3. Extract the ZIP file anywhere (e.g., `C:\Godot\`)
4. You'll get a single file: `Godot_v4.6-stable_win64.exe`
5. Double-click it to run — no installation needed

---

## Step 2: Open the Project

1. When Godot opens, you see the **Project Manager** (list of projects)
2. Click the **"Import"** button on the right
3. Navigate to: `C:\Users\rvajjhala\Downloads\Personal Docs\AlleyCatGame\`
4. Select the file **`project.godot`** and click **Open**
5. Click **"Import & Edit"**
6. If you see a migration warning (4.4 → 4.6), click **OK** — this is normal
7. Wait 30-60 seconds for the first-time import to complete

---

## Step 3: Understanding the Godot Editor

When the project opens, you'll see the editor with these panels:

```
┌──────────────────────────────────────────────────────────────┐
│  Menu Bar (Scene, Project, Debug, Editor, Help)              │
├──────────┬───────────────────────────────┬───────────────────┤
│          │                               │                   │
│  Scene   │      2D/3D Viewport           │    Inspector      │
│  Tree    │    (Visual Editor)            │   (Properties)    │
│  (left)  │                               │    (right)        │
│          │                               │                   │
├──────────┴───────────────────────────────┴───────────────────┤
│  Bottom Panel: Output | Debugger | Audio | Animation         │
└──────────────────────────────────────────────────────────────┘
```

**Key panels:**
- **Scene Tree (left):** Shows all nodes in the current scene
- **FileSystem (bottom-left):** Shows your project files/folders
- **Inspector (right):** Shows properties of the selected node
- **Output (bottom):** Shows print statements and errors

---

## Step 4: Run the Game

### To run the full game:
- Press **F5** on your keyboard
- OR click the **▶ (Play)** button in the top-right corner of the editor

### To run just the current scene:
- Press **F6**
- OR click the **🎬 (Play Scene)** button (movie clapperboard icon)

### To stop the game:
- Press **F8**
- OR click the **⏹ (Stop)** button
- OR close the game window

---

## Step 5: Testing on Desktop (Simulating Touch)

Since this is a mobile game with touch controls, on desktop:
- **Mouse click = Touch tap** (Godot simulates touch with mouse by default)
- **Click left side of screen** = Joystick area (drag to move)
- **Click right-lower area** = Jump button
- **Click right-upper area** = Action button

### The game flow:
1. **Loading screen** → "LOADING..." text (0.5 seconds)
2. **Title Screen** → Shows "MIDNIGHT PROWL", tap/click to start
3. **Player Registration** (first time) → Enter your name, click "START PLAYING"
4. **Tutorial** (first time) → Follow the on-screen instructions
5. **Alleyway Hub** → The main game! Move around, jump into windows

---

## Step 6: Understanding the Game Controls

When playing on desktop:

| Action | How to Do It |
|--------|-------------|
| Move left/right | Click and drag on the LEFT side of the screen |
| Jump | Click on the LOWER-RIGHT area |
| Action (in minigames) | Click on the UPPER-RIGHT area |
| Pause | Press Escape key |
| Back to title | Press Escape on title screen |

**Note:** The controls are designed for touchscreens. On desktop, you're simulating touch with your mouse. The game is best experienced on an actual Android device.

---

## Step 7: Common Editor Actions

### View a scene file:
1. In the **FileSystem** panel (bottom-left), navigate to `scenes/`
2. Double-click any `.tscn` file to open it in the editor
3. You'll see its node tree on the left and visual layout in the center

### View a script:
1. In the FileSystem, navigate to `scripts/`
2. Double-click any `.gd` file to open it in the script editor
3. OR click the scroll icon (📜) next to a node that has a script

### Switch between 2D view and Script view:
- Click **"2D"** at the top-center to see the visual scene editor
- Click **"Script"** at the top-center to see code

---

## Step 8: Project File Structure (What's What)

| Folder/File | What It Is |
|-------------|-----------|
| `project.godot` | Main project config (DO NOT delete) |
| `scenes/` | Game screens (.tscn files = scene layouts) |
| `scenes/main.tscn` | First scene loaded (loading screen) |
| `scenes/title_screen.tscn` | Title screen you see first |
| `scenes/alleyway_hub.tscn` | Main gameplay level |
| `scenes/minigames/` | The 5 challenge rooms |
| `scripts/` | All game logic code (.gd files) |
| `scripts/autoloads/` | Global managers (always running) |
| `scripts/player/freddy.gd` | The cat you control |
| `assets/` | Art, audio, fonts (placeholder for now) |
| `.godot/` | Engine cache (auto-generated, safe to delete) |

---

## Step 9: If Something Goes Wrong

### Game shows black screen when running:
1. Check the **Output** panel at the bottom for red error text
2. Common fix: Stop (F8), then try F5 again

### "Scene not found" error:
- A scene file might be missing. Check `scenes/` folder.

### "Parse Error" in a script:
- Open the script mentioned in the error
- Look at the line number mentioned
- It's usually a typo or syntax issue

### Editor is frozen/slow:
1. Close Godot via Task Manager
2. Delete the `.godot` folder in the project
3. Reopen — it will reimport (takes ~1 min)

### Game runs but nothing visible:
- Make sure the game window is in focus
- Try maximizing the game window
- Check if your display scale (Windows Settings > Display > Scale) is set very high

---

## Step 10: Exporting for Android

### Prerequisites:
1. Install **Android Studio** (for Android SDK)
2. In Android Studio, install SDK for API 24+ and build tools
3. Set the SDK path in Godot: **Editor > Editor Settings > Export > Android**
   - Set "Android SDK Path" to your SDK location (usually `C:\Users\YOU\AppData\Local\Android\Sdk`)
4. Install **Android Export Templates**: **Editor > Manage Export Templates > Download**

### To export:
1. **Project > Export** (top menu)
2. Select the **"Android"** preset (already configured)
3. Click **"Export Project"**
4. Choose where to save the `.apk` or `.aab` file
5. Transfer the `.apk` to your phone and install it

### Quick testing on phone:
1. Enable **Developer Options** on your Android phone
2. Enable **USB Debugging**
3. Connect phone via USB
4. In Godot, click the **Android phone icon** in the top-right (next to Play)
5. Your game will install and run on the phone directly

---

## Keyboard Shortcuts Reference

| Shortcut | Action |
|----------|--------|
| F5 | Run the game |
| F6 | Run current scene only |
| F8 | Stop running game |
| Ctrl+S | Save current scene |
| Ctrl+Shift+S | Save all scenes |
| Ctrl+F | Find in script |
| Ctrl+Shift+F | Find across all scripts |
| Ctrl+Z | Undo |
| Ctrl+Y | Redo |
| Ctrl+Tab | Switch between open scripts |

---

## Quick Troubleshooting Checklist

- [ ] Is Godot 4.6 installed? (not 3.x — very different)
- [ ] Did you import `project.godot` (not just open the folder)?
- [ ] Did you wait for the first import to complete (~60 seconds)?
- [ ] Is the Output panel showing errors? (check bottom of editor)
- [ ] Did you press F5 (not F6) to run the game from the start?
- [ ] Is the game window appearing? (check your taskbar)

---

*If you're still stuck, look at the red error messages in the Output panel at the bottom of the Godot editor — those tell you exactly what's wrong and which file/line to look at.*
