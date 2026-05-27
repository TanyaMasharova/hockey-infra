#!/bin/sh
set -e

TAG=${1:?usage: deploy-backend.sh <tag>}
TAG=${TAG#v}
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
COMPOSE_FILE="$REPO_DIR/compose.prod.yml"
ENV_FILE="$REPO_DIR/.env"

git -C "$REPO_DIR" pull

sed -i "s/^BACKEND_TAG=.*/BACKEND_TAG=${TAG}/" "$ENV_FILE"

docker compose -f "$COMPOSE_FILE" pull backend
docker compose -f "$COMPOSE_FILE" up --force-recreate --no-deps migrate
docker compose -f "$COMPOSE_FILE" up -d --no-deps backend
