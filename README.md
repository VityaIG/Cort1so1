# Cort1so1 Simulator

<p align="center">
  <img src="Cort1so1/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png" width="128" height="128" alt="Cort1so1 Logo" style="border-radius:22%" />
</p>

<h3 align="center">Advanced iOS Environment Simulator & Downgrade Engine</h3>

<p align="center">
  <a href="https://github.com/VityaIG/Cort1so1/actions"><img src="https://github.com/VityaIG/Cort1so1/actions/workflows/build.yml/badge.svg?label=Build%20IPA" alt="Build Status" /></a>
  <a href="https://t.me/VityaV"><img src="https://img.shields.io/badge/Telegram-@VityaV-229ED9?style=flat-square&logo=telegram" alt="Telegram" /></a>
  <img src="https://img.shields.io/badge/iOS-15.0+-black?style=flat-square&logo=apple" alt="iOS Support" />
  <img src="https://img.shields.io/badge/Swift-5.9%20%7C%20SwiftUI-F05138?style=flat-square&logo=swift" alt="Swift" />
</p>

---

## About the Project

**Cort1so1** is a native iOS application that combines an interactive jailbreak simulation in the style of Dopamine v2, a dynamic system tweak management module **Substrate Tweak Engine** (which appears only after activation), and a highly accurate iOS firmware downgrade simulation engine.
The interface is designed strictly according to **Apple Human Interface Guidelines (HIG)** with support for English and Russian localization, light/dark modes, custom accent colors (App Theme Picker), and smooth animations. No unnecessary gradients — strict, native style.

---

## What's New in Release 1.3

- **Cortisol Terminal Tab**:
  - Unlocked and visible **only** when the user selects and executes the `"Cortisol"` jailbreak method (remains hidden for the legacy `"Dopamine"` method).
  - Integrated command line interface with instant command autocomplete chips and console log history.
  - Dedicated hint: `Example: "battery color set orange" or "battery percentage set 100"`.
  - Commands support:
    - `help` (interactive command reference)
    - `createpopup <text> <button>` (trigger custom native iOS popup dialogs, e.g. `createpopup Hello OK` or `createpopup "Custom text" "Dismiss"`)
    - `battery color set <color>` (orange, red, green, blue, purple, cyan, #hex, etc.)
    - `battery percentage set <val>` (0–100%)
    - `battery reset` (revert to real system device battery readings)
    - `statusbar show` / `statusbar hide`
    - `whoami`, `uname -a`, `clear`
- **Dynamic iOS Status Bar Overlay Engine**:
  - Live system clock in `HH:mm` updating continuously every second.
  - Queries device's real battery level (`UIDevice.current.batteryLevel`) by default.
  - Dynamically updates numerical percentage and battery icon fill width when modified via terminal commands.
  - Dynamic battery fill color styling with automatic `.statusBarHidden(true)` activation.
- **Tab & Localization Updates**:
  - Renamed the `"iOS Downgrade"` tab strictly to `"iOS"` in the English localization (Russian `"Откат iOS"` preserved).
- **Bundle ID & Project Settings**:
  - Updated Bundle Identifier to `com.vitya.cort1so1`.
  - Updated Marketing Version to `1.3` (Build `27`).

---

## Key Features

### 1. Simulation Engine (Dopamine Process Experience)
- **3-Phase Execution Cycle**:
  - `Phase 1`: Kernel initialization, offset checks, and compatibility.
  - `Phase 2`: Stability verification and PPL/PAC bypass.
  - `Phase 3`: Bootloop probability check and environment preparation.
- **Accurate Timings & Kinematics**:
  - Logs appear from bottom to top with status animations `[X/7]`, chat-like behavior, and `UIFeedbackGenerator` haptics.
  - White Apple logo appearance.
  - **Exactly 1.0 second** of pure black screen (`blackScreen`).
  - Red Apple logo appearance (kfd/tfp0 initialization). No gradients.
  - Native SpringBoard respring screen with a spinner transitioning to an active status.
- **Cort1so1 Installer**: A native built-in package manager `Cort1so1 Installer` is used instead of Sileo.

### 2. 60-Second Downgrade Engine ("iOS Downgrade")
- **IPSW Firmware Catalog**: Current iOS versions 26.6, 26.0, 18.7.1, and 18.5 with Apple TSS Signed / SHSH2 blobs status.
- **Exactly 1 minute of execution (00:00 → 01:00)** with dynamic calculation of progress, transferred data (GB), and speed (MB/s).
- **5 Detailed Restore Stages**:
  1. `0s – 10s`: **TSS & ApTicket** (requesting gs.apple.com and validating ApTicket).
  2. `10s – 25s`: **RootFS & Cryptex1 OS** (mounting system DMG `disk0s1s1`, verifying TrustCache).
  3. `25s – 40s`: **SEP & Baseband Microcode** (sending signed Secure Enclave microcode).
  4. `40s – 52s`: **APFS Snapshot & KernelCache** (creating `com.apple.os.update` snapshot).
  5. `52s – 60s`: **NVRAM, boot-args & SHA-256** (finalization and reboot preparation).
- **Interactive Futurerestore Terminal**: Real-time output of actual console logs.

### 3. Apple HIG Native Settings
- **Profile & Branding**: New signature app icon with a centered "C". Selectable app accent colors (App Theme Picker).
- **Developer Card**: Direct link to the project author **[@VityaV](https://t.me/VityaV)** on Telegram.
- **Appearance & Language**: Quick localization switching (English / Russian).
- **Utility Parameters**: Detailed kernel logs, auto-respring, Substrate/ElleKit tweak injection, and Safe Mode. Highly polished UI (Tweaks UI).
- **Danger Zone**: Safe reset function (`Restore RootFS`).

---

## Architecture & File Structure

```
Cort1so1/
├── .github/
│   └── workflows/
│       └── build.yml               # CI/CD: macOS IPA build and auto-release
├── Cort1so1/
│   ├── Assets.xcassets/            # Assets catalog (AppIcon 1024x1024, AccentColor)
│   ├── icon.svg                    # Master vector icon with centered "C"
│   ├── Cort1so1App.swift           # Main app entry point (@main)
│   ├── ContentView.swift           # Root navigation coordinator and TabView
│   ├── MainView.swift              # Main utility screen
│   ├── DopamineProcessView.swift   # Process screen with animations (bottom-up logs)
│   ├── DowngradeView.swift          # 60-second firmware downgrade engine
│   ├── SettingsView.swift          # Apple HIG style settings screen
│   ├── LocalizationManager.swift   # Bilingual localization manager (EN / RU)
│   ├── SimulationModels.swift      # Data models, color themes (AppTheme), state types
│   ├── LogData.swift               # Kernel logs and message structures
│   ├── LogStreamView.swift         # Terminal logger with chat-like behavior
│   ├── NeoSpringView.swift         # SpringBoard respring simulation overlay
│   ├── TerminalView.swift          # Cortisol terminal subsystem & custom status bar overlay
│   ├── TweaksView.swift            # System tweaks management interface
│   └── Info.plist                  # System app manifest
├── Cort1so1.xcodeproj/             # Xcode project configuration
└── README.md
```

---

## Installation

The pre-compiled `.ipa` file is available in the [Releases](https://github.com/VityaIG/Cort1so1/releases/latest) section.
You can install the app using any convenient method:

1. **TrollStore** *(recommended for supported iOS versions without the need for 7-day resigning)*.
2. **AltStore / SideStore** (via Apple ID account).
3. **Sideloadly / Scarlet / 3uTools** (directly from a computer).

---

## Build from Source

### Requirements
- macOS 14.0+
- Xcode 15.0+
- iOS 15.0+ Deployment Target

```bash
# Clone the repository
git clone https://github.com/VityaIG/Cort1so1.git
cd Cort1so1

# Open in Xcode
open Cort1so1.xcodeproj
```

---

## Author & Contacts

- **Developer**: [Viktor (@VityaV)](https://t.me/VityaV)
- **Telegram Channel / Contact**: [@VityaV](https://t.me/VityaV)
- **GitHub**: [@VityaIG](https://github.com/VityaIG)

---

## Disclaimer

*The **Cort1so1** app is a simulator and demonstration project. The application contains no malicious code, does not modify the real system partitions of your device without your knowledge, and was created for educational and aesthetic purposes.*
