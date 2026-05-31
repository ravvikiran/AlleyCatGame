# Google Play Store Publishing Guide — Midnight Prowl

A complete checklist and best practices guide for publishing your first Android game on the Google Play Store.

---

## Table of Contents

1. [Prerequisites & Accounts](#1-prerequisites--accounts)
2. [App Signing & Build](#2-app-signing--build)
3. [Store Listing Assets](#3-store-listing-assets)
4. [Content Rating](#4-content-rating)
5. [Privacy Policy](#5-privacy-policy)
6. [App Content & Compliance](#6-app-content--compliance)
7. [Testing Before Release](#7-testing-before-release)
8. [Pricing & Distribution](#8-pricing--distribution)
9. [Release Strategy](#9-release-strategy)
10. [Post-Launch Checklist](#10-post-launch-checklist)

---

## 1. Prerequisites & Accounts

### Google Play Developer Account
- **Cost:** One-time $25 USD registration fee
- **Sign up:** https://play.google.com/console/signup
- **Identity verification:** Google now requires identity verification (government ID + photo) for new accounts. This can take 2-7 business days.
- **Organization vs Individual:** Choose "Individual" for solo developers. Organization requires a D-U-N-S number.

### What You Need Ready
- [ ] Google account (dedicated one for your developer identity is recommended)
- [ ] Credit/debit card for the $25 fee
- [ ] Government-issued photo ID for verification
- [ ] A computer with Android SDK installed
- [ ] Your game exported as a signed AAB (Android App Bundle)

---

## 2. App Signing & Build

### Generate a Signing Key (Do This Once, Keep It Forever)

```bash
keytool -genkey -v -keystore midnight-prowl-release.keystore -alias midnight_prowl -keyalg RSA -keysize 2048 -validity 10000
```

You'll be prompted for:
- Keystore password (choose a strong one, NEVER lose this)
- Your name, organization, city, country
- Key password

**CRITICAL: Back up your keystore file and passwords in multiple secure locations. If you lose them, you can NEVER update your app on Google Play.**

### Configure Godot Export

1. Open Godot → Project → Export → Android preset
2. Set the keystore path to your `.keystore` file
3. Enter the alias and passwords
4. Set **Export Format** to **AAB** (Android App Bundle) — Google Play requires AAB, not APK
5. Set Min SDK to 24, Target SDK to 34 (latest stable)

### Build Settings Checklist
- [ ] Package name: `com.midnightprowl.game` (cannot change after publishing)
- [ ] Version Code: Start at 1, increment with every upload
- [ ] Version Name: Use semantic versioning (e.g., "1.0.0")
- [ ] Target architectures: arm64-v8a (required), armeabi-v7a (optional for older devices)
- [ ] Export as AAB (not APK)
- [ ] Release build (not debug)

### Google Play App Signing (Recommended)
- Enroll in **Play App Signing** during first upload
- Google manages your app signing key (more secure)
- You sign with an "upload key" — if you lose it, Google can reset it
- This is now the default and strongly recommended

---

## 3. Store Listing Assets

### Required Graphics

| Asset | Size | Format | Notes |
|-------|------|--------|-------|
| App Icon | 512 x 512 px | PNG (32-bit, no alpha) | High-res version of your launcher icon |
| Feature Graphic | 1024 x 500 px | PNG or JPEG | Shown at top of store listing, no text in corners |
| Phone Screenshots | Min 2, max 8 | 16:9 or 9:16, min 320px, max 3840px | Show actual gameplay |
| Tablet Screenshots | Min 1 (if targeting tablets) | 16:9, min 1080px wide | Show gameplay on tablet |

### Recommended Additional Assets
- [ ] Promo Video (YouTube link, 30-120 seconds, landscape)
- [ ] Short description (max 80 characters)
- [ ] Full description (max 4000 characters)

### Store Listing Text for Midnight Prowl

**App Name:** Midnight Prowl (max 30 characters)

**Short Description (80 chars max):**
```
A stray cat's quest for love — retro platformer with 5 unique minigames!
```

**Full Description (suggested):**
```
🐱 MIDNIGHT PROWL — A stray cat's quest for love under the city lights.

Play as Freddy, a scrappy alley cat navigating rooftops, dodging hazards, and completing challenges to win the heart of Felicia.

🎮 FEATURES:
• Navigate a multi-level urban alleyway with trash cans, fences, and clotheslines
• Enter open windows to discover 5 unique minigame rooms
• Cheese Maze — Chase mice through Swiss cheese holes
• Spider Library — Dodge a giant spider while collecting plants
• Dog Kennel — Sneak past sleeping dogs to steal their food
• Aquarium — Swim underwater, eat fish, avoid electric eels
• Birdcage — Free a bird and catch it mid-flight
• Complete the Love Game bonus stage to reach your sweetheart
• Progressive difficulty: Kitten → House Cat → Tomcat → Alley Cat
• Local leaderboard with score sharing
• Touch-optimized controls designed for mobile

🎨 RETRO-MODERN STYLE:
Inspired by classic 80s arcade platformers, reimagined with vibrant pixel art and smooth 60fps animations.

🏆 COMPETE:
Track your scores on the local leaderboard and share them with friends via email or social media.

No ads. No in-app purchases. No internet required. Just pure retro gaming fun.
```

### Screenshot Tips
- Show the title screen, alleyway hub, at least 2 minigames, and the Love Game
- Add short captions overlaid on screenshots (e.g., "5 Unique Minigames!")
- Use device frames (phone mockups) for a professional look
- Tools: https://screenshots.pro or Figma templates

---

## 4. Content Rating

Google Play requires an IARC content rating questionnaire.

### For Midnight Prowl, expect:
- **Violence:** Mild cartoon violence (cat gets knocked around, no blood)
- **Sexuality:** None
- **Language:** None
- **Substances:** None
- **Gambling:** None
- **User interaction:** None (no multiplayer, no chat)
- **Data sharing:** None (no internet features)

### Expected Rating: **PEGI 3 / Everyone**

### Steps:
1. Go to Play Console → Your App → Policy → App Content → Content Rating
2. Fill out the IARC questionnaire honestly
3. You'll receive a rating automatically
4. This is required before you can publish

---

## 5. Privacy Policy

**Required by Google Play for ALL apps**, even if you collect no data.

### For Midnight Prowl (no network, no data collection):

Create a simple privacy policy and host it somewhere accessible (GitHub Pages, a simple webpage, or Google Sites).

**Sample Privacy Policy:**

```
Privacy Policy for Midnight Prowl

Last updated: [DATE]

Midnight Prowl is a single-player offline game developed by [YOUR NAME].

DATA COLLECTION:
This app does NOT collect, store, or transmit any personal data to external servers. All game data (scores, player name, settings) is stored locally on your device only.

PERMISSIONS:
This app does not require any special permissions beyond basic storage for saving game progress locally.

THIRD-PARTY SERVICES:
This app does not use any third-party analytics, advertising, or tracking services.

CHILDREN'S PRIVACY:
This app does not knowingly collect information from children. The app is suitable for all ages.

CONTACT:
If you have questions about this privacy policy, contact: [YOUR EMAIL]

CHANGES:
We may update this policy from time to time. Changes will be posted here.
```

### Where to Host It:
- **Free option:** Create a GitHub repository with a `privacy-policy.md` file, enable GitHub Pages
- **URL format:** `https://yourusername.github.io/midnight-prowl-privacy/`
- Enter this URL in Play Console → Policy → App Content → Privacy Policy

---

## 6. App Content & Compliance

### Data Safety Form (Required)
In Play Console → Policy → App Content → Data Safety:

For Midnight Prowl, declare:
- [ ] "My app does NOT collect or share any user data" ✓
- [ ] No data collected
- [ ] No data shared with third parties
- [ ] No account required

### Ads Declaration
- [ ] "Does your app contain ads?" → **No**

### App Access
- [ ] "Is all functionality available without special access?" → **Yes** (no login required)

### Government Apps
- [ ] "Is this a government app?" → **No**

### Financial Features
- [ ] "Does your app provide financial services?" → **No**

### Health Features
- [ ] "Is this a health app?" → **No**

---

## 7. Testing Before Release

### Internal Testing (Recommended First Step)
1. Play Console → Testing → Internal Testing
2. Upload your AAB
3. Add up to 100 testers by email
4. They get a private Play Store link to install
5. Use this to verify the app installs and runs correctly on real devices

### Closed Testing (Alpha/Beta)
- Up to 2000 testers
- Good for getting feedback before public launch
- Requires testers to opt-in via a link

### Open Testing (Public Beta)
- Anyone can join
- Shows up on Play Store with "Early Access" badge
- Good for stress testing before full launch

### Device Testing Checklist
- [ ] Test on at least 3 different screen sizes (5", 6.5", 10" tablet)
- [ ] Test on Android 7.0 (API 24) — your minimum target
- [ ] Test on latest Android version
- [ ] Test with poor network (shouldn't matter for offline game)
- [ ] Test app lifecycle: home button, back button, rotate (should be locked landscape)
- [ ] Test after device restart
- [ ] Verify touch controls work on all screen densities
- [ ] Check for ANR (App Not Responding) — game should never freeze

### Pre-Launch Report
- Google automatically runs your app on Firebase Test Lab devices
- Check Play Console → Testing → Pre-launch report for crashes
- Fix any issues before production release

---

## 8. Pricing & Distribution

### Pricing
- [ ] **Free** or **Paid** — decide before publishing (cannot change from paid to free easily)
- For a first game, **Free** is recommended for maximum downloads
- If free: no in-app purchases needed for Midnight Prowl

### Countries
- [ ] Select "All countries" unless you have a reason to restrict
- Default: available in all 170+ countries

### Device Compatibility
- Godot handles this via the manifest, but verify in Play Console:
  - [ ] Phones: Yes
  - [ ] Tablets: Yes (your responsive scaling handles this)
  - [ ] Chromebooks: Optional (landscape games work well)
  - [ ] Android TV: No (touch controls required)
  - [ ] Wear OS: No

---

## 9. Release Strategy

### Recommended Launch Flow

```
Week 1:  Internal Testing (you + close friends)
         Fix critical bugs
         
Week 2:  Closed Testing (10-50 testers)
         Gather feedback on controls, difficulty
         
Week 3:  Open Testing (optional)
         Final polish based on feedback
         
Week 4:  Production Release
         Full public launch
```

### Production Release Steps
1. Play Console → Production → Create new release
2. Upload your signed AAB
3. Write release notes (what's new)
4. Set rollout percentage (start at 20%, increase over days)
5. Review and submit

### Review Time
- First submission: 3-7 days (can be longer)
- Updates: Usually 1-3 days
- Google may reject for policy violations — read rejection emails carefully

### Staged Rollout
- Start at 20% of users
- Monitor crash reports for 24-48 hours
- If stable, increase to 50%, then 100%
- You can halt a rollout if issues are found

---

## 10. Post-Launch Checklist

### Monitor (First 2 Weeks)
- [ ] Check crash reports daily (Play Console → Quality → Android Vitals)
- [ ] Monitor ANR rate (should be < 0.47%)
- [ ] Monitor crash rate (should be < 1.09%)
- [ ] Respond to user reviews (especially negative ones)
- [ ] Check uninstall rate

### Android Vitals Thresholds
| Metric | Bad Threshold | Your Target |
|--------|--------------|-------------|
| ANR rate | > 0.47% | < 0.1% |
| Crash rate | > 1.09% | < 0.5% |
| Excessive wakeups | > 10/hour | 0 (offline game) |
| Stuck partial wake locks | > 0.10% | 0 (offline game) |

### Ongoing Maintenance
- [ ] Update target SDK annually (Google requires targeting recent API levels)
- [ ] Address new device form factors (foldables, etc.)
- [ ] Respond to policy change emails from Google
- [ ] Keep your developer account in good standing (respond to policy issues within 7 days)

---

## Quick Reference: Complete Submission Checklist

### Before You Start
- [ ] Google Play Developer account ($25, verified)
- [ ] Signing keystore generated and backed up securely
- [ ] Privacy policy hosted at a public URL

### Build
- [ ] Export as AAB (not APK)
- [ ] Release build (not debug)
- [ ] Version code: 1 (increment for updates)
- [ ] Min SDK: 24, Target SDK: 34
- [ ] Package name finalized: `com.midnightprowl.game`

### Store Listing
- [ ] App name (30 chars max)
- [ ] Short description (80 chars max)
- [ ] Full description (4000 chars max)
- [ ] App icon 512x512 PNG
- [ ] Feature graphic 1024x500
- [ ] At least 2 phone screenshots
- [ ] At least 1 tablet screenshot (if targeting tablets)
- [ ] App category: Games → Arcade
- [ ] Contact email

### Policy & Compliance
- [ ] Content rating questionnaire completed
- [ ] Privacy policy URL entered
- [ ] Data safety form completed
- [ ] Ads declaration: No ads
- [ ] Target audience: General (not "designed for children" unless you want COPPA compliance)

### Testing
- [ ] Internal test track verified on real device
- [ ] Pre-launch report reviewed (no critical crashes)
- [ ] Touch controls tested on multiple screen sizes

### Release
- [ ] Production release created
- [ ] Release notes written
- [ ] Staged rollout at 20%
- [ ] Monitor for 48 hours before full rollout

---

## Common Rejection Reasons & How to Avoid Them

| Reason | Prevention |
|--------|-----------|
| Broken functionality | Test thoroughly on internal track first |
| Missing privacy policy | Host one even if you collect no data |
| Misleading metadata | Don't use competitor names in description |
| Intellectual property | Don't reference "Alley Cat" or other trademarked games |
| Crashes on launch | Test on API 24 device/emulator |
| Inappropriate content | Keep it family-friendly |
| Deceptive behavior | No hidden data collection, no fake buttons |
| Minimum functionality | Game must be playable, not just a splash screen |

---

## Useful Links

- Google Play Console: https://play.google.com/console
- Developer Policy Center: https://play.google.com/about/developer-content-policy/
- Launch Checklist (official): https://developer.android.com/distribute/best-practices/launch/launch-checklist
- Asset requirements: https://support.google.com/googleplay/android-developer/answer/9866151
- Content rating: https://support.google.com/googleplay/android-developer/answer/188189
- Data safety form: https://support.google.com/googleplay/android-developer/answer/10787469

---

## Cost Summary

| Item | Cost | Frequency |
|------|------|-----------|
| Google Play Developer Account | $25 | One-time |
| Privacy Policy Hosting (GitHub Pages) | Free | — |
| Signing Key (keytool) | Free | — |
| Godot Engine | Free (MIT license) | — |
| **Total to publish** | **$25** | — |

---

*Document created for Midnight Prowl v1.0.0 — Last updated: May 2026*
