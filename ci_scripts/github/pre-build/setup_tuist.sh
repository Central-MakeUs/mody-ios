#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  setup_tuist.sh [--dry-run]

Options:
  --dry-run      Print planned commands without running them.
  --help         Show this help.
USAGE
}

notify_failure() {
  local message="$1"

  echo "Tuist setup failed"
  echo "Reason: $message" >&2

  ci_scripts/github/webhook/send_slack.sh \
    --status failure \
    --message "Tuist 설정에 실패했어요: ${message}" \
    --step setup-tuist || true
}

notify_success() {
  echo "Tuist setup succeeded"
}

fail() {
  local message="$1"

  trap - ERR
  notify_failure "$message"
  exit 1
}

handle_unexpected_failure() {
  local line="$1"
  local command="$2"

  trap - ERR
  notify_failure "line ${line}: ${command}"
  exit 1
}

dry_run=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      dry_run=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      fail "unknown argument: $1"
      ;;
  esac
done

if [[ "$dry_run" == true ]]; then
  echo "Tuist setup dry-run"
  echo "commands=curl mise install, mise install tuist, tuist version, make clean, make generate"
  exit 0
fi

echo "Setup Tuist started"
trap 'handle_unexpected_failure "$LINENO" "$BASH_COMMAND"' ERR

if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  echo "GitHub token detected for mise downloads"
else
  echo "GitHub token is not set; mise may hit GitHub API rate limits"
fi

if ! command -v mise >/dev/null 2>&1; then
  echo "mise install started"
  curl https://mise.jdx.dev/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
  echo "mise install succeeded"
else
  echo "mise already installed"
fi

export PATH="$HOME/.local/bin:$PATH"

echo "Tuist install started"
mise install tuist
echo "Tuist install succeeded"

echo "mise activate started"
eval "$(mise activate bash --shims)" || echo "mise activate warning: continuing without shell activation"

echo "mise doctor started"
mise doctor || echo "mise doctor warning: continuing despite warnings"

echo "Tuist version check started"
mise exec -- tuist version
echo "Tuist version check succeeded"

echo "Tuist clean started"
mise exec -- make clean
echo "Tuist clean succeeded"

echo "Tuist generate started"
mise exec -- make generate

notify_success
