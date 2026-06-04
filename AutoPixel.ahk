#Requires AutoHotkey v2.0
#SingleInstance Force
CoordMode "Mouse", "Screen"
SetMouseDelay 0

; ===========================================================
;  AutoPixel  —  wplace 자동 픽셀 (AutoHotkey)
;  실제 마우스/키보드를 자동 조작해 '수동 동작'을 그대로 재현합니다.
;  칸마다:  이동 → i(색상 인식) → 클릭 0.1s → 대기 0.1s → 클릭 0.1s
;
;  [직선 모드]  P1 시작 → P2 끝.  N칸을 직선으로 채움.
;  [사각형 모드] P1 시작(좌상단) → P2 같은 행 끝(우상단) → P3 다른 행 끝(하단).
;               가로 N칸 + (P3로 자동 산출된)세로 행 수만큼, 행 단위로 채움.
;
;   F2 : P1 시작점 보정
;   F3 : P2 끝점(직선) / 같은 행 끝(사각형) 보정
;   F7 : P3 다른 행 끝(사각형 전용) 보정
;   F4 : 실행
;   Esc / F6 : 정지 (실행 중에만 동작)
; ===========================================================

; ---------- 전역 상태 ----------
S := { startX: "", startY: "", endX: "", endY: "", rectX: "", rectY: "", running: false, stop: false }

; ---------- GUI (픽셀아트 테마) ----------
g := Gui("+AlwaysOnTop +ToolWindow", "AutoPixel")
g.MarginX := 12
g.MarginY := 12
g.BackColor := "14142B"
g.SetFont("s9", "DotumChe")

; 헤더: 픽셀 로고 + 타이틀
logoPath := A_ScriptDir "\logo.png"
if FileExist(logoPath)
    g.Add("Picture", "x12 y12 w48 h48", logoPath)
g.SetFont("s14 bold", "DotumChe")
g.Add("Text", "x70 y16 w228 c5CE65C", "AutoPixel")
g.SetFont("s8 norm", "DotumChe")
g.Add("Text", "x70 y45 w228 c9A9ABF", "wplace 자동 픽셀")

; 픽셀 구분선
g.Add("Text", "x12 y68 w286 h3 Background39D353", "")

; 모드 선택
g.SetFont("s9 norm", "DotumChe")
g.Add("Text", "xm y+10 +0x200 cC8C8DC", "모드")
modeLineRadio := g.Add("Radio", "x+10 yp Checked cE6E6F2", "직선")
modeRectRadio := g.Add("Radio", "x+14 yp cE6E6F2", "사각형")

; 단축키 안내
g.SetFont("s8", "DotumChe")
g.Add("Text", "xm y+7 c8080A0", "F2 시작 · F3 끝 · F7 다른행끝 · F4 실행 · Esc 정지")

; 보정 좌표 표시
g.SetFont("s9", "DotumChe")
startLbl := g.Add("Text", "xm y+8 cC8C8DC w286", "P1 시작: (미설정)")
endLbl   := g.Add("Text", "xm cC8C8DC w286", "P2 끝(행): (미설정)")
rectLbl  := g.Add("Text", "xm cC8C8DC w286", "P3 다른행끝: (미설정)  [사각형]")

; 입력값
g.Add("Text", "xm y+9 w128 +0x200 cC8C8DC", "칸 수 N (가로)")
nEdit := g.Add("Edit", "x+6 yp w80", "10")
g.Add("Text", "xm w128 +0x200 cC8C8DC", "딜레이 (ms)")
delayEdit := g.Add("Edit", "x+6 yp w80", "150")
g.Add("Text", "xm w128 +0x200 cC8C8DC", "지터 (%)")
jitterEdit := g.Add("Edit", "x+6 yp w80", "30")

; 정지 블록 버튼
stopBtn := g.Add("Text", "xm y+11 w286 h24 Center +0x200 +Border BackgroundB5302A cFFFFFF", "정지 (Esc / F6)")
stopBtn.OnEvent("Click", StopPaint)

; 상태
g.SetFont("s9 bold", "DotumChe")
statusText := g.Add("Text", "xm y+9 cF2D94E w286", "상태: 모드 선택 후 보정")

g.Show("x12 y12")
try DllCall("dwmapi\DwmSetWindowAttribute", "ptr", g.Hwnd, "int", 20, "int*", 1, "int", 4)  ; 다크 타이틀바

; ---------- 핫키 ----------
F2::CaptureStart()
F3::CaptureEnd()
F7::CaptureRect()
F4::RunPaint()

#HotIf S.running
Esc::StopPaint()
F6::StopPaint()
#HotIf

; ---------- 보정 ----------
CaptureStart(*) {
    global S, startLbl, statusText
    MouseGetPos &x, &y
    S.startX := x, S.startY := y
    startLbl.Text := "P1 시작: (" x ", " y ")"
    statusText.Text := "P1 보정됨 → F3"
}

CaptureEnd(*) {
    global S, endLbl, statusText
    MouseGetPos &x, &y
    S.endX := x, S.endY := y
    endLbl.Text := "P2 끝(행): (" x ", " y ")"
    statusText.Text := "P2 보정됨 → 직선:F4 / 사각형:F7"
}

CaptureRect(*) {
    global S, rectLbl, statusText
    MouseGetPos &x, &y
    S.rectX := x, S.rectY := y
    rectLbl.Text := "P3 다른행끝: (" x ", " y ")"
    statusText.Text := "P3 보정됨 → F4로 실행 (사각형)"
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

; 한 칸 칠하기:  이동 → i(색상 인식) → 2회 클릭
PaintAt(x, y) {
    MouseMove x, y, 0
    Sleep 40
    Send "i"
    Sleep 60
    Click "Down"
    Sleep 100         ; 클릭 0.1초
    Click "Up"
    Sleep 100         ; 대기 0.1초
    Click "Down"
    Sleep 100         ; 클릭 0.1초
    Click "Up"
}

; ---------- 실행 ----------
RunPaint(*) {
    global S, nEdit, delayEdit, jitterEdit, statusText, modeRectRadio
    if (S.running)
        return

    N := ToInt(nEdit.Text, 1)
    if (N < 1)
        N := 1
    delay := ToInt(delayEdit.Text, 150)
    jit := ToInt(jitterEdit.Text, 0)
    rect := (modeRectRadio.Value = 1)

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
            statusText.Text := "사각형 모드는 가로 칸 수(N)가 2 이상이어야 합니다"
            return
        }

        p1x := S.startX, p1y := S.startY
        dx := S.endX - p1x, dy := S.endY - p1y

        ; 행(가로)축을 주축으로 스냅 → 칸 간격(pitch) 산출
        if (Abs(dx) >= Abs(dy)) {
            colStepX := dx / (N - 1), colStepY := 0
            pitch := Abs(colStepX)
            rowStepX := 0
            rowStepY := (S.rectY >= p1y ? 1 : -1) * pitch
            rows := (pitch > 0) ? Round(Abs(S.rectY - p1y) / pitch) + 1 : 1
        } else {
            colStepX := 0, colStepY := dy / (N - 1)
            pitch := Abs(colStepY)
            rowStepY := 0
            rowStepX := (S.rectX >= p1x ? 1 : -1) * pitch
            rows := (pitch > 0) ? Round(Abs(S.rectX - p1x) / pitch) + 1 : 1
        }

        if (pitch = 0) {
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
        if (Abs(ex - sx) >= Abs(ey - sy))   ; 직선(가로/세로) 스냅
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

    S.running := false
    statusText.SetFont("s9 bold cF2D94E", "DotumChe")
    statusText.Text := S.stop ? "정지됨." : "완료"
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
