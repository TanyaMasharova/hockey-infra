#!/bin/sh
set -e

TAG=${1:?usage: deploy-frontend.sh <tag>}
COMPOSE_FILE="$(dirname "$0")/../compose.prod.yml"
ENV_FILE="$(dirname "$0")/../.env"

sed -i "s/^FRONTEND_TAG=.*/FRONTEND_TAG=${TAG}/" "$ENV_FILE"

docker compose -f "$COMPOSE_FILE" pull frontend
docker compose -f "$COMPOSE_FILE" up -d --no-deps frontend
