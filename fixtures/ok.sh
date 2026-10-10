#!/bin/bash
# Fixture for static.yml: must pass bash -n and shellcheck at error severity.
set -euo pipefail
name="${1:-ci-workflows}"
printf 'ok: %s\n' "$name"
