#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  send_slack.sh --status <status> --message <message> --step <step> [--dry-run]

Required:
  --status       CI/CD step status. Example: started, success, failure
  --message      Human-readable message. Example: Pre-Build completed
  --step         CI/CD step name. Example: pre-build, tests, distribution

Options:
  --dry-run      Print payload without sending to Slack
  --help         Show this help

Environment:
  SLACK_WEBHOOK_URL is required unless --dry-run is used.
USAGE
}

die() {
  echo "send_slack.sh: $*" >&2
  exit 1
}

status="${STATUS:-}"
message="${MESSAGE:-}"
step="${STEP:-}"
workflow="${WORKFLOW:-${GITHUB_WORKFLOW:-}}"
job="${JOB:-${GITHUB_JOB:-}}"
branch="${CICD_BRANCH:-${BRANCH:-${GITHUB_REF_NAME:-}}}"
scheme="${CICD_SCHEME:-${SCHEME:-unknown}}"
environment="${CICD_ENVIRONMENT:-${ENVIRONMENT:-unknown}}"
version_display="${CICD_VERSION_DISPLAY:-}"
dry_run=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --status)
      [[ $# -ge 2 ]] || die "--status requires a value"
      status="$2"
      shift 2
      ;;
    --message)
      [[ $# -ge 2 ]] || die "--message requires a value"
      message="$2"
      shift 2
      ;;
    --step)
      [[ $# -ge 2 ]] || die "--step requires a value"
      step="$2"
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

[[ -n "$status" ]] || die "--status is required"
[[ -n "$message" ]] || die "--message is required"
[[ -n "$step" ]] || die "--step is required"

if [[ -z "$branch" ]] && command -v git >/dev/null 2>&1; then
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
fi

workflow="${workflow:-local}"
job="${job:-local}"
branch="${branch:-unknown}"
scheme="${scheme:-unknown}"
environment="${environment:-unknown}"
version_display="${version_display:-unknown}"
datetime="$(TZ=Asia/Seoul date '+%Y-%m-%d %H:%M KST')"

make_payload() {
  if command -v python3 >/dev/null 2>&1; then
    STATUS="$status" \
    MESSAGE="$message" \
    STEP="$step" \
    WORKFLOW="$workflow" \
    JOB="$job" \
    BRANCH="$branch" \
    SCHEME="$scheme" \
    ENVIRONMENT="$environment" \
    VERSION_DISPLAY="$version_display" \
    DATETIME="$datetime" \
      python3 - <<'PY'
import json
import os

status = os.environ["STATUS"].lower()
message = os.environ["MESSAGE"]
step = os.environ["STEP"]

status_labels = {
    "started": "Started",
    "success": "Success",
    "succeeded": "Success",
    "completed": "Success",
    "failure": "Failure",
    "failed": "Failure",
    "error": "Failure",
    "cancelled": "Cancelled",
    "canceled": "Cancelled",
}

status_icons = {
    "started": ":rocket:",
    "success": ":white_check_mark:",
    "succeeded": ":white_check_mark:",
    "completed": ":white_check_mark:",
    "failure": ":x:",
    "failed": ":x:",
    "error": ":x:",
    "cancelled": ":stop_button:",
    "canceled": ":stop_button:",
}

label = status_labels.get(status, os.environ["STATUS"])
icon = status_icons.get(status, ":information_source:")
title = f"{icon} Mody CI/CD {label}"

fields = [
    ("Status", label),
    ("Message", message),
    ("Step", step),
    ("Workflow", os.environ["WORKFLOW"]),
    ("Job", os.environ["JOB"]),
    ("Target", os.environ["SCHEME"]),
    ("Environment", os.environ["ENVIRONMENT"]),
    ("Version", os.environ["VERSION_DISPLAY"]),
    ("Tag/Branch", os.environ["BRANCH"]),
    ("Time", os.environ["DATETIME"]),
]

payload = {
    "text": f"{title}: {message}",
    "blocks": [
        {
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": title,
                "emoji": True,
            },
        },
        {
            "type": "section",
            "fields": [
                {
                    "type": "mrkdwn",
                    "text": f"*{name}:*\n{value or 'unknown'}",
                }
                for name, value in fields
            ],
        },
    ],
}

print(json.dumps(payload, ensure_ascii=False))
PY
    return
  fi

  die "python3 is required to build the Slack JSON payload"
}

payload="$(make_payload)"

if [[ "$dry_run" == true ]]; then
  printf '%s\n' "$payload"
  exit 0
fi

[[ -n "${SLACK_WEBHOOK_URL:-}" ]] || die "SLACK_WEBHOOK_URL is required"

curl \
  --fail \
  --silent \
  --show-error \
  --request POST \
  --header "Content-Type: application/json" \
  --data "$payload" \
  "$SLACK_WEBHOOK_URL" >/dev/null

echo "Slack notification sent"
