# AutoPixel

[English](https://github.com/JTech-CO/AutoPixel/blob/main/README.md) | **한국어**

> **wplace.live의 픽셀아트를 직선·사각형으로 자동으로 그려주는 Windows 오토마우스 (AutoHotkey)**

## 1. 소개 (Introduction)

AutoPixel은 [wplace.live](https://wplace.live/)에서 가이드라인을 따라 픽셀을 찍는 반복 작업을 자동화하기 위해 만든 **AutoHotkey 기반 오토마우스**입니다. 실제 마우스·키보드 동작을 그대로 재현(이동 → `i` 색상 인식 → 클릭)하여, 사람이 손으로 찍는 과정을 자동으로 수행합니다.

**주요 기능**
- **직선 모드**: 시작·끝 두 점을 찍으면 그 사이를 N칸으로 균등 분할해 한 줄을 자동으로 채움
- **사각형 모드**: 3점(시작 / 같은 행 끝 / 다른 행 끝)으로 사각 영역을 행 단위로 자동으로 채움 (세로 행 수는 자동 산출)
- **칸 수 자동 계산**: `F8`로 1칸 크기를 한 번 보정(인접한 두 칸 클릭)하면, 이후 시작·끝 선택 시 `N`이 자동으로 채워짐 — 대규모 그림도 셀 필요 없음
- **픽셀아트 UI**: 다크 테마 · 픽셀 로고 · **누르면 하이라이트되는 키캡 패널**(실행 중엔 계속 켜짐)로 진행 상황을 직관적으로 확인
- **딜레이·지터** 조절로 속도와 규칙성을 완화

## 2. 기술 스택 (Tech Stack)

- **Platform**: Windows
- **Runtime**: AutoHotkey v2
- **Language**: AutoHotkey v2 Script
- **자동화**: 실제 마우스/키보드 입력 시뮬레이션 (오토마우스)
- **의존성 / 네트워크**: 없음 (전적으로 로컬에서 동작)

## 3. 설치 및 실행 (Quick Start)

**요구 사항**: Windows + [AutoHotkey v2](https://www.autohotkey.com/download/ahk-v2.exe)

1. **설치 (Install)**
   - **AutoHotkey v2** 를 설치합니다 — 직접 다운로드: https://www.autohotkey.com/download/ahk-v2.exe
   - 이 저장소를 다운로드하거나 클론합니다.
   ```bash
   git clone <repository-url>
   ```

2. **실행 (Run)**
   - `AutoPixel-실행.bat` 을 더블클릭합니다. (또는 `AutoPixel.ahk` 직접 실행)
   - 좌측 상단에 패널이 뜨면 준비 완료입니다.

3. **사용 (Usage)**
   - **(최초 1회) 1칸 크기 보정**: 한 칸에서 `F8`, 바로 옆 칸에서 `F8` → 1칸 크기가 학습되어 이후 `N`이 자동으로 채워짐 (줌을 바꾸면 다시 보정)
   - **직선 모드**: `F2`(시작) → `F3`(끝) → `F4` 실행
   - **사각형 모드**: `F2`(좌상단) → `F3`(같은 행 끝) → `F7`(다른 행 끝) → `F4` 실행
   - **정지**: `Esc` 또는 `F6`
   - `N`(직선 칸 수 / 사각형 가로 칸 수)은 보정 후 자동 입력되며 직접 수정도 가능. 기본값: 딜레이 `50`ms, 지터 `25`%.
   - 자세한 설명은 [`AutoPixel-사용법.md`](AutoPixel-사용법.md) 참고

## 4. 폴더 구조 (Structure)

```text
AutoPixel/
├── AutoPixel.ahk         # 본체 스크립트 (직선·사각형 모드)
├── AutoPixel-실행.bat     # 더블클릭 실행기 (AHK 경로 자동 탐색)
├── AutoPixel-진단.bat     # 실행 문제 진단용
├── AutoPixel-사용법.md    # 상세 사용법
├── logo.png              # 아이콘 / 로고
├── privacy-policy.html   # 개인정보 처리방침 (EN / KO 전환)
├── README.md             # 영문
└── README-KR.md          # 한국어 (이 문서)
```

## 5. 정보 (Info)

- **Version**: 1.1.0
- **License**: MIT
- **Privacy**: [privacy-policy.html](privacy-policy.html) — 어떤 데이터도 수집·전송하지 않습니다 (로컬 전용)
- **Contact**: GitHub Issues

## ⚠️ 주의 (Disclaimer)

- AutoPixel은 마우스·키보드를 자동으로 조작하는 **오토마우스**입니다. wplace는 자동화를 제한할 수 있으며, 사용에 따른 **계정 제재 등 모든 책임은 사용자 본인**에게 있습니다.
- 반드시 **본인 계정·본인 충전량** 범위에서만 사용하고, 딜레이를 너무 짧게 두지 마세요(지터 사용 권장).
- 본 도구는 개인·학습 용도로 제공되며, 제작자는 오·남용에 대한 책임을 지지 않습니다.
