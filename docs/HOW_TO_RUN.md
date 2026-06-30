# How to Run Midnight Prowl

## Important: This is a Godot Project, NOT an Android Studio Project

You CANNOT open this in Android Studio. This is built with **Godot Engine**.

| Tool | Purpose |
|------|---------|
| **Godot Engine 4.6** | Develop, run, and export the game |
| **Android Studio** | Only provides the Android SDK that Godot uses internally |

---

## Step 1: Run on Desktop (for testing)

1. Open **Godot Engine 4.6**
2. Import this project (select `project.godot`)
3. Press **F5** to run
4. The game runs in a window — use mouse to simulate touch

---

## Step 2: Run on Android Phone (direct from Godot)

### Prerequisites:
1. Install **Android Studio** (just for the SDK, you won't code in it)
   - Download: https://developer.android.com/studio
   - During install, make sure "Android SDK" is checked
   - Note the SDK path (usually `C:\Users\YOU\AppData\Local\Android\Sdk`)

2. In **Godot**, set the SDK path:
   - Go to **Editor → Editor Settings**
   - Search for "Android"
   - Set **"Export/Android/Android SDK Path"** to your SDK folder

3. Install **Export Templates**:
   - In Godot: **Editor → Manage Export Templates → Download for Current Version**
   - Wait for download to complete

4. On your **Android phone**:
   - Go to Settings → About Phone → tap "Build Number" 7 times (enables Developer Options)
   - Go to Settings → Developer Options → enable **USB Debugging**
   - Connect phone to PC via USB cable
   - Accept the "Allow USB debugging?" prompt on phone

### To run on phone:
1. In Godot, click the **📱 Android icon** in the top-right toolbar (next to the Play button)
2. Select your device from the list
3. Game installs and runs on your phone

---

## Step 3: Export an APK file

1. In Godot: **Project → Export**
2. Select the **"Android"** preset
3. Click **"Export Project"**
4. Choose save location, name it `MidnightProwl.apk`
5. Transfer APK to phone and install

### If you get errors during export:

| Error | Fix |
|-------|-----|
| "No Android SDK found" | Set SDK path in Editor → Editor Settings → Export/Android |
| "No export templates" | Editor → Manage Export Templates → Download |
| "No debug keystore" | Godot creates one automatically on first export, OR generate one manually |
| "JDK not found" | Install JDK 17 from https://adoptium.net |

---

## Common Issues

### "Game shows colored blocks, not real graphics"
- This is normal! The game uses placeholder shapes until you add real sprite PNG files
- See `ASSET_NAMING.md` for where to put real art files
- See `docs/FREE_ASSET_SOURCES.md` for where to get free art

### "Black screen when running"
- Check the **Output panel** at the bottom of Godot for red error messages
- Most likely a script error — the error will say which file and line number

### "Game runs but Freddy doesn't move"
- On desktop: click and drag on the LEFT side of the window (that's the joystick area)
- Click on the RIGHT side to jump

### "Export to Android fails"
- Make sure you have: Android SDK + Export Templates + JDK 17
- In Editor Settings → Export → Android, verify all paths are set
- Try: Editor → Manage Export Templates → ensure version matches your Godot

---

## Quick Summary

```
To TEST:     Open in Godot → Press F5
To PHONE:    Open in Godot → Click Android icon → Select device
To EXPORT:   Open in Godot → Project → Export → Android → Export Project
```

**You never need to open Android Studio to work on this game.**
Android Studio is only installed so Godot can use its SDK internally.
