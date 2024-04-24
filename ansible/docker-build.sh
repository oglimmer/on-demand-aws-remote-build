#!/bin/bash

set -eu

docker build --tag registry.oglimmer.com/picz-be:latest picz/backend 
docker build --tag registry.oglimmer.com/picz-fe:latest -f picz/frontend/Dockerfile-prod picz/frontend

docker push registry.oglimmer.com/picz-be:latest
docker push registry.oglimmer.com/picz-fe:latest
