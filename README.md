# AutoPixel

**English** | [한국어](#) <!-- replace # with the README-KR link after deployment -->

> **A Windows auto-mouse (AutoHotkey) that automatically draws pixel art on wplace.live as lines and rectangles.**

## 1. Introduction

AutoPixel is an **AutoHotkey-based auto-mouse** built to automate the repetitive task of placing pixels along a guideline on [wplace.live](https://wplace.live/). It faithfully reproduces real mouse/keyboard actions (move → `i` color pick → click), performing the same steps a person would do by hand.

**Features**
- **Line mode**: Pick a start and end point; the span is evenly divided into N cells and a single line is filled automatically.
- **Rectangle mode**: Pick 3 points (start / end of the same row / a point in another row) to fill a rectangular area row by row (the number of rows is computed automatically).
- **Pixel-art UI**: Dark theme + pixel logo + retro font (readability first).
- **Delay & jitter** controls to tune speed and reduce regularity.

## 2. Tech Stack

- **Platform**: Windows
- **Runtime**: AutoHotkey v2
- **Language**: AutoHotkey v2 Script
- **Automation**: Real mouse/keyboard input simulation (auto-mouse)
- **Dependencies / Network**: None (runs entirely locally)

## 3. Quick Start

**Requirements**: Windows + [AutoHotkey v2](https://www.autohotkey.com)

1. **Install**
   - Install AutoHotkey **v2**.
   - Download or clone this repository.
   ```bash
   git clone <repository-url>
   ```

2. **Run**
   - Double-click `AutoPixel-실행.bat` (or run `AutoPixel.ahk` directly).
   - A panel appears at the top-left when it is ready.

3. **Usage**
   - **Line mode**: `F2` (start) → `F3` (end) → enter `N (cells)` → `F4` to run
   - **Rectangle mode**: `F2` (top-left) → `F3` (end of the same row) → `F7` (a point in another row) → enter `N (columns)` → `F4` to run
   - **Stop**: `Esc` or `F6`
   - See [`AutoPixel-사용법.md`](AutoPixel-사용법.md) for the detailed guide (Korean).

## 4. Structure

```text
AutoPixel/
├── AutoPixel.ahk         # Main script (line & rectangle modes)
├── AutoPixel-실행.bat     # Double-click launcher (auto-detects AHK)
├── AutoPixel-진단.bat     # Diagnostic helper
├── AutoPixel-사용법.md    # Detailed guide (Korean)
├── logo.png              # Icon / logo
├── privacy-policy.html   # Privacy policy (EN / KO toggle)
├── README.md             # English (this file)
└── README-KR.md          # Korean
```

## 5. Info

- **License**: MIT
- **Privacy**: [privacy-policy.html](privacy-policy.html) — collects/transmits no data (local only)
- **Contact**: GitHub Issues

## ⚠️ Disclaimer

- AutoPixel is an **auto-mouse** that automates mouse/keyboard input. wplace may restrict automation, and **you are solely responsible** for any consequences (e.g., account bans).
- Use it only within **your own account and your own paint charges**. Do not set the delay too low (use jitter).
- This tool is provided for personal/educational use; the author is not responsible for misuse.
