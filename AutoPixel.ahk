#Requires AutoHotkey v2.0
#SingleInstance Force
CoordMode "Mouse", "Screen"
SetMouseDelay 0

; ===========================================================
;  AutoPixel  —  wplace 자동 픽셀 (AutoHotkey)
;  실제 마우스/키보드를 자동 조작해 '수동 동작'을 그대로 재현합니다.
;  칸마다:  이동 → i(색상 인식) → 클릭 0.1s → 대기 0.1s → 클릭 0.1s
;
;  [직선]   P1 시작 → P2 끝.  N칸을 직선으로 채움.
;  [사각형] P1 좌상단 → P2 같은 행 끝 → P3 다른 행 끝.  가로 N + 자동 행수로 채움.
;
;   F2 시작 · F3 끝 · F7 다른행끝 · F8 1칸 보정 · F4 실행 · Esc/F6 정지
;   (F8로 인접 두 칸을 찍어 1칸 크기를 보정하면 F2/F3 선택 시 '칸 수'가 자동 계산됨)
;   패널의 키캡은 해당 키를 누르면 하이라이트됩니다.
; ===========================================================

; ---------- 전역 상태 ----------
S := { startX: "", startY: "", endX: "", endY: "", rectX: "", rectY: "", running: false, stop: false }
mode := "line"
pitch := 0
pcStep := 0
pcA := { x: 0, y: 0 }
kc := Map()             ; 키캡 컨트롤들

; ---------- 색상 ----------
C_GREEN := "2FB34D", C_GREENL := "5CE65C", C_SET := "B8E6B8"
C_DIM := "6E6E92", C_LABEL := "C8C8DC", C_YELLOW := "F2D94E"
C_KEY := "23234A", C_KEYTX := "D0D0E0"

; ---------- GUI ----------
g := Gui("+AlwaysOnTop +ToolWindow", "AutoPixel")
g.MarginX := 14
g.MarginY := 14
g.BackColor := "12121F"
g.SetFont("s9", "DotumChe")

; 헤더: 로고 + 타이틀
logoPath := A_ScriptDir "\logo.png"
if FileExist(logoPath)
    g.Add("Picture", "x14 y14 w50 h50", logoPath)
g.SetFont("s16 bold", "DotumChe")
g.Add("Text", "x74 y14 w224 h50 +0x200 c" C_GREENL, "AutoPixel")

; 구분선
g.SetFont("s9 norm", "DotumChe")
g.Add("Text", "x14 y72 w300 h3 Background" C_GREEN, "")

; 모드 버튼 (둥근 사각형)
g.SetFont("s10 bold", "DotumChe")
modeLineBtn := g.Add("Text", "xm y+12 w94 h34 Center +0x200 Background222238 c9A9ABF", "직선")
modeRectBtn := g.Add("Text", "x+10 yp w94 h34 Center +0x200 Background222238 c9A9ABF", "사각형")
modeLineBtn.OnEvent("Click", ModeLineClick)
modeRectBtn.OnEvent("Click", ModeRectClick)

; 키캡 (3열 × 2행, 누르면 하이라이트) — 한 줄 표기로 줄바꿈 글리프 문제 방지
g.SetFont("s9 norm", "DotumChe")
keyList := [["F2", "시작"], ["F3", "끝"], ["F7", "행끝"], ["F8", "1칸"], ["F4", "실행"], ["Esc", "정지"]]
for i, kd in keyList {
    idx := i - 1
    if (Mod(idx, 3) = 0)
        pos := (idx = 0) ? "xm y+12" : "xm y+6"
    else
        pos := "x+6 yp"
    cap := g.Add("Text", pos " w96 h34 Center +0x200 Background" C_KEY " c" C_KEYTX, kd[1] "  " kd[2])
    kc[kd[1]] := cap
}

g.Add("Text", "xm y+12 w300 h1 Background2A2A45", "")

; 좌표 / 보정 상태
g.SetFont("s9 norm", "DotumChe")
startLbl := g.Add("Text", "xm y+8 w300 c" C_DIM, "○ P1 시작     (미설정)")
endLbl   := g.Add("Text", "xm w300 c" C_DIM, "○ P2 끝(행)    (미설정)")
rectLbl  := g.Add("Text", "xm w300 c" C_DIM, "○ P3 다른행끝  (미설정)")
pitchLbl := g.Add("Text", "xm w300 c8FB7E6", "□ 1칸 크기: 미보정  (F8로 두 칸 보정)")

g.Add("Text", "xm y+8 w300 h1 Background2A2A45", "")

; 설정값
g.SetFont("s9 norm", "DotumChe")
g.Add("Text", "xm y+8 w118 +0x200 c" C_LABEL, "칸 수 N")
nEdit := g.Add("Edit", "x+8 yp w88", "10")
g.Add("Text", "xm w118 +0x200 c" C_LABEL, "딜레이 (ms)")
delayEdit := g.Add("Edit", "x+8 yp w88", "50")
g.Add("Text", "xm w118 +0x200 c" C_LABEL, "지터 (%)")
jitterEdit := g.Add("Edit", "x+8 yp w88", "25")

; 정지 버튼 (둥근, 클릭 가능)
g.SetFont("s10 bold", "DotumChe")
stopBtn := g.Add("Text", "xm y+13 w300 h30 Center +0x200 BackgroundB5302A cFFFFFF", "정지  (Esc / F6)")
stopBtn.OnEvent("Click", StopPaint)

; 상태
g.SetFont("s9 bold", "DotumChe")
statusText := g.Add("Text", "xm y+10 w300 c" C_YELLOW, "상태: 모드 선택 후 보정")

g.Show("x12 y12")
try DllCall("dwmapi\DwmSetWindowAttribute", "ptr", g.Hwnd, "int", 20, "int*", 1, "int", 4)

; 둥근 모서리 적용 + 초기 모드
RoundControl(modeLineBtn, 14)
RoundControl(modeRectBtn, 14)
RoundControl(stopBtn, 12)
for name, cap in kc
    RoundControl(cap, 8)
SetMode("line")

; ---------- 핫키 ----------
F2:: {
    KeyFlash("F2")
    CaptureStart()
}
F3:: {
    KeyFlash("F3")
    CaptureEnd()
}
F7:: {
    KeyFlash("F7")
    CaptureRect()
}
F8:: {
    KeyFlash("F8")
    CapturePitch()
}
F4::RunPaint()           ; F4 강조는 RunPaint가 직접 관리(실행 내내 ON)

#HotIf S.running
Esc:: {
    KeyFlash("Esc")
    StopPaint()
}
F6:: {
    KeyFlash("Esc")
    StopPaint()
}
#HotIf

; ---------- 키캡 하이라이트 ----------
KeyStyle(name, active) {
    global kc, C_GREEN, C_KEY, C_KEYTX
    if !kc.Has(name)
        return
    c := kc[name]
    c.Opt(active ? "Background" C_GREEN : "Background" C_KEY)
    c.SetFont(active ? "s9 c0C0C1A bold" : "s9 c" C_KEYTX " norm", "DotumChe")
}
KeyFlash(name) {
    KeyStyle(name, true)
    SetTimer(() => KeyStyle(name, false), -250)
}

; ---------- 모드 ----------
ModeLineClick(*) {
    SetMode("line")
}
ModeRectClick(*) {
    SetMode("rect")
}
SetMode(m) {
    global mode, modeLineBtn, modeRectBtn, statusText, S
    mode := m
    StyleModeBtn(modeLineBtn, m = "line")
    StyleModeBtn(modeRectBtn, m = "rect")
    if (!S.running)
        statusText.Text := (m = "line") ? "직선 모드 · F2/F3 보정" : "사각형 모드 · F2/F3/F7 보정"
}
StyleModeBtn(btn, active) {
    global C_GREEN
    btn.Opt(active ? "Background" C_GREEN : "Background222238")
    btn.SetFont(active ? "s10 c0C0C1A bold" : "s10 c9A9ABF norm", "DotumChe")
}

; ---------- 보정 ----------
CaptureStart(*) {
    global S, startLbl, statusText, C_SET
    MouseGetPos &x, &y
    S.startX := x, S.startY := y
    startLbl.Text := "● P1 시작     (" x ", " y ")"
    startLbl.SetFont("s9 c" C_SET, "DotumChe")
    statusText.Text := "P1 보정됨"
    ComputeAutoN()
}
CaptureEnd(*) {
    global S, endLbl, statusText, C_SET
    MouseGetPos &x, &y
    S.endX := x, S.endY := y
    endLbl.Text := "● P2 끝(행)    (" x ", " y ")"
    endLbl.SetFont("s9 c" C_SET, "DotumChe")
    statusText.Text := "P2 보정됨"
    ComputeAutoN()
}
CaptureRect(*) {
    global S, rectLbl, statusText, C_SET
    MouseGetPos &x, &y
    S.rectX := x, S.rectY := y
    rectLbl.Text := "● P3 다른행끝  (" x ", " y ")"
    rectLbl.SetFont("s9 c" C_SET, "DotumChe")
    statusText.Text := "P3 보정됨 → F4 실행"
}
CapturePitch(*) {
    global pcStep, pcA, pitch, pitchLbl, statusText, C_SET
    MouseGetPos &x, &y
    if (pcStep = 0) {
        pcA := { x: x, y: y }
        pcStep := 1
        statusText.Text := "1칸 보정: 바로 옆 칸에서 F8 한 번 더"
    } else {
        pcStep := 0
        d := Max(Abs(x - pcA.x), Abs(y - pcA.y))
        if (d > 0) {
            pitch := d
            pitchLbl.Text := "■ 1칸 크기: " pitch "px  (보정됨)"
            pitchLbl.SetFont("s9 c" C_SET, "DotumChe")
            ComputeAutoN()
            statusText.Text := "1칸 ≈ " pitch "px · 칸 수 자동 계산"
        } else {
            statusText.Text := "두 점이 같습니다 · 다시 F8"
        }
    }
}
ComputeAutoN() {
    global S, pitch, nEdit
    if (pitch <= 0 || S.startX = "" || S.endX = "")
        return
    d := Max(Abs(S.endX - S.startX), Abs(S.endY - S.startY))
    n := Round(d / pitch) + 1
    if (n < 1)
        n := 1
    nEdit.Value := n
}

StopPaint(*) {
    global S
    if (S.running)
        S.stop := true
}

; ---------- 유틸 ----------
ToInt(str, def) {
    return IsNumber(str) ? Integer(str) : def
}
SleepDelay(delay, jit) {
    w := delay
    if (jit > 0)
        w := delay + delay * Random(-jit, jit) / 100
    if (w < 0)
        w := 0
    Sleep Round(w)
}
RoundControl(ctrl, r) {
    rc := Buffer(16, 0)
    DllCall("User32\GetClientRect", "ptr", ctrl.Hwnd, "ptr", rc)
    cw := NumGet(rc, 8, "int"), ch := NumGet(rc, 12, "int")
    rgn := DllCall("Gdi32\CreateRoundRectRgn", "int", 0, "int", 0, "int", cw + 1, "int", ch + 1, "int", r, "int", r, "ptr")
    DllCall("User32\SetWindowRgn", "ptr", ctrl.Hwnd, "ptr", rgn, "int", 1)
}
PaintAt(x, y) {
    MouseMove x, y, 0
    Sleep 40
    Send "i"
    Sleep 60
    Click "Down"
    Sleep 100
    Click "Up"
    Sleep 100
    Click "Down"
    Sleep 100
    Click "Up"
}

; ---------- 실행 ----------
RunPaint(*) {
    global S, nEdit, delayEdit, jitterEdit, statusText, mode, C_YELLOW
    if (S.running)
        return
    KeyStyle("F4", true)        ; 실행 키 강조 (작업 내내 ON)
    try {
        N := ToInt(nEdit.Text, 1)
        if (N < 1)
            N := 1
        delay := ToInt(delayEdit.Text, 50)
        jit := ToInt(jitterEdit.Text, 0)
        rect := (mode = "rect")

        if (S.startX = "" || S.endX = "") {
            statusText.Text := "먼저 F2(시작), F3(끝)으로 보정하세요"
            return
        }

        if (rect) {
            ; ===== 사각형 모드 =====
            if (S.rectX = "") {
                statusText.Text := "사각형: F7(다른 행 끝)도 보정하세요"
                return
            }
            if (N < 2) {
                statusText.Text := "사각형은 가로 칸 수(N) 2 이상 (F8 보정 권장)"
                return
            }

            p1x := S.startX, p1y := S.startY
            dx := S.endX - p1x, dy := S.endY - p1y

            if (Abs(dx) >= Abs(dy)) {
                colStepX := dx / (N - 1), colStepY := 0
                p := Abs(colStepX)
                rowStepX := 0
                rowStepY := (S.rectY >= p1y ? 1 : -1) * p
                rows := (p > 0) ? Round(Abs(S.rectY - p1y) / p) + 1 : 1
            } else {
                colStepX := 0, colStepY := dy / (N - 1)
                p := Abs(colStepY)
                rowStepY := 0
                rowStepX := (S.rectX >= p1x ? 1 : -1) * p
                rows := (p > 0) ? Round(Abs(S.rectX - p1x) / p) + 1 : 1
            }

            if (p = 0) {
                statusText.Text := "P1과 P2가 같은 위치입니다 (다시 보정)"
                return
            }
            if (rows < 1)
                rows := 1

            total := rows * N
            ActivateAt(p1x, p1y)
            Sleep 120
            S.running := true, S.stop := false
            statusText.SetFont("s9 bold cFF3B3B", "DotumChe")

            k := 0
            Loop rows {
                if (S.stop)
                    break
                r := A_Index - 1
                Loop N {
                    if (S.stop)
                        break
                    c := A_Index - 1
                    px := Round(p1x + c * colStepX + r * rowStepX)
                    py := Round(p1y + c * colStepY + r * rowStepY)
                    k += 1
                    statusText.Text := "사각형 " N "x" rows "  " k " / " total
                    PaintAt(px, py)
                    if (k < total && !S.stop)
                        SleepDelay(delay, jit)
                }
            }
        } else {
            ; ===== 직선 모드 =====
            sx := S.startX, sy := S.startY
            ex := S.endX, ey := S.endY
            if (Abs(ex - sx) >= Abs(ey - sy))
                ey := sy
            else
                ex := sx

            ActivateAt(sx, sy)
            Sleep 120
            S.running := true, S.stop := false
            statusText.SetFont("s9 bold cFF3B3B", "DotumChe")

            Loop N {
                if (S.stop)
                    break
                i := A_Index - 1
                if (N = 1) {
                    px := sx, py := sy
                } else {
                    px := Round(sx + (ex - sx) * i / (N - 1))
                    py := Round(sy + (ey - sy) * i / (N - 1))
                }
                statusText.Text := "직선  " A_Index " / " N
                PaintAt(px, py)
                if (A_Index < N && !S.stop)
                    SleepDelay(delay, jit)
            }
        }

        statusText.SetFont("s9 bold c" C_YELLOW, "DotumChe")
        statusText.Text := S.stop ? "정지됨." : "완료"
    } finally {
        S.running := false
        KeyStyle("F4", false)
    }
}

ActivateAt(x, y) {
    lParam := ((y & 0xFFFFFFFF) << 32) | (x & 0xFFFFFFFF)
    hwnd := DllCall("WindowFromPoint", "int64", lParam, "ptr")
    if (hwnd) {
        root := DllCall("GetAncestor", "ptr", hwnd, "uint", 2, "ptr")
        if (root)
            try WinActivate("ahk_id " root)
    }
}
