#!/usr/bin/env bash
# Deploys a packaged build to DEPLOY_DIR and (re)starts the app in the background.
# Usage: scripts/deploy.sh <path-to-tar.gz> [version]
set -euo pipefail

ARTIFACT="${1:?usage: deploy.sh <artifact.tar.gz> [version]}"
VERSION="${2:-dev}"
DEPLOY_DIR="${DEPLOY_DIR:-$HOME/deployments/sample-app}"
PORT="${PORT:-8000}"

echo ">> Deploying $ARTIFACT (version $VERSION) to $DEPLOY_DIR on port $PORT"

# Stop the previous release if it is still running
if [[ -f "$DEPLOY_DIR/app.pid" ]] && kill -0 "$(cat "$DEPLOY_DIR/app.pid")" 2>/dev/null; then
    echo ">> Stopping previous release (pid $(cat "$DEPLOY_DIR/app.pid"))"
    kill "$(cat "$DEPLOY_DIR/app.pid")"
    sleep 1
fi

mkdir -p "$DEPLOY_DIR/releases/$VERSION"
tar -xzf "$ARTIFACT" -C "$DEPLOY_DIR/releases/$VERSION"
ln -sfn "$DEPLOY_DIR/releases/$VERSION" "$DEPLOY_DIR/current"

cd "$DEPLOY_DIR/current"
APP_VERSION="$VERSION" PORT="$PORT" nohup python3 app/app.py > "$DEPLOY_DIR/app.log" 2>&1 &
echo $! > "$DEPLOY_DIR/app.pid"

echo ">> Started pid $(cat "$DEPLOY_DIR/app.pid"), logs at $DEPLOY_DIR/app.log"
