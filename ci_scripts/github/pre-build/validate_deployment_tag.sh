#!/usr/bin/env bash

set -euo pipefail

die() {
  local message="$1"

  echo "Validate deployment tag failed"
  echo "Reason: $message" >&2

  ci_scripts/github/webhook/send_slack.sh \
    --status failure \
    --message "배포 태그가 올바르지 않아요: ${message}" \
    --step tag-validation || true

  exit 1
}

echo "Validate deployment tag started"

branch="${BRANCH:-${GITHUB_REF_NAME:-}}"

case "$branch" in
  dev/*)
    [[ "$branch" =~ ^dev/[0-9]+(\.[0-9]+){2}-[0-9]{10}$ ]] || die "invalid dev tag format: $branch"
    ;;
  prod/*)
    [[ "$branch" =~ ^prod/[0-9]+(\.[0-9]+){2}-[0-9]{10}$ ]] || die "invalid prod tag format: $branch"
    ;;
  demo/*/*)
    [[ "$branch" =~ ^demo/[^/]+/[0-9]+(\.[0-9]+){2}-[0-9]{10}$ ]] || die "invalid demo tag format: $branch"
    [[ "$branch" != demo/DesignSystemDemo/* ]] || die "DesignSystemDemo must use design tag prefix: $branch"
    ;;
  design/*)
    [[ "$branch" =~ ^design/[0-9]+(\.[0-9]+){2}-[0-9]{10}$ ]] || die "invalid design tag format: $branch"
    ;;
  *)
    die "unsupported tag prefix: $branch"
    ;;
esac

echo "Validate deployment tag succeeded"
