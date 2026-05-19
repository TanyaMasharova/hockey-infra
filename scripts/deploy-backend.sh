#!/bin/sh
set -e

TAG=${1:?usage: deploy-backend.sh <tag>}
COMPOSE_FILE="$(dirname "$0")/../compose.prod.yml"
ENV_FILE="$(dirname "$0")/../.env"

sed -i "s/^BACKEND_TAG=.*/BACKEND_TAG=${TAG}/" "$ENV_FILE"

docker compose -f "$COMPOSE_FILE" pull backend
docker compose -f "$COMPOSE_FILE" up --force-recreate --no-deps migrate
docker compose -f "$COMPOSE_FILE" up -d --no-deps backend
