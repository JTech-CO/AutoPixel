# AutoPixel

**English** | [한국어](#) <!-- replace # with the README-KR link after deployment -->

> **A Windows auto-mouse (AutoHotkey) that automatically draws pixel art on wplace.live as lines and rectangles.**

## 1. Introduction

AutoPixel is an **AutoHotkey-based auto-mouse** built to automate the repetitive task of placing pixels along a guideline on [wplace.live](https://wplace.live/). It faithfully reproduces real mouse/keyboard actions (move → `i` color pick → click), performing the same steps a person would do by hand.

**Features**
- **Line mode**: Pick a start and end point; the span is evenly divided into N cells and a single line is filled automatically.
- **Rectangle mode**: Pick 3 points (start / end of the same row / a point in another row) to fill a rectangular area row by row (the number of rows is computed automatically).
- **Auto cell-count**: Calibrate the cell size once with `F8` (mark two adjacent cells); afterward the count `N` fills in automatically when you pick the start/end — no counting cells for large drawings.
- **Pixel-art UI**: Dark theme, pixel logo, and on-screen **keycaps that highlight when you press a key** (and stay lit while running) so you can see what's happening.
- **Delay & jitter** controls to tune speed and reduce regularity.

## 2. Tech Stack

- **Platform**: Windows
- **Runtime**: AutoHotkey v2
- **Language**: AutoHotkey v2 Script
- **Automation**: Real mouse/keyboard input simulation (auto-mouse)
- **Dependencies / Network**: None (runs entirely locally)

## 3. Quick Start

**Requirements**: Windows + [AutoHotkey v2](https://www.autohotkey.com/download/ahk-v2.exe)

1. **Install**
   - Install **AutoHotkey v2** — direct download: https://www.autohotkey.com/download/ahk-v2.exe
   - Download or clone this repository.
   ```bash
   git clone <repository-url>
   ```

2. **Run**
   - Double-click `AutoPixel-실행.bat` (or run `AutoPixel.ahk` directly).
   - A panel appears at the top-left when it is ready.

3. **Usage**
   - **(Once) Calibrate cell size**: press `F8` over a cell, then `F8` over the adjacent cell. The cell size is learned and `N` auto-fills afterward. (Re-do after changing zoom.)
   - **Line mode**: `F2` (start) → `F3` (end) → `F4` to run
   - **Rectangle mode**: `F2` (top-left) → `F3` (end of the same row) → `F7` (a point in another row) → `F4` to run
   - **Stop**: `Esc` or `F6`
   - `N` (line cells / rectangle columns) fills automatically once calibrated; you can still edit it manually. Defaults: delay `50` ms, jitter `25` %.
   - See [`How-to-use-AutoPixel.md`](How-to-use-AutoPixel.md) (English) or [`AutoPixel-사용법.md`](AutoPixel-사용법.md) (Korean) for the detailed guide.

## 4. Structure

```text
AutoPixel/
├── AutoPixel.ahk         # Main script (line & rectangle modes)
├── AutoPixel-실행.bat     # Double-click launcher (auto-detects AHK)
├── AutoPixel-진단.bat     # Diagnostic helper
├── How-to-use-AutoPixel.md # Detailed guide (English)
├── AutoPixel-사용법.md    # Detailed guide (Korean)
├── logo.png              # Icon / logo
├── privacy-policy.html   # Privacy policy (EN / KO toggle)
├── README.md             # English (this file)
└── README-KR.md          # Korean
```

## 5. Info

- **Version**: 1.1.0
- **License**: MIT
- **Privacy**: [privacy-policy.html](privacy-policy.html) — collects/transmits no data (local only)
- **Contact**: GitHub Issues

## ⚠️ Disclaimer

- AutoPixel is an **auto-mouse** that automates mouse/keyboard input. wplace may restrict automation, and **you are solely responsible** for any consequences (e.g., account bans).
- Use it only within **your own account and your own paint charges**. Do not set the delay too low (use jitter).
- This tool is provided for personal/educational use; the author is not responsible for misuse.
