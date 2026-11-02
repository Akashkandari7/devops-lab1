#!/usr/bin/env bash
# Polls the deployed app's /health endpoint and checks it reports the expected version.
# Usage: scripts/smoke_test.sh [expected-version]
set -euo pipefail

EXPECTED="${1:-}"
URL="http://localhost:${PORT:-8000}/health"

for i in $(seq 1 10); do
    if body=$(curl -fsS "$URL"); then
        echo ">> $URL -> $body"
        if [[ -n "$EXPECTED" && "$body" != *"\"version\": \"$EXPECTED\""* ]]; then
            echo "!! Expected version $EXPECTED but got: $body"
            exit 1
        fi
        echo ">> Smoke test passed"
        exit 0
    fi
    echo ".. attempt $i: app not ready yet, retrying"
    sleep 1
done

echo "!! Smoke test failed: $URL never became healthy"
exit 1
