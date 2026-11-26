# kTerm.AI 테스트 버전

SSH·로컬 터미널에 AI 도우미를 더한 macOS / Windows 앱의 테스트 배포판입니다.

## 설치 · 업데이트

**macOS** (Apple silicon, Intel 모두) — macOS 기본 **터미널** 앱에서:

```bash
curl -fsSL https://raw.githubusercontent.com/01-june-0/k-term-ai-releases/main/install.sh | bash
```

**Windows** (64비트) — PowerShell에서:

```powershell
[Net.ServicePointManager]::SecurityProtocol = 'Tls12'; irm https://raw.githubusercontent.com/01-june-0/k-term-ai-releases/main/install.ps1 | iex
```

같은 명령을 다시 실행하면 최신 버전으로 업데이트됩니다. 설정과 저장한 호스트는 그대로 남습니다.
업데이트 전에 kTerm.AI를 먼저 종료하세요 (열린 터미널·SSH 세션은 닫힙니다). kTerm.AI 안의 터미널에서는 업데이트할 수 없습니다.

## 알아 둘 점

- 테스트 버전이라 Apple·Microsoft의 정식 서명이 없습니다.
- **macOS**: 위 설치 명령으로 설치하면 바로 열립니다. 릴리스 페이지에서 zip을 직접 받아 풀면 "확인되지 않은 개발자" 경고로 열리지 않으니 설치 명령을 써 주세요.
- **Windows**: "Windows의 PC 보호" 창이 뜨면 **추가 정보 → 실행**을 누르세요.
- macOS에서 처음 실행할 때 키체인 접근을 묻는 창이 뜰 수 있습니다. **항상 허용**을 누르면 됩니다.
- AI 기능(Claude Code · Codex · Antigravity)은 각 CLI가 따로 설치·로그인되어 있어야 합니다. 앱의 설정 화면에 설치 방법 안내가 있습니다.

## 삭제

- **macOS**: `응용 프로그램`의 kTerm.AI를 휴지통으로 옮깁니다. 설정까지 지우려면 `~/Library/Application Support/ai.kterm.app` 폴더도 지웁니다.
- **Windows**: 설정 → 앱 → kTerm.AI → 제거. 설정까지 지우려면 `%APPDATA%\ai.kterm.app` 폴더도 지웁니다.

## 문제 알리기

이상한 동작을 발견하면 화면 캡처나 오류 메시지와 함께 배포한 사람에게 알려 주세요.
