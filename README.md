# gbios (Gboard for iOS)

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2016.0%2B-blue?style=for-the-badge&logo=apple&logoColor=white" alt="iOS 16+"/>
  <img src="https://img.shields.io/badge/Language-Swift%205.0%20%7C%20SwiftUI-orange?style=for-the-badge&logo=swift&logoColor=white" alt="Swift / SwiftUI"/>
  <img src="https://img.shields.io/badge/Based%20On-PixelBoard%20%26%20GboardWu-purple?style=for-the-badge&logo=google" alt="PixelBoard & GboardWu"/>
  <img src="https://img.shields.io/badge/CI%2FCD-Unsigned%20IPA%20Auto--Release-success?style=for-the-badge&logo=githubactions&logoColor=white" alt="Unsigned IPA Release"/>
  <img src="https://img.shields.io/badge/License-MIT-lightgrey?style=for-the-badge" alt="License"/>
</p>

**gbios** is a comprehensive, native iOS port of Google's flagship Android keyboard features, inspired by and implementing the powerhouse capabilities of [Akshay Kadam's PixelBoard](https://github.com/Akshayykadam/PixelBoard) and [Jason Wu's GboardWu (Gboard-patches)](https://github.com/jasonwu1994/Gboard-patches).

Stock iOS keyboards have notoriously lacked the productivity features that Android Gboard power users rely on every day: **in-keyboard live Google Translate**, **secondary character hints and popup bubbles on every key**, a **multi-clip clipboard manager with pinned snippets**, **Web Clipboard desktop-to-iPhone LAN syncing**, **dedicated number row**, **Gemini Rambler natural voice typing**, **AI writing tools**, **live camera OCR scan text**, and **Material 3 Belka expressive styling**. **gbios** brings all of these features to iOS in a native, privacy-first Swift & SwiftUI implementation.

---

## 📥 Unsigned IPA Releases

Every push to `main` automatically builds an unsigned iOS application package (`gbios-unsigned.ipa`) via GitHub Actions and publishes it directly to [**GitHub Releases**](https://github.com/benjamin-brinkerhoff/gbios/releases), ready to sideload with AltStore, SideStore, Feather, TrollStore, or LiveContainer.

---

## 🌟 Feature Comparison Matrix

| Feature | Stock iOS Keyboard | Official iOS Gboard | Android Gboard / PixelBoard / GboardWu | **gbios (This Project)** |
| :--- | :---: | :---: | :---: | :---: |
| **Built-In Gboard Translate Bar** | ❌ No | ⚠️ Discontinued/Limited | ✅ Yes (Live in-keyboard translation) | ✅ **Yes (13+ languages, live & field translate)** |
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

### 1. Built-In Gboard Translate (`TranslateView` & `TranslationService`)
- **In-Keyboard Translation Bar**: Tap the Translate icon in the top toolbar to open the Gboard Translate bar directly above the QWERTY keys so you can keep typing on the full keyboard while watching your text translate in real time.
- **13+ Supported Languages**: Auto-Detect, English, Spanish, French, German, Italian, Portuguese, Japanese, Korean, Chinese (Simplified & Traditional), Russian, Arabic, and Hindi.
- **One-Tap Language Swap & Field Translation**: Flip source and target languages instantaneously, or tap **Field** to translate existing text already typed into the host app's text field in place.
- **Hybrid Online + Offline Dictionary Fallback**: Uses live Google Translate endpoints when Full Access is active and falls back to an embedded offline phrase and word dictionary when offline.

### 2. Android-Style Key Popups & Secondary Symbols
- **Keycap Symbol Hints**: Every letter displays its secondary numeric or punctuation symbol (e.g. `q` -> `1`, `w` -> `2`, `a` -> `@`, `s` -> `#`).
- **Elevated Popup Bubbles**: Tapping or holding keys renders Android-style floating preview bubbles.
- **Accented Character Menus**: Long-pressing letters opens quick-selection accent drawers (e.g. `e` -> `é`, `è`, `ê`, `ë`, `ē`).

### 3. Comprehensive Clipboard Manager & Web Clipboard
- **In-Keyboard Clipboard Drawer**: Tap the clipboard icon to access recently copied clips.
- **Pinning System**: Pin frequent addresses, snippets, or code blocks so they are never purged.
- **Web Clipboard (Ported from Jason Wu's GboardWu)**:
  - Runs an embedded, low-latency local HTTP server on port `8088`.
  - Open `http://<iphone-ip>:8088` on any Mac, Windows, or Linux browser on the same Wi-Fi to view clipboard history or push text clips directly to the iPhone keyboard.

### 4. Gemini "Rambler" Natural Voice Dictation & AI Writing Tools
- **Speech Cleanup**: Automatically strips conversational filler words (*"um"*, *"uh"*, *"like"*, *"you know"*, *"ah"*) in real time.
- **Battery-Friendly Lifecycle**: Automatically releases speech and microphone audio taps as soon as dictation stops or keyboard hides.
- **AI Writing Assistant**: Drawer with 1-tap **Proofread**, **Tone Switcher** (*Professional*, *Casual*, *Concise*), and **Rephrase**.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.
