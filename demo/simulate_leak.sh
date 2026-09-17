#!/usr/bin/env bash
# Show the scanner catching a documented fake key.
# The file is created in a temp dir and deleted. Nothing is committed.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

FAKE="$TMP/oops.env"
cat > "$FAKE" <<'EOF'
# Documented AWS example credentials — not real, still a scanner hit.
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
EOF

echo "Wrote a temporary fake secret at $FAKE"
echo "Running gitleaks against that file only..."
echo

run_gitleaks() {
  if command -v gitleaks >/dev/null 2>&1; then
    gitleaks detect --no-git --source "$TMP" --verbose
    return $?
  fi
  if command -v docker >/dev/null 2>&1; then
    docker run --rm -v "$TMP":/scan zricethezav/gitleaks:v8.28.0 detect --no-git --source /scan --verbose
    return $?
  fi
  echo "Neither gitleaks nor docker is installed."
  echo "Install one of:"
  echo "  brew install gitleaks"
  echo "  pip install pre-commit && pre-commit run --all-files"
  echo "  https://github.com/gitleaks/gitleaks/releases"
  return 2
}

set +e
run_gitleaks
STATUS=$?
set -e

echo
if [[ "$STATUS" -eq 1 ]]; then
  echo "Expected result: scanner blocked the fake key."
  echo "That is the same check the pre-commit hook runs on git commit."
  exit 0
elif [[ "$STATUS" -eq 0 ]]; then
  echo "Scanner reported clean. Unexpected for this fixture."
  exit 1
else
  echo "Could not run the scanner (missing binary)."
  exit "$STATUS"
fi
