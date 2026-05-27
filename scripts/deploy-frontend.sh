#!/bin/sh
set -e

TAG=${1:?usage: deploy-frontend.sh <tag>}
TAG=${TAG#v}
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
COMPOSE_FILE="$REPO_DIR/compose.prod.yml"
ENV_FILE="$REPO_DIR/.env"

git -C "$REPO_DIR" pull

sed -i "s/^FRONTEND_TAG=.*/FRONTEND_TAG=${TAG}/" "$ENV_FILE"

docker compose -f "$COMPOSE_FILE" pull frontend
docker compose -f "$COMPOSE_FILE" up -d --no-deps frontend
