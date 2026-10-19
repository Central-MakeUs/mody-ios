#!/usr/bin/env bash

set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

exec mise exec -- python3 Scripts/Python/run_tests.py \
  --destination auto \
  --derived-data "$RUNNER_TEMP/mody-test-derived"
