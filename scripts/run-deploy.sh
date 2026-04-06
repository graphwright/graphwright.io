#!/bin/bash -xe

docker build -t my-runner .
#CONTAINER=$(docker run -d --privileged --env-file .env my-runner sleep infinity)
CONTAINER=$(docker run -d --env-file .env my-runner sleep infinity)
docker exec -t "$CONTAINER" bash -xe /deploy.sh
IMAGE_NAME="gwio-$(date -u +%Y%m%d_%H%M%S)"
docker commit "$CONTAINER" "$IMAGE_NAME"

docker rm -f "$CONTAINER"
CONTAINER=$(docker run -d --privileged --env-file .env "$IMAGE_NAME" sleep infinity)

# docker exec -it -w /graphwright.io "$CONTAINER" uv add mkdocs
# docker exec -it -w /graphwright.io "$CONTAINER" mkdocs build --config-file docs/mkdocs.yml
# docker compose --profile api up

docker exec -it "$CONTAINER" apt install -y ripgrep curl git vim

docker exec -it -w /docs "$CONTAINER" uv sync
docker exec -it -w /docs "$CONTAINER" .venv/bin/mkdocs build

docker exec -it -w /graphwright.io "$CONTAINER" bash --login
