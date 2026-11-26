#!/usr/bin/env bash
# kTerm.AI installer for macOS (Apple silicon and Intel). Run it again to update:
#   curl -fsSL https://raw.githubusercontent.com/01-june-0/k-term-ai-releases/main/install.sh | bash
# KTERM_BASE_URL overrides where the app is downloaded from, KTERM_INSTALL_DIR
# where it goes (default /Applications, or ~/Applications if that is not writable).
# Everything runs from main() on the last line, so a cut-off download runs nothing.
#
# It never quits kTerm.AI itself: quitting closes every terminal and SSH session
# without asking, so the tester quits the app and runs the command again.
set -euo pipefail

KTERM_TMP=""
cleanup() { [[ -n "$KTERM_TMP" ]] && rm -rf "$KTERM_TMP"; return 0; }

# Is this user running the copy at $1 (an .app path)? A plain prefix match on the
# command line, so regex characters in the path don't matter.
running() {
  ps -x -U "$(id -u)" -o command= | awk -v p="$1/Contents/MacOS/" 'index($0, p) == 1 { found = 1 } END { exit !found }'
}

main() {
  local base="${KTERM_BASE_URL:-https://github.com/01-june-0/k-term-ai-releases/releases/latest/download}"
  local asset="kTerm.AI-macos-universal.zip"

  if [[ "$(uname -s)" != Darwin ]]; then
    echo "이 설치 스크립트는 macOS용입니다. Windows에서는 PowerShell용 명령을 쓰세요." >&2
    exit 1
  fi
  if [[ "${TERM_PROGRAM:-}" == "kTerm.AI" ]]; then
    echo "kTerm.AI 안에서는 설치·업데이트할 수 없습니다 (앱을 종료해야 하므로)." >&2
    echo "kTerm.AI를 종료한 뒤 macOS 기본 '터미널' 앱에서 이 명령을 실행해 주세요." >&2
    exit 1
  fi

  local dir="${KTERM_INSTALL_DIR:-}"
  if [[ -z "$dir" ]]; then
    if [[ -w /Applications ]]; then dir=/Applications; else dir="$HOME/Applications"; fi
  fi
  local app="$dir/kTerm.AI.app"
  if running "$app"; then
    echo "kTerm.AI가 실행 중입니다. 앱을 종료한 뒤 이 명령을 다시 실행해 주세요." >&2
    echo "(종료하면 열려 있는 터미널·SSH 세션이 모두 닫힙니다.)" >&2
    exit 1
  fi
  mkdir -p "$dir"

  KTERM_TMP=$(mktemp -d)
  trap cleanup EXIT

  echo "kTerm.AI 내려받는 중..."
  curl -fL --progress-bar "$base/$asset" -o "$KTERM_TMP/$asset"
  ditto -x -k "$KTERM_TMP/$asset" "$KTERM_TMP/app"
  if [[ ! -d "$KTERM_TMP/app/kTerm.AI.app" ]]; then
    echo "내려받은 파일에 kTerm.AI.app이 없습니다." >&2
    exit 1
  fi

  # Copy next to the old app first, so a failed copy leaves the old one in place
  local staged="$dir/.kTerm.AI.app.new"
  rm -rf "$staged"
  ditto "$KTERM_TMP/app/kTerm.AI.app" "$staged"
  rm -rf "$app"
  mv "$staged" "$app"
  echo "설치 완료: $app"
  open "$app"
}

main "$@"
