# gbios (Gboard for iOS)

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2016.0%2B-blue?style=for-the-badge&logo=apple&logoColor=white" alt="iOS 16+"/>
  <img src="https://img.shields.io/badge/Language-Swift%205.0%20%7C%20SwiftUI-orange?style=for-the-badge&logo=swift&logoColor=white" alt="Swift / SwiftUI"/>
  <img src="https://img.shields.io/badge/Based%20On-PixelBoard%20%26%20GboardWu-purple?style=for-the-badge&logo=google" alt="PixelBoard & GboardWu"/>
  <img src="https://img.shields.io/badge/Architecture-UIInputViewController%20%2B%20App%20Groups-green?style=for-the-badge" alt="Architecture"/>
  <img src="https://img.shields.io/badge/License-MIT-lightgrey?style=for-the-badge" alt="License"/>
</p>

**gbios** is a comprehensive, native iOS port of Google's flagship Android keyboard features, inspired by and implementing the powerhouse capabilities of [Akshay Kadam's PixelBoard](https://github.com/Akshayykadam/PixelBoard) and [Jason Wu's GboardWu (Gboard-patches)](https://github.com/jasonwu1994/Gboard-patches).

Stock iOS keyboards have notoriously lacked the productivity features that Android Gboard power users rely on every day: **secondary character hints and popup bubbles on every key**, a **multi-clip clipboard manager with pinned snippets**, **Web Clipboard desktop-to-iPhone LAN syncing**, **dedicated number row**, **Gemini Rambler natural voice typing**, **AI writing tools**, **live camera OCR scan text**, and **Material 3 Belka expressive styling**. **gbios** brings all of these features to iOS in a native, privacy-first Swift & SwiftUI implementation.

---

## 🌟 Feature Comparison Matrix

| Feature | Stock iOS Keyboard | Official iOS Gboard | Android Gboard / PixelBoard / GboardWu | **gbios (This Project)** |
| :--- | :---: | :---: | :---: | :---: |
| **Secondary Symbol Hints on Every Key** | ❌ No | ❌ No | ✅ Yes (Numbers & symbols on letters) | ✅ **Yes (Full Android-style hints)** |
| **Keypress Popup Bubbles & Accents** | ⚠️ Basic | ⚠️ Basic | ✅ Yes (Elevated M3 bubbles & variants) | ✅ **Yes (Elevated preview & accent menu)** |
| **Clipboard History & Search** | ❌ No | ❌ No | ✅ Yes (Multi-clip history with search) | ✅ **Yes (History, search, preview)** |
| **Pinned Clipboard Snippets** | ❌ No | ❌ No | ✅ Yes (Pins persist across restarts) | ✅ **Yes (Pinned clips never expire)** |
| **Web Clipboard (LAN Desktop Sync)** | ❌ No | ❌ No | ✅ Yes (Jason Wu's GboardWu portal) | ✅ **Yes (Built-in LAN HTTP server)** |
| **Gemini Rambler Voice Typing** | ❌ No | ❌ No | ✅ Yes (PixelBoard Rambler speech cleanup) | ✅ **Yes (Strips 'um', 'uh', 'like')** |
| **In-Line AI Writing Tools** | ❌ No | ❌ No | ✅ Yes (PixelBoard Writing Tools) | ✅ **Yes (Proofread, tone switcher)** |
| **Dedicated Top Number Row** | ❌ No | ❌ No | ✅ Yes (Configurable top row) | ✅ **Yes (Toggleable numeric row)** |
| **Camera OCR Scan Text** | ⚠️ System only | ❌ No | ✅ Yes (Dedicated OCR viewfinder) | ✅ **Yes (Vision framework OCR)** |
| **Spacebar Cursor Trackpad** | ⚠️ Hold required | ❌ No | ✅ Yes (Horizontal swipe scrubbing) | ✅ **Yes (Smooth swipe cursor trackpad)** |
| **Dedicated Text Editing D-Pad** | ❌ No | ❌ No | ✅ Yes (Arrows, Select All, Cut, Copy) | ✅ **Yes (Complete D-pad editing panel)** |
| **Inline Math Calculator** | ❌ No | ❌ No | ✅ Yes (GboardWu arithmetic evaluation) | ✅ **Yes (Auto-evaluates math in chips)** |
| **Material 3 Belka Rounded Keys** | ❌ No | ❌ No | ✅ Yes (PixelBoard Belka UI) | ✅ **Yes (Belka pill keycaps & themes)** |
| **Frosted Glass Blur Background** | ⚠️ Fixed | ❌ No | ✅ Yes (GboardWu frosted glass) | ✅ **Yes (Live UIKit UIBlurEffect)** |
| **One-Handed & Floating Dock** | ⚠️ Basic | ❌ No | ✅ Yes (Left/Right dock with quick swap) | ✅ **Yes (Left & Right dock containers)** |
| **JSON Configuration Backup/Restore**| ❌ No | ❌ No | ✅ Yes (GboardWu export/import format) | ✅ **Yes (Portable JSON export/import)** |

---

## 🚀 Key Modules & Capabilities

### 1. Android-Style Key Popups & Secondary Symbols
- **Keycap Symbol Hints**: Every letter displays its secondary numeric or punctuation symbol (e.g. `q` -> `1`, `w` -> `2`, `a` -> `@`, `s` -> `#`).
- **Elevated Popup Bubbles**: Tapping or holding keys renders Android-style floating preview bubbles.
- **Accented Character Menus**: Long-pressing letters opens quick-selection accent drawers (e.g. `e` -> `é`, `è`, `ê`, `ë`, `ē`).

### 2. Comprehensive Clipboard Manager & Web Clipboard
- **In-Keyboard Clipboard Drawer**: Tap the clipboard icon to access recently copied clips.
- **Pinning System**: Pin frequent addresses, snippets, or code blocks so they are never purged.
- **Web Clipboard (Ported from Jason Wu's GboardWu)**:
  - Runs an embedded, low-latency local HTTP server on port `8088`.
  - Open `http://<iphone-ip>:8088` on any Mac, Windows, or Linux browser on the same Wi-Fi.
  - Enter your 4-digit pairing code to view iPhone keyboard clipboard history or push text clips directly to the iPhone keyboard.

### 3. Gemini "Rambler" Natural Voice Dictation & AI Writing Tools
- **Speech Cleanup**: Automatically strips conversational filler words (*"um"*, *"uh"*, *"like"*, *"you know"*, *"ah"*) in real time.
- **Auto-Punctuation & Thought Completion**: Resolves self-corrections on the fly.
- **Battery-Friendly Lifecycle**: Automatically releases speech and microphone audio taps as soon as dictation stops or keyboard hides.
- **AI Writing Assistant**: Drawer with 1-tap **Proofread**, **Tone Switcher** (*Professional*, *Casual*, *Concise*), and **Rephrase**.

### 4. Precision Text Editing Pad & Cursor Trackpad
- **Spacebar Trackpad**: Slide your finger horizontally across the spacebar to glide the cursor character-by-character.
- **Text Editing D-Pad**: Tap the navigation icon in the toolbar to reveal directional arrows (Up, Down, Left, Right), Select All, Cut, Copy, Paste, and Undo/Redo.

### 5. Inline Math Calculator
- Evaluates arithmetic expressions typed in the input field (e.g., `45 * 12 + 10 = ?` or `250 * 0.08`).
- An answer chip (e.g., `= 550`) immediately appears in the suggestion row. Tap it to replace the formula with the calculated result.

### 6. Material 3 Expressive Belka Themes
- **Keycap Styles**: Toggle between Google's **Belka Pill (Material 3)** shape and Classic Rectangular keys.
- **Built-in Palettes**: Material 3 Dynamic (Pixel), AMOLED True Black, Frosted Glass Blur, Pixel Ocean Blue, and Sage Mint Green.
- **Google "G" Logo**: Display the iconic "G" branding on the spacebar.

---

## 🛠 Project Architecture

The project is structured into three clean targets using [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```
gbios/
├── project.yml                          # XcodeGen declarative project spec
├── Shared/                              # Common code compiled into both targets
│   ├── Models/
│   │   ├── ClipboardItem.swift         # Clipboard entry model & serialization
│   │   ├── KeyboardTheme.swift         # M3 themes, Belka key styles & palettes
│   │   ├── KeyboardSettings.swift      # AppGroup-backed reactive settings store
│   │   └── KeyModel.swift              # QWERTY matrix, secondary symbols & popups
│   ├── Services/
│   │   ├── ClipboardStore.swift        # AppGroup shared clipboard persistence
│   │   ├── WebClipboardServer.swift    # LAN Web Clipboard HTTP server
│   │   └── MathCalculator.swift        # Arithmetic expression evaluator
│   └── Extensions/
│       └── Color+Theme.swift           # Hex color parser & SwiftUI styling
├── GBoardApp/                           # Host Configuration & Playground App
│   ├── GBoardApp.swift                 # SwiftUI App entry point
│   ├── Info.plist & Entitlements       # App Groups & Permission descriptions
│   └── Views/
│       ├── MainSettingsView.swift      # Interactive playground & quick toggles
│       ├── ClipboardManagerView.swift  # Clip history & Web Clipboard LAN server
│       ├── ThemeGalleryView.swift      # M3 Belka keycap & theme picker
│       ├── RamblerVoiceSettingsView.swift # Rambler voice & AI assistant setup
│       ├── AdvancedSettingsView.swift  # Popups, number row, JSON backup/restore
│       └── SetupInstructionsView.swift # Step-by-step iOS keyboard activation
└── GBoardKeyboardExtension/             # Custom iOS Keyboard Extension
    ├── Info.plist & Entitlements       # RequestsOpenAccess = YES, App Groups
    ├── KeyboardViewController.swift    # UIInputViewController bridge
    ├── ViewModels/
    │   ├── KeyboardViewModel.swift     # Typing engine, cursor offset, popups
    │   └── VoiceTypingViewModel.swift  # Rambler speech recognition & cleanup
    └── Views/
        ├── MainKeyboardView.swift      # Root keyboard container
        ├── KeyButtonView.swift         # M3 Belka key with secondary symbol hints
        ├── KeyPopupBubbleView.swift    # Elevated keypress popup & accent menu
        ├── ToolbarView.swift           # Gboard top action bar
        ├── SuggestionStripView.swift   # Predictions & math calculator chip
        ├── ClipboardView.swift         # In-keyboard clipboard drawer
        ├── AIWritingToolsView.swift    # Gemini writing tools drawer
        ├── TextEditingPadView.swift    # D-pad precision navigation panel
        ├── CameraOCRView.swift         # Vision OCR scanner panel
        ├── EmojiPaletteView.swift      # Emoji picker with size slider
        └── OneHandedContainerView.swift# One-handed left/right docked container
```

---

## 📦 How to Build and Run

### Prerequisites
- macOS Sonoma (14.0+) or macOS Sequoia (15.0+)
- Xcode 15.0+ or Xcode 16.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### 1. Clone the Repository
```bash
git clone https://github.com/benjamin-brinkerhoff/gbios.git
cd gbios
```

### 2. Generate the Xcode Project
```bash
xcodegen generate
```
This generates `gbios.xcodeproj` with all build phases, schemes, and target dependencies configured.

### 3. Open and Build in Xcode
```bash
open gbios.xcodeproj
```
- Select the `GBoardApp` scheme and build/run on your iOS Simulator or connected iPhone.
- To test the extension directly, select the `GBoardKeyboardExtension` scheme and run, choosing Safari or Messages as the host app.

---

## 📱 How to Enable on iPhone

1. Launch the **gbios** app once on your iPhone.
2. Open iOS **Settings** > **General** > **Keyboard** > **Keyboards**.
3. Tap **Add New Keyboard...** and select **gbios** under Third-Party Keyboards.
4. Tap **gbios** in your list of keyboards and toggle **Allow Full Access** to **ON**.
   > *Note: Full Access is required by iOS for custom keyboards to read the shared clipboard container, access speech recognition for Gemini Rambler voice typing, and run the Web Clipboard LAN server.*
5. Open any app (Messages, Notes, Safari) and tap the Globe icon on your keyboard to switch to **gbios**!

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.
