#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  build_app.sh [--dry-run]

Options:
  --dry-run      Print resolved build settings without installing or building.
  --help         Show this help.
USAGE
}

notify_failure() {
  local message="$1"

  echo "App build failed"
  echo "Reason: $message" >&2

  ci_scripts/github/webhook/send_slack.sh \
    --status failure \
    --message "앱 빌드/배포에 실패했어요: ${message}" \
    --step app-build || true
}

notify_success() {
  echo "App build succeeded"

  ci_scripts/github/webhook/send_slack.sh \
    --status success \
    --message "앱 빌드/배포가 성공했어요" \
    --step app-build || true
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

require_env() {
  local name="$1"
  local value="${!name:-}"

  [[ -n "$value" ]] || fail "required build env is missing: $name"
}

scheme_exists() {
  local scheme="$1"

  find Projects -path "*/xcshareddata/xcschemes/${scheme}.xcscheme" -print -quit | grep -q .
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

require_env "CICD_SCHEME"
require_env "CICD_DEPLOYMENT_KIND"
require_env "CICD_DISTRIBUTION_TYPE"
require_env "CICD_VERSION"

if [[ "$dry_run" == true ]]; then
  echo "App build dry-run"
  echo "scheme=$CICD_SCHEME"
  echo "deployment_kind=$CICD_DEPLOYMENT_KIND"
  echo "distribution_type=$CICD_DISTRIBUTION_TYPE"
  echo "signing_mode=${CICD_SIGNING_MODE:-automatic}"
  echo "version=$CICD_VERSION"
  echo "demo_target=${CICD_DEMO_TARGET:-}"
  exit 0
fi

echo "App build started"
echo "Resolved build target: scheme=$CICD_SCHEME, kind=$CICD_DEPLOYMENT_KIND, distribution=$CICD_DISTRIBUTION_TYPE, signing=${CICD_SIGNING_MODE:-automatic}, version=$CICD_VERSION"

trap 'handle_unexpected_failure "$LINENO" "$BASH_COMMAND"' ERR

export FASTLANE_SKIP_UPDATE_CHECK=1
export FASTLANE_HIDE_CHANGELOG=1
export FASTLANE_OPT_OUT_USAGE=1

scheme_exists "$CICD_SCHEME" || fail "shared scheme does not exist: $CICD_SCHEME"

if command -v bundle >/dev/null 2>&1; then
  echo "Bundle install started"
  bundle check || bundle install
  echo "Bundle install succeeded"

  echo "Fastlane CI/CD lane started"
  bundle exec fastlane ios cicd
else
  echo "Bundler is not installed; using system fastlane"
  command -v fastlane >/dev/null 2>&1 || fail "fastlane is not installed"

  echo "Fastlane CI/CD lane started"
  fastlane ios cicd
fi

notify_success
