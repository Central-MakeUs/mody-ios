#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  setup_xcconfig.sh [--dry-run]

Options:
  --dry-run      Print planned files without changing them.
  --help         Show this help.
USAGE
}

notify_failure() {
  local message="$1"

  echo "XCConfig setup failed"
  echo "Reason: $message" >&2

  ci_scripts/github/webhook/send_slack.sh \
    --status failure \
    --message "XCConfig 설정에 실패했어요: ${message}" \
    --step setup-xcconfig || true
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

escape_xcconfig_value() {
  local value="$1"

  printf '%s' "$value" | sed 's#//#/$()/#g'
}

create_xcconfigs() {
  local raw_api_base_url_dev
  local raw_api_base_url_prod
  local api_base_url_dev
  local api_base_url_prod
  local kakao_native_app_key_dev
  local kakao_native_app_key_prod

  raw_api_base_url_dev="${API_BASE_URL_DEV:-}"
  raw_api_base_url_prod="${API_BASE_URL_PROD:-}"
  kakao_native_app_key_dev="${KAKAO_NATIVE_APP_KEY_DEV:-}"
  kakao_native_app_key_prod="${KAKAO_NATIVE_APP_KEY_PROD:-}"

  [[ -n "$raw_api_base_url_dev" ]] || fail "required XCConfig secret/env is missing: API_BASE_URL_DEV"
  [[ -n "$raw_api_base_url_prod" ]] || fail "required XCConfig secret/env is missing: API_BASE_URL_PROD"
  [[ -n "$kakao_native_app_key_dev" ]] || fail "required XCConfig secret/env is missing: KAKAO_NATIVE_APP_KEY_DEV"
  [[ -n "$kakao_native_app_key_prod" ]] || fail "required XCConfig secret/env is missing: KAKAO_NATIVE_APP_KEY_PROD"

  api_base_url_dev="$(escape_xcconfig_value "$raw_api_base_url_dev")"
  api_base_url_prod="$(escape_xcconfig_value "$raw_api_base_url_prod")"

  mkdir -p XCConfig

  cat > XCConfig/Shared.xcconfig <<'EOF'
ENABLE_USER_SCRIPT_SANDBOXING = NO
OTHER_LDFLAGS = -ObjC
EOF

  cat > XCConfig/DEV.xcconfig <<EOF
#include "./Shared.xcconfig"

BUNDLE_IDENTIFIER = com.jagsim.mody-dev
BUNDLE_NAME = MODY DEV
ENV = Dev
SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEV
BASE_URL = ${api_base_url_dev}
KAKAO_NATIVE_APP_KEY = ${kakao_native_app_key_dev}
EOF

  cat > XCConfig/PROD.xcconfig <<EOF
#include "./Shared.xcconfig"

BUNDLE_IDENTIFIER = com.jagsim.mody
BUNDLE_NAME = MODY
ENV = Prod
SWIFT_ACTIVE_COMPILATION_CONDITIONS = PROD
BASE_URL = ${api_base_url_prod}
KAKAO_NATIVE_APP_KEY = ${kakao_native_app_key_prod}
EOF

  cp XCConfig/PROD.xcconfig XCConfig/RELEASE.xcconfig

  [[ -f XCConfig/Shared.xcconfig ]] || fail "failed to create XCConfig/Shared.xcconfig"
  [[ -f XCConfig/DEV.xcconfig ]] || fail "failed to create XCConfig/DEV.xcconfig"
  [[ -f XCConfig/PROD.xcconfig ]] || fail "failed to create XCConfig/PROD.xcconfig"
  [[ -f XCConfig/RELEASE.xcconfig ]] || fail "failed to create XCConfig/RELEASE.xcconfig"
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
  echo "XCConfig setup dry-run"
  echo "files=XCConfig/Shared.xcconfig XCConfig/DEV.xcconfig XCConfig/PROD.xcconfig XCConfig/RELEASE.xcconfig"
  echo "required_env=API_BASE_URL_DEV API_BASE_URL_PROD KAKAO_NATIVE_APP_KEY_DEV KAKAO_NATIVE_APP_KEY_PROD"
  exit 0
fi

echo "Setup XCConfig started"
trap 'handle_unexpected_failure "$LINENO" "$BASH_COMMAND"' ERR
create_xcconfigs

echo "XCConfig setup succeeded"
