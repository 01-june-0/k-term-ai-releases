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

# ---- output: brand colors (256-color, so Terminal.app shows them too) on a tty, plain otherwise
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  C_G=$'\e[38;5;114m' C_V=$'\e[38;5;141m' C_B=$'\e[1m' C_D=$'\e[38;5;245m' C_0=$'\e[0m'
else
  C_G="" C_V="" C_B="" C_D="" C_0=""
fi
if [[ -t 2 && -z "${NO_COLOR:-}" ]]; then C_R=$'\e[38;5;203m' C_E0=$'\e[0m'; else C_R="" C_E0=""; fi
banner() { printf '\n  %s❯%s %skTerm%s%s.AI%s  %s설치 · 업데이트%s\n\n' "$C_G" "$C_0" "$C_B" "$C_0" "$C_V" "$C_0" "$C_D" "$C_0"; }
step() { printf '  %s●%s %s\n' "$C_V" "$C_0" "$*"; }
ok() { printf '  %s✓%s %s\n' "$C_G" "$C_0" "$*"; }
note() { printf '    %s%s%s\n' "$C_D" "$*" "$C_0"; }
fail() { printf '  %s✗ %s%s\n' "$C_R" "$1" "$C_E0" >&2; shift; local l; for l in "$@"; do printf '    %s\n' "$l" >&2; done; exit 1; }

version_of() {
  [[ -f "$1/Contents/Info.plist" ]] || return 0
  /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$1/Contents/Info.plist" 2>/dev/null || true
}

# Is this user running the copy at $1 (an .app path)? A plain prefix match on the
# command line, so regex characters in the path don't matter.
running() {
  ps -x -U "$(id -u)" -o command= | awk -v p="$1/Contents/MacOS/" 'index($0, p) == 1 { found = 1 } END { exit !found }'
}

main() {
  local base="${KTERM_BASE_URL:-https://github.com/01-june-0/k-term-ai-releases/releases/latest/download}"
  local asset="kTerm.AI-macos-universal.zip"

  banner
  if [[ "$(uname -s)" != Darwin ]]; then
    fail "이 설치 스크립트는 macOS용입니다." "Windows에서는 PowerShell용 설치 명령을 쓰세요."
  fi
  if [[ "${TERM_PROGRAM:-}" == "kTerm.AI" ]]; then
    fail "kTerm.AI 안에서는 설치·업데이트할 수 없습니다 (앱을 종료해야 하므로)." \
      "kTerm.AI를 종료한 뒤 macOS 기본 '터미널' 앱에서 이 명령을 실행해 주세요."
  fi

  local dir="${KTERM_INSTALL_DIR:-}"
  if [[ -z "$dir" ]]; then
    if [[ -w /Applications ]]; then dir=/Applications; else dir="$HOME/Applications"; fi
  fi
  local app="$dir/kTerm.AI.app"
  if running "$app"; then
    fail "kTerm.AI가 실행 중입니다." "앱을 종료한 뒤 이 명령을 다시 실행해 주세요." \
      "(종료하면 열려 있는 터미널·SSH 세션이 모두 닫힙니다.)"
  fi
  mkdir -p "$dir"

  KTERM_TMP=$(mktemp -d)
  trap cleanup EXIT

  step "내려받는 중"
  curl -fL --progress-bar "$base/$asset" -o "$KTERM_TMP/$asset" || fail "내려받지 못했습니다." "인터넷 연결을 확인하고 다시 실행해 주세요."
  ditto -x -k "$KTERM_TMP/$asset" "$KTERM_TMP/app"
  if [[ ! -d "$KTERM_TMP/app/kTerm.AI.app" ]]; then
    fail "내려받은 파일에 kTerm.AI.app이 없습니다."
  fi

  local old new
  old=$(version_of "$app")
  new=$(version_of "$KTERM_TMP/app/kTerm.AI.app")
  if [[ -z "$old" ]]; then step "설치하는 중  ${C_D}${new}${C_0}"
  elif [[ "$old" == "$new" ]]; then step "다시 설치하는 중  ${C_D}${new} (이미 최신 버전)${C_0}"
  else step "업데이트하는 중  ${C_D}${old} → ${new}${C_0}"; fi

  # Copy next to the old app first, so a failed copy leaves the old one in place
  local staged="$dir/.kTerm.AI.app.new"
  rm -rf "$staged"
  ditto "$KTERM_TMP/app/kTerm.AI.app" "$staged"
  rm -rf "$app"
  mv "$staged" "$app"
  ok "설치 완료  ${C_D}${app}${C_0}"
  note "앱을 엽니다. 업데이트할 때도 같은 명령을 다시 실행하면 됩니다."
  echo
  open "$app"
}

main "$@"
