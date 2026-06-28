#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  install_ios_signing_assets.sh [--dry-run]

Options:
  --dry-run      Print planned signing asset installation without changing keychains.
  --help         Show this help.
USAGE
}

notify_failure() {
  local message="$1"

  echo "Signing asset install failed"
  echo "Reason: $message" >&2

  ci_scripts/github/webhook/send_slack.sh \
    --status failure \
    --message "서명 자산 설치에 실패했어요: ${message}" \
    --step install-ios-signing-assets || true
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

  [[ -n "$value" ]] || fail "required signing secret/env is missing: $name"
}

decode_base64() {
  local value="$1"
  local output_path="$2"

  printf '%s' "$value" | base64 -D > "$output_path"
  [[ -s "$output_path" ]] || fail "failed to decode signing asset: $output_path"
}

deployment_kind="${CICD_DEPLOYMENT_KIND:-}"
dry_run=false
profile_secret_name=""
profile_file_name=""

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

case "$deployment_kind" in
  DEV)
    profile_secret_name="DEV_IOS_APPSTORE_PROFILE_BASE64"
    profile_file_name="dev_appstore"
    ;;
  PROD)
    profile_secret_name="PROD_IOS_APPSTORE_PROFILE_BASE64"
    profile_file_name="prod_appstore"
    ;;
  DEMO|DESIGN)
    profile_secret_name="DEMO_IOS_ADHOC_PROFILE_BASE64"
    profile_file_name="demo_adhoc"
    ;;
  *)
    echo "Signing asset install skipped"
    echo "Reason: deployment_kind=${deployment_kind:-unknown} does not use installed signing assets"
    exit 0
    ;;
esac

echo "Signing asset install started"
trap 'handle_unexpected_failure "$LINENO" "$BASH_COMMAND"' ERR

if [[ "$dry_run" == true ]]; then
  echo "Signing asset install dry-run"
  echo "deployment_kind=$deployment_kind"
  echo "certificate_secret=IOS_DISTRIBUTION_CERTIFICATE_BASE64"
  echo "profile_secret=$profile_secret_name"
  echo "keychain_secret=IOS_SIGNING_KEYCHAIN_PASSWORD"
  exit 0
fi

require_env "IOS_DISTRIBUTION_CERTIFICATE_BASE64"
require_env "IOS_DISTRIBUTION_CERTIFICATE_PASSWORD"
require_env "$profile_secret_name"
require_env "IOS_SIGNING_KEYCHAIN_PASSWORD"

signing_dir="${RUNNER_TEMP:-build/signing}/ios-signing"
certificate_path="$signing_dir/apple_distribution.p12"
profile_path="$signing_dir/${profile_file_name}.mobileprovision"
profile_plist_path="$signing_dir/${profile_file_name}.plist"
keychain_path="$signing_dir/ios_signing.keychain-db"

mkdir -p "$signing_dir"

decode_base64 "$IOS_DISTRIBUTION_CERTIFICATE_BASE64" "$certificate_path"
decode_base64 "${!profile_secret_name}" "$profile_path"

security cms -D -i "$profile_path" > "$profile_plist_path"
profile_uuid="$(/usr/libexec/PlistBuddy -c 'Print UUID' "$profile_plist_path")"
profile_name="$(/usr/libexec/PlistBuddy -c 'Print Name' "$profile_plist_path")"
application_identifier="$(/usr/libexec/PlistBuddy -c 'Print Entitlements:application-identifier' "$profile_plist_path")"
profile_bundle_identifier="${application_identifier#*.}"
[[ -n "$profile_uuid" ]] || fail "failed to read provisioning profile UUID"
[[ -n "$profile_name" ]] || fail "failed to read provisioning profile name"
[[ -n "$profile_bundle_identifier" ]] || fail "failed to read provisioning profile bundle identifier"

security create-keychain -p "$IOS_SIGNING_KEYCHAIN_PASSWORD" "$keychain_path"
security set-keychain-settings -lut 21600 "$keychain_path"
security unlock-keychain -p "$IOS_SIGNING_KEYCHAIN_PASSWORD" "$keychain_path"

current_keychains="$(security list-keychains -d user | tr -d '"')"
security list-keychains -d user -s "$keychain_path" $current_keychains

security import "$certificate_path" \
  -k "$keychain_path" \
  -P "$IOS_DISTRIBUTION_CERTIFICATE_PASSWORD" \
  -T /usr/bin/codesign \
  -T /usr/bin/security

security set-key-partition-list \
  -S apple-tool:,apple:,codesign: \
  -s \
  -k "$IOS_SIGNING_KEYCHAIN_PASSWORD" \
  "$keychain_path"

mkdir -p "$HOME/Library/MobileDevice/Provisioning Profiles"
cp "$profile_path" "$HOME/Library/MobileDevice/Provisioning Profiles/${profile_uuid}.mobileprovision"

if [[ -n "${GITHUB_ENV:-}" ]]; then
  {
    printf 'CICD_PROVISIONING_PROFILE_SPECIFIER=%s\n' "$profile_name"
    printf 'CICD_PROVISIONING_PROFILE_UUID=%s\n' "$profile_uuid"
    printf 'CICD_PROVISIONING_PROFILE_BUNDLE_IDENTIFIER=%s\n' "$profile_bundle_identifier"

    if [[ "$deployment_kind" == "DEMO" || "$deployment_kind" == "DESIGN" ]]; then
      printf 'CICD_DEMO_PROVISIONING_PROFILE_SPECIFIER=%s\n' "$profile_name"
      printf 'CICD_DEMO_PROVISIONING_PROFILE_UUID=%s\n' "$profile_uuid"
    fi
  } >> "$GITHUB_ENV"
fi

echo "Signing asset install succeeded"
echo "Installed provisioning profile UUID: $profile_uuid"
echo "Installed provisioning profile name: $profile_name"
echo "Installed provisioning profile bundle id: $profile_bundle_identifier"
