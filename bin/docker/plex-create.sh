#!/usr/bin/env bash

set -e

docker run \
  -d \
  --name plex \
  --net host \
  --gpus all \
  -e PUID=$(id -u plex) \
  -e PGID=$(id -g plex) \
  -e VERSION=latest \
  -v plex_config:/config \
  -v plex_media:/media \
  -v plex_music:/music \
  -v plex_published:/published \
  -v /bulk/plex:/bulk \
  --tmpfs /transcode \
  --restart always \
  linuxserver/plex
