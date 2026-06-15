# How to Use AutoPixel · v1.1.1

AutoPixel is an **auto-mouse** that reproduces real manual actions by automating the mouse and keyboard.
It is a **completely separate program** from the Chrome extension (`wplace-2click`) and is self-contained in this single folder (you can move the whole folder anywhere).

Per-cell sequence: **move → `i` (color pick) → click 0.1s → wait 0.1s → click 0.1s**

**Two modes** (select with the rounded buttons at the top of the panel)
- **Line mode**: Evenly divides Start (P1) → End (P2) into N cells and fills a single line.
- **Rectangle mode**: With 3 points — P1 (top-left) → P2 (end of the same row) → P3 (a point in another row) — fills row by row, from the first row to the last.

> The **keycaps** in the panel turn green when you press the matching key, and **F4 (Run)** stays lit until the job finishes, so you can see which key / which task is active at a glance.
>
> Note: the on-screen panel text is in Korean; English translations are given in brackets in this guide.

---

## 1. Setup

1. Install **AutoHotkey v2** — direct download: https://www.autohotkey.com/download/ahk-v2.exe (must be **v2**).
2. Double-click **`AutoPixel-실행.bat`** in this folder → a panel appears at the top-left.
   - If it doesn't launch, run **`AutoPixel-진단.bat`** to diagnose.
   - To quit: right-click the green `H` tray icon → Exit / Reload after edits.

## 2. Hotkeys

| Key | Action |
|---|---|
| **F2** | Calibrate **P1 (start)** (rectangle: top-left cell) |
| **F3** | Calibrate **P2 (end)** — line: end cell / rectangle: **end of the same row** (top-right) |
| **F7** | Calibrate **P3 (other-row end)** — **rectangle mode only** (a cell in the last row) |
| **F8** | **Calibrate cell size** — click two adjacent cells in turn to learn the cell size → **auto-fills the count** |
| **F4** | **Run** |
| **Esc** or **F6** | **Stop** (only while running) |

> The same keys appear as **keycaps (3 columns × 2 rows)** at the top of the panel and highlight when pressed.

## 3. Panel Layout

- **Mode buttons** (rounded): `직선` (Line) / `사각형` (Rectangle) — click to switch (active = green).
- **Keycap row**: `F2 · F3 · F7 · F8 · F4 · Esc` — highlight when pressed.
- **Point indicators**: P1 / P2 / P3 — turn `●` green once calibrated.
- **Cell size** (`1칸 크기`): shows the F8 calibration result in px.
- **Settings**
  - **N** (`칸 수`) — line: number of cells from start to end / rectangle: cells per row (**auto-filled when calibrated**)
  - **Delay** (`딜레이`, ms) — gap between cells (default **50**)
  - **Jitter** (`지터`, %) — random ± applied to the delay to reduce regularity (default **25**)

## 4. Cell-size Calibration → Auto Count (recommended)

To avoid counting cells one by one on large drawings, calibrate the cell size **once**.

1. Hover a cell center and press **F8**.
2. Press **F8** again on the **adjacent cell** center. → the panel shows `1칸 크기: NNpx (보정됨)` (cell size NN px, calibrated).
3. From then on, **picking the start/end with F2/F3 auto-fills `N`** (you can still edit it manually).

> **If you change the zoom, the cell size changes — run F8 again.**
> You can also skip calibration and type `N` manually.

## 5. Line Mode

1. Select the **직선 (Line)** button.
2. (Recommended) Calibrate the cell size with **F8**.
3. Press **F2** on the first cell center, then **F3** on the last cell center → `N` auto-fills (type it manually if not calibrated).
4. **F4** to run / **Esc** to stop.

## 6. Rectangle Mode

1. Select the **사각형 (Rectangle)** button.
2. (Recommended) Calibrate the cell size with **F8**.
3. **P1**: press **F2** on the top-left (start) cell.
4. **P2**: press **F3** on the **last cell of the same row** (top-right) → the column count `N` auto-fills.
5. **P3**: press **F7** on a cell in the **last row** (only its row / vertical position matters; horizontal position is ignored).
6. **F4** to run → fills from the first row to the last, **left→right, top→bottom**.

> **The number of rows is computed automatically.** Because wplace pixels are square, the cell size is used to divide the vertical distance to P3 into rows.
> For your first try, test a small rectangle (e.g., N=3 wide, P3 two or three rows down) to check alignment, then scale up.

## 7. Notes

- Use it with **English (Latin) input active** — if a Korean IME is on, `i` may not trigger the color pick.
- **Do not touch the mouse or keyboard while it is running.**
- The **wplace window must be visible** before running (F4 activates the window at the start coordinate).
- It draws axis-aligned grids only; points are auto-snapped to the dominant axis even if slightly off.
- It consumes paint charges. Large rectangles use charges quickly — check `N` and the row count.
- **After changing zoom, re-do F8 (cell size) and F2/F3 (/F7).**
- Detection is usually based on speed/regularity, so don't set the delay too low and use jitter. You are solely responsible for your use.

## 8. Files

| File | Description |
|---|---|
| `AutoPixel.ahk` | Main script (line & rectangle modes, keycap UI) |
| `AutoPixel-실행.bat` | Double-click launcher (auto-detects AHK) |
| `AutoPixel-진단.bat` | Diagnostic helper |
| `How-to-use-AutoPixel.md` | This document (English) |
| `AutoPixel-사용법.md` | Usage guide (Korean) |
| `README.md` / `README-KR.md` | English / Korean overview |
| `privacy-policy.html` | Privacy policy (EN/KO toggle) |
| `logo.png` | Logo |

## 9. Tuning

Edit values directly in `AutoPixel.ahk`:
- Click timing: `Sleep 100` (0.1s click) in `PaintAt()`
- Color-pick ↔ click gaps: `Sleep 40`, `Sleep 60`
- Panel colors: the color constants near the top (`C_GREEN`, `C_KEY`, …)
