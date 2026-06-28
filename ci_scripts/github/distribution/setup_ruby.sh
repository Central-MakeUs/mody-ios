#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  setup_ruby.sh [--dry-run]

Options:
  --dry-run      Print planned commands without running them.
  --help         Show this help.
USAGE
}

notify_failure() {
  local message="$1"

  echo "Ruby setup failed"
  echo "Reason: $message" >&2

  ci_scripts/github/webhook/send_slack.sh \
    --status failure \
    --message "Ruby/Fastlane 설치에 실패했어요: ${message}" \
    --step setup-ruby || true
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
bundler_version="${CICD_BUNDLER_VERSION:-2.4.22}"

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
  echo "Ruby setup dry-run"
  echo "bundler_version=$bundler_version"
  echo "commands=brew install ruby, gem install bundler, bundle install"
  exit 0
fi

echo "Setup Ruby started"
trap 'handle_unexpected_failure "$LINENO" "$BASH_COMMAND"' ERR

export PATH="$HOME/.local/bin:$PATH"

[[ -f "Gemfile" ]] || fail "Gemfile does not exist"
[[ -f "Gemfile.lock" ]] || fail "Gemfile.lock does not exist"

echo "Ruby install started"
command -v brew >/dev/null 2>&1 || fail "Homebrew is not installed"
if ! brew list ruby >/dev/null 2>&1; then
  brew install ruby
else
  echo "Ruby already installed by Homebrew"
fi
echo "Ruby install succeeded"

ruby_bin="$(brew --prefix ruby)/bin"
[[ -d "$ruby_bin" ]] || fail "Ruby bin directory does not exist: $ruby_bin"

export PATH="$ruby_bin:$PATH"

if [[ -n "${GITHUB_PATH:-}" ]]; then
  printf '%s\n' "$ruby_bin" >> "$GITHUB_PATH"
fi

echo "Ruby version check started"
ruby -v
ruby -rsocket -e 'puts "Ruby socket library check succeeded"'
echo "Ruby version check succeeded"

echo "Bundler install started"
gem install bundler -v "$bundler_version" --no-document
echo "Bundler install succeeded"

echo "Bundle install started"
bundle config set --local path vendor/bundle
bundle config set --local deployment true
bundle install --jobs "$(sysctl -n hw.ncpu 2>/dev/null || echo 4)"
echo "Bundle install succeeded"

echo "Ruby setup succeeded"
