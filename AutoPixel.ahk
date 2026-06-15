#Requires AutoHotkey v2.0
#SingleInstance Force
CoordMode "Mouse", "Screen"
SetMouseDelay 0

; ===========================================================
;  AutoPixel — wplace auto-pixel (AutoHotkey)
;  실제 마우스/키보드를 자동 조작해 수동 동작을 그대로 재현합니다.
;  칸마다: 이동 → i(색상 인식) → 클릭 0.1s → 대기 0.1s → 클릭 0.1s
;
;  우측 상단 버튼으로 한/영(KO/EN) 전환. 기본 영문. 실행 중에는 전환 불가.
;  F2 시작 · F3 끝 · F7 다른행끝 · F8 1칸 보정 · F4 실행 · Esc/F6 정지
; ===========================================================

; ---------- 전역 상태 ----------
S := { startX: "", startY: "", endX: "", endY: "", rectX: "", rectY: "", running: false, stop: false }
mode := "line"
pitch := 0
pcStep := 0
pcA := { x: 0, y: 0 }
kc := Map()
lang := "en"                 ; 기본 영문
curStatusKey := "st_init"
curStatusArg := ""

; ---------- 색상 ----------
C_GREEN := "2FB34D", C_GREENL := "5CE65C", C_SET := "B8E6B8"
C_DIM := "6E6E92", C_LABEL := "C8C8DC", C_YELLOW := "F2D94E"
C_KEY := "23234A", C_KEYTX := "D0D0E0"

; ---------- 번역 테이블 ----------
TX := Map(
    "m_line",        Map("en", "Line", "ko", "직선"),
    "m_rect",        Map("en", "Rect", "ko", "사각형"),
    "k_start",       Map("en", "Start", "ko", "시작"),
    "k_end",         Map("en", "End", "ko", "끝"),
    "k_rowend",      Map("en", "RowEnd", "ko", "행끝"),
    "k_cell",        Map("en", "Cell", "ko", "1칸"),
    "k_run",         Map("en", "Run", "ko", "실행"),
    "k_stop",        Map("en", "Stop", "ko", "정지"),
    "p_start",       Map("en", "Start", "ko", "시작"),
    "p_end",         Map("en", "End(row)", "ko", "끝(행)"),
    "p_rowend",      Map("en", "RowEnd", "ko", "다른행끝"),
    "none",          Map("en", "not set", "ko", "미설정"),
    "cellsize",      Map("en", "Cell size", "ko", "1칸 크기"),
    "notset",        Map("en", "not set", "ko", "미보정"),
    "set",           Map("en", "set", "ko", "보정됨"),
    "cellhint",      Map("en", "F8: two cells", "ko", "F8로 두 칸 보정"),
    "s_count",       Map("en", "Count N", "ko", "칸 수 N"),
    "s_delay",       Map("en", "Delay (ms)", "ko", "딜레이 (ms)"),
    "s_jitter",      Map("en", "Jitter (%)", "ko", "지터 (%)"),
    "b_stop",        Map("en", "Stop  (Esc / F6)", "ko", "정지  (Esc / F6)"),
    "st_init",       Map("en", "Pick a mode, then calibrate", "ko", "모드 선택 후 보정"),
    "st_mode_line",  Map("en", "Line mode · F2/F3", "ko", "직선 모드 · F2/F3"),
    "st_mode_rect",  Map("en", "Rectangle mode · F2/F3/F7", "ko", "사각형 모드 · F2/F3/F7"),
    "st_p1",         Map("en", "P1 set", "ko", "P1 보정됨"),
    "st_p2",         Map("en", "P2 set", "ko", "P2 보정됨"),
    "st_p3",         Map("en", "P3 set → F4 to run", "ko", "P3 보정됨 → F4 실행"),
    "st_pitch_step2",Map("en", "Cell calib: F8 on the next cell", "ko", "1칸 보정: 옆 칸에서 F8 한 번 더"),
    "st_pitch_same", Map("en", "Same point · press F8 again", "ko", "두 점이 같음 · 다시 F8"),
    "st_need_se",    Map("en", "Set F2 (start) & F3 (end) first", "ko", "먼저 F2(시작)·F3(끝) 보정"),
    "st_need_p3",    Map("en", "Rectangle: also set F7 (row end)", "ko", "사각형: F7(다른행끝)도 보정"),
    "st_need_n2",    Map("en", "Rectangle needs N >= 2 (use F8)", "ko", "사각형은 N >= 2 (F8 권장)"),
    "st_same_p12",   Map("en", "P1 and P2 are identical (recalibrate)", "ko", "P1·P2 위치 같음 (다시 보정)"),
    "st_stopped",    Map("en", "Stopped.", "ko", "정지됨."),
    "st_done",       Map("en", "Done", "ko", "완료")
)

; ---------- GUI ----------
g := Gui("+AlwaysOnTop +ToolWindow", "AutoPixel")
g.MarginX := 14
g.MarginY := 14
g.BackColor := "12121F"
g.SetFont("s9", "DotumChe")

; 헤더: 로고 + 타이틀(AutoPixel, 고정) + 언어 토글
logoPath := A_ScriptDir "\logo.png"
if FileExist(logoPath)
    g.Add("Picture", "x14 y14 w50 h50", logoPath)
g.SetFont("s16 bold", "DotumChe")
g.Add("Text", "x74 y14 w160 h50 +0x200 c" C_GREENL, "AutoPixel")
g.SetFont("s9 bold", "DotumChe")
langBtn := g.Add("Text", "x244 y22 w62 h26 Center +0x200 Background222238 cC8C8DC", "한국어")
langBtn.OnEvent("Click", LangToggle)

; 구분선
g.SetFont("s9 norm", "DotumChe")
g.Add("Text", "x14 y72 w300 h3 Background" C_GREEN, "")

; 모드 버튼 (둥근 사각형)
g.SetFont("s10 bold", "DotumChe")
modeLineBtn := g.Add("Text", "xm y+12 w94 h34 Center +0x200 Background222238 c9A9ABF", "Line")
modeRectBtn := g.Add("Text", "x+10 yp w94 h34 Center +0x200 Background222238 c9A9ABF", "Rect")
modeLineBtn.OnEvent("Click", ModeLineClick)
modeRectBtn.OnEvent("Click", ModeRectClick)

; 키캡 (3열 × 2행)
g.SetFont("s9 norm", "DotumChe")
keyList := [["F2", "k_start"], ["F3", "k_end"], ["F7", "k_rowend"], ["F8", "k_cell"], ["F4", "k_run"], ["Esc", "k_stop"]]
for i, kd in keyList {
    idx := i - 1
    if (Mod(idx, 3) = 0)
        pos := (idx = 0) ? "xm y+12" : "xm y+6"
    else
        pos := "x+6 yp"
    cap := g.Add("Text", pos " w96 h34 Center +0x200 Background" C_KEY " c" C_KEYTX, kd[1] "  " T(kd[2]))
    kc[kd[1]] := cap
}

g.Add("Text", "xm y+12 w300 h1 Background2A2A45", "")

; 좌표 / 보정 상태
g.SetFont("s9 norm", "DotumChe")
startLbl := g.Add("Text", "xm y+8 w300 c" C_DIM, "P1")
endLbl   := g.Add("Text", "xm w300 c" C_DIM, "P2")
rectLbl  := g.Add("Text", "xm w300 c" C_DIM, "P3")
pitchLbl := g.Add("Text", "xm w300 c8FB7E6", "cell")

g.Add("Text", "xm y+8 w300 h1 Background2A2A45", "")

; 설정값
g.SetFont("s9 norm", "DotumChe")
lblCount := g.Add("Text", "xm y+8 w118 +0x200 c" C_LABEL, "Count N")
nEdit := g.Add("Edit", "x+8 yp w88", "10")
lblDelay := g.Add("Text", "xm w118 +0x200 c" C_LABEL, "Delay (ms)")
delayEdit := g.Add("Edit", "x+8 yp w88", "50")
lblJitter := g.Add("Text", "xm w118 +0x200 c" C_LABEL, "Jitter (%)")
jitterEdit := g.Add("Edit", "x+8 yp w88", "25")

; 정지 버튼
g.SetFont("s10 bold", "DotumChe")
stopBtn := g.Add("Text", "xm y+13 w300 h30 Center +0x200 BackgroundB5302A cFFFFFF", "Stop  (Esc / F6)")
stopBtn.OnEvent("Click", StopPaint)

; 상태
g.SetFont("s9 bold", "DotumChe")
statusText := g.Add("Text", "xm y+10 w300 c" C_YELLOW, "")

; 초기 모드/언어 적용 (Show 이전 → 깜빡임 방지)
SetMode("line")
ApplyLang()

g.Show("x12 y12")
try DllCall("dwmapi\DwmSetWindowAttribute", "ptr", g.Hwnd, "int", 20, "int*", 1, "int", 4)

; 둥근 모서리 (Show 이후: 실제 크기 필요)
RoundControl(langBtn, 12)
RoundControl(modeLineBtn, 14)
RoundControl(modeRectBtn, 14)
RoundControl(stopBtn, 12)
for name, cap in kc
    RoundControl(cap, 8)

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
F4::RunPaint()

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

; ---------- 번역 / 언어 ----------
T(key) {
    global TX, lang
    return TX.Has(key) ? TX[key][lang] : key
}
LangToggle(*) {
    global S, lang
    if (S.running)              ; 작업 중에는 전환 불가
        return
    lang := (lang = "en") ? "ko" : "en"
    ApplyLang()
}
ApplyLang() {
    global lang, modeLineBtn, modeRectBtn, keyList, kc, lblCount, lblDelay, lblJitter, stopBtn, langBtn
    modeLineBtn.Text := T("m_line")
    modeRectBtn.Text := T("m_rect")
    for kd in keyList
        kc[kd[1]].Text := kd[1] "  " T(kd[2])
    lblCount.Text := T("s_count")
    lblDelay.Text := T("s_delay")
    lblJitter.Text := T("s_jitter")
    stopBtn.Text := T("b_stop")
    langBtn.Text := (lang = "en") ? "한국어" : "ENG"
    RenderPoints()
    RenderPitch()
    RenderStatus()
}
StyleLangBtn(enabled) {
    global langBtn
    langBtn.Opt(enabled ? "Background222238" : "Background17172A")
    langBtn.SetFont(enabled ? "s9 bold cC8C8DC" : "s9 bold c505068", "DotumChe")
}

; ---------- 상태 / 렌더 ----------
SetStatus(key, arg := "") {
    global curStatusKey, curStatusArg
    curStatusKey := key, curStatusArg := arg
    RenderStatus()
}
RenderStatus() {
    global curStatusKey, curStatusArg, statusText, lang
    if (curStatusKey = "st_pitch_done")
        statusText.Text := (lang = "en") ? ("Cell ~ " curStatusArg "px · auto count") : ("1칸 ≈ " curStatusArg "px · 칸 수 자동")
    else
        statusText.Text := T(curStatusKey)
}
RenderPoints() {
    global S, startLbl, endLbl, rectLbl
    RenderOnePoint(startLbl, "P1", T("p_start"),  S.startX, S.startY)
    RenderOnePoint(endLbl,   "P2", T("p_end"),    S.endX,   S.endY)
    RenderOnePoint(rectLbl,  "P3", T("p_rowend"), S.rectX,  S.rectY)
}
RenderOnePoint(lbl, tag, name, x, y) {
    global C_SET, C_DIM
    if (x = "") {
        lbl.Text := "○ " tag " " name "  (" T("none") ")"
        lbl.SetFont("s9 c" C_DIM, "DotumChe")
    } else {
        lbl.Text := "● " tag " " name "  (" x ", " y ")"
        lbl.SetFont("s9 c" C_SET, "DotumChe")
    }
}
RenderPitch() {
    global pitch, pitchLbl, C_SET
    if (pitch > 0) {
        pitchLbl.Text := "■ " T("cellsize") ": " pitch "px  (" T("set") ")"
        pitchLbl.SetFont("s9 c" C_SET, "DotumChe")
    } else {
        pitchLbl.Text := "□ " T("cellsize") ": " T("notset") "  (" T("cellhint") ")"
        pitchLbl.SetFont("s9 c8FB7E6", "DotumChe")
    }
}

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
    global mode, modeLineBtn, modeRectBtn, S
    mode := m
    StyleModeBtn(modeLineBtn, m = "line")
    StyleModeBtn(modeRectBtn, m = "rect")
    if (!S.running)
        SetStatus(m = "line" ? "st_mode_line" : "st_mode_rect")
}
StyleModeBtn(btn, active) {
    global C_GREEN
    btn.Opt(active ? "Background" C_GREEN : "Background222238")
    btn.SetFont(active ? "s10 c0C0C1A bold" : "s10 c9A9ABF norm", "DotumChe")
}

; ---------- 보정 ----------
CaptureStart(*) {
    global S
    MouseGetPos &x, &y
    S.startX := x, S.startY := y
    RenderPoints()
    SetStatus("st_p1")
    ComputeAutoN()
}
CaptureEnd(*) {
    global S
    MouseGetPos &x, &y
    S.endX := x, S.endY := y
    RenderPoints()
    SetStatus("st_p2")
    ComputeAutoN()
}
CaptureRect(*) {
    global S
    MouseGetPos &x, &y
    S.rectX := x, S.rectY := y
    RenderPoints()
    SetStatus("st_p3")
}
CapturePitch(*) {
    global pcStep, pcA, pitch
    MouseGetPos &x, &y
    if (pcStep = 0) {
        pcA := { x: x, y: y }
        pcStep := 1
        SetStatus("st_pitch_step2")
    } else {
        pcStep := 0
        d := Max(Abs(x - pcA.x), Abs(y - pcA.y))
        if (d > 0) {
            pitch := d
            RenderPitch()
            ComputeAutoN()
            SetStatus("st_pitch_done", pitch)
        } else {
            SetStatus("st_pitch_same")
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
    global S, nEdit, delayEdit, jitterEdit, statusText, mode, lang, C_YELLOW
    if (S.running)
        return
    KeyStyle("F4", true)
    ran := false
    try {
        N := ToInt(nEdit.Text, 1)
        if (N < 1)
            N := 1
        delay := ToInt(delayEdit.Text, 50)
        jit := ToInt(jitterEdit.Text, 0)
        rect := (mode = "rect")

        if (S.startX = "" || S.endX = "") {
            SetStatus("st_need_se")
            return
        }

        if (rect) {
            if (S.rectX = "") {
                SetStatus("st_need_p3")
                return
            }
            if (N < 2) {
                SetStatus("st_need_n2")
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
                SetStatus("st_same_p12")
                return
            }
            if (rows < 1)
                rows := 1

            total := rows * N
            ActivateAt(p1x, p1y)
            Sleep 120
            ran := true
            S.running := true, S.stop := false
            StyleLangBtn(false)
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
                    statusText.Text := (lang = "en" ? "Rect " : "사각형 ") N "x" rows "  " k " / " total
                    PaintAt(px, py)
                    if (k < total && !S.stop)
                        SleepDelay(delay, jit)
                }
            }
        } else {
            sx := S.startX, sy := S.startY
            ex := S.endX, ey := S.endY
            if (Abs(ex - sx) >= Abs(ey - sy))
                ey := sy
            else
                ex := sx

            ActivateAt(sx, sy)
            Sleep 120
            ran := true
            S.running := true, S.stop := false
            StyleLangBtn(false)
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
                statusText.Text := (lang = "en" ? "Line " : "직선 ") A_Index " / " N
                PaintAt(px, py)
                if (A_Index < N && !S.stop)
                    SleepDelay(delay, jit)
            }
        }
    } finally {
        S.running := false
        KeyStyle("F4", false)
        StyleLangBtn(true)
        if (ran) {
            statusText.SetFont("s9 bold c" C_YELLOW, "DotumChe")
            SetStatus(S.stop ? "st_stopped" : "st_done")
        }
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
