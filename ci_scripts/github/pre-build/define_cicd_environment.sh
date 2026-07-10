#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  define_cicd_environment.sh [--branch <branch-or-tag>] [--dry-run]

Options:
  --branch   Branch or tag. Defaults to GITHUB_REF_NAME or current git branch.
  --dry-run  Print resolved values without writing to GITHUB_ENV.
  --help     Show this help.
USAGE
}

die() {
  echo "define_cicd_environment.sh: $*" >&2
  exit 1
}

branch="${BRANCH:-${GITHUB_REF_NAME:-}}"
dry_run=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch)
      [[ $# -ge 2 ]] || die "--branch requires a value"
      branch="$2"
      shift 2
      ;;
    --dry-run)
      dry_run=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

if [[ -z "$branch" ]] && command -v git >/dev/null 2>&1; then
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
fi

branch="${branch:-unknown}"
scheme=""
environment=""
distribution_type=""
info_plist=""
tag_version=""
version=""
build_number=""
deployment_kind=""
demo_target=""
signing_mode=""

infer_from_ref() {
  local ref="$1"
  local version_part=""

  case "$ref" in
    dev/*)
      scheme="Mody-DEV"
      environment="DEV"
      distribution_type="appstore"
      deployment_kind="DEV"
      signing_mode="manual"
      version_part="${ref#dev/}"
      tag_version="${version_part%%-*}"
      ;;
    prod/*)
      scheme="Mody"
      environment="PROD"
      distribution_type="appstore"
      deployment_kind="PROD"
      signing_mode="manual"
      version_part="${ref#prod/}"
      tag_version="${version_part%%-*}"
      ;;
    demo/*/*)
      demo_target="${ref#demo/}"
      demo_target="${demo_target%%/*}"
      [[ "$demo_target" != "DesignSystemDemo" ]] || die "DesignSystemDemo must use design tag prefix: $ref"
      scheme="$demo_target"
      environment="DEV"
      distribution_type="firebase"
      deployment_kind="DEMO"
      signing_mode="manual"
      version_part="${ref#demo/*/}"
      tag_version="${version_part%%-*}"
      ;;
    design/*)
      scheme="DesignSystemDemo"
      environment="DEV"
      distribution_type="firebase"
      deployment_kind="DESIGN"
      demo_target="DesignSystemDemo"
      signing_mode="manual"
      version_part="${ref#design/}"
      tag_version="${version_part%%-*}"
      ;;
    *)
      die "unsupported ref: $ref"
      ;;
  esac
}

infer_info_plist_path() {
  local current_scheme="$1"
  local demo_name=""

  case "$current_scheme" in
    Mody*|unknown)
      printf '%s\n' "Projects/App/Support/Info.plist"
      ;;
    DesignSystemDemo)
      printf '%s\n' "Projects/DesignSystem/Demo/Support/Info.plist"
      ;;
    *Demo)
      demo_name="${current_scheme%Demo}"
      printf '%s\n' "Projects/Feature/${demo_name}/Demo/Support/Info.plist"
      ;;
    *)
      printf '%s\n' ""
      ;;
  esac
}

read_plist_value() {
  local plist_path="$1"
  local key="$2"

  [[ -f "$plist_path" ]] || return 0

  PLIST_PATH="$plist_path" PLIST_KEY="$key" python3 - <<'PY'
import os
import plistlib

path = os.environ["PLIST_PATH"]
key = os.environ["PLIST_KEY"]

with open(path, "rb") as plist_file:
    value = plistlib.load(plist_file).get(key, "")

print(value if value is not None else "")
PY
}

write_env() {
  local key="$1"
  local value="$2"

  if [[ "$dry_run" == true ]]; then
    printf '%s=%s\n' "$key" "$value"
    return
  fi

  [[ -n "${GITHUB_ENV:-}" ]] || die "GITHUB_ENV is required unless --dry-run is used"
  printf '%s=%s\n' "$key" "$value" >> "$GITHUB_ENV"
}

require_value() {
  local key="$1"
  local value="$2"

  [[ -n "$value" && "$value" != "unknown" ]] || die "$key could not be resolved"
}

infer_from_ref "$branch"
info_plist="$(infer_info_plist_path "$scheme")"

require_value "CICD_BRANCH" "$branch"
require_value "CICD_SCHEME" "$scheme"
require_value "CICD_ENVIRONMENT" "$environment"
require_value "CICD_DISTRIBUTION_TYPE" "$distribution_type"
require_value "CICD_DEPLOYMENT_KIND" "$deployment_kind"
require_value "CICD_SIGNING_MODE" "$signing_mode"

if [[ -n "$info_plist" && -f "$info_plist" ]]; then
  version="$(read_plist_value "$info_plist" "CFBundleShortVersionString")"
  build_number="$(read_plist_value "$info_plist" "CFBundleVersion")"
fi

version="${tag_version:-$version}"
require_value "CICD_VERSION" "$version"
build_number="${build_number:-}"

if [[ -n "$build_number" && "$version" != "unknown" ]]; then
  version_display="${version}(${build_number})"
else
  version_display="$version"
fi

write_env "CICD_BRANCH" "$branch"
write_env "CICD_SCHEME" "$scheme"
write_env "CICD_ENVIRONMENT" "$environment"
write_env "CICD_DISTRIBUTION_TYPE" "$distribution_type"
write_env "CICD_DEPLOYMENT_KIND" "$deployment_kind"
write_env "CICD_SIGNING_MODE" "$signing_mode"
write_env "CICD_DEMO_TARGET" "$demo_target"
write_env "CICD_INFO_PLIST" "$info_plist"
write_env "CICD_VERSION" "$version"
write_env "CICD_BUILD_NUMBER" "$build_number"
write_env "CICD_VERSION_DISPLAY" "$version_display"

echo "Define CI/CD environment succeeded"
echo "Resolved CI/CD environment: branch=$branch, kind=$deployment_kind, scheme=$scheme, environment=$environment, distribution=$distribution_type, signing=$signing_mode, demo_target=${demo_target:-none}, version=$version_display"
