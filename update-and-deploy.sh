#!/usr/bin/env bash
set -euo pipefail

# optional: adjust to your compose file dir
# cd /path/to/project

REMOTE="${DEPLOY_REMOTE:-upstream}"
BRANCH="${DEPLOY_BRANCH:-main}"

current_branch=$(git rev-parse --abbrev-ref HEAD)
if [[ "$current_branch" != "$BRANCH" ]]; then
  echo "Current branch is '$current_branch' but DEPLOY_BRANCH is '$BRANCH'. Refusing to pull to avoid an unintended merge."
  exit 1
fi

echo "Fetching latest from ${REMOTE}/${BRANCH}..."
git fetch "$REMOTE" "$BRANCH"

head_before=$(git rev-parse HEAD)

echo "Pulling changes from ${REMOTE}/${BRANCH}..."
git pull --ff-only "$REMOTE" "$BRANCH"

head_after=$(git rev-parse HEAD)

if [[ "$head_before" == "$head_after" ]]; then
  echo "No updates found. Skipping docker compose."
  exit 0
fi

echo "Changes detected. Rebuilding/running docker compose..."
docker compose up --build -d

echo "Done."
