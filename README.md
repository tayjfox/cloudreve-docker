# Cloudreve Docker

![](https://img.shields.io/github/actions/workflow/status/xavier-niu/cloudreve-docker/dockerhub.yml) ![](https://img.shields.io/docker/v/vedla/cloudreve/latest) ![](https://img.shields.io/docker/image-size/vedla/cloudreve/latest) ![](https://img.shields.io/docker/pulls/vedla/cloudreve) ![](https://img.shields.io/badge/maintainer-vedla-lightgrey)

Advantages

- Based on [Cloudreve V4](https://github.com/cloudreve/Cloudreve)
- Long-term maintenance
- Multiple version tags available, so you can pin the exact Cloudreve release you want
- Debian Bookworm slim runtime, built from the official prebuilt binaries
- Multi-architecture support (amd64, arm64, arm/v7)
- Easy to set up
- Optional Aria2 support for offline downloads (no separate container required when enabled)
- Detailed Cloudreve + Nginx deployment guide included

## Available tags

- `<version>` (e.g. `4.17.0`): a specific pinned Cloudreve v4 release
- `4`: always points at the newest Cloudreve v4 release published by this project
- `latest`: same as `4`

See the full list of published versions on [Docker Hub](https://hub.docker.com/r/vedla/cloudreve/tags).

## Getting started

Directories

- `<PATH TO data>`: data directory that stores the config, database, avatars, uploads, and Aria2 downloads, e.g. `/dockercnf/cloudreve/data`

Create the data directory

```bash
mkdir -p <PATH TO data>
```

Build an ARMv7 image locally

```bash
docker buildx build --platform linux/arm/v7 \
  --build-arg CLOUDREVE_VERSION=4.17.0 \
  --build-arg INSTALL_ARIA2=0 \
  -t cloudreve:armv7 \
  --load .
```

Start the Cloudreve container

```bash
docker run -d \
  --name cloudreve \
  -e TZ="America/Toronto" \
  -e CR_ENABLE_ARIA2=0 \
  -p 5212:5212 \
  --restart=unless-stopped \
  -v <PATH TO data>:/cloudreve/data \
  cloudreve:armv7
```

Notes

- Open `http://<your server>:5212` and register the first account — it is automatically made the site administrator (Cloudreve v4 no longer prints a generated admin password to the logs like v3 did).
- `TZ` sets the container's timezone. Defaults to `America/Toronto` if not set.
- Aria2 is not required for normal Cloudreve file browsing, uploads, and downloads. Enable it only if you use Cloudreve's offline/remote download feature; build with `INSTALL_ARIA2=1`, run with `CR_ENABLE_ARIA2=1`, and publish `6888/tcp` plus `6888/udp`.
- To pin a specific Cloudreve version instead of the newest one, use an explicit tag, e.g. `vedla/cloudreve:4.17.0`.

Troubleshooting ARMv7 NAS startup (`libc.so.6: ELF load command address/offset not page-aligned`)

- Some older ARMv7 NAS kernels/runtimes fail with Debian Bookworm userland.
- Rebuild with Debian Bullseye for compatibility:

```bash
docker compose build --build-arg DEBIAN_SUITE=bullseye --no-cache cloudreve
docker compose up -d
```

- Or set `DEBIAN_SUITE=bullseye` in your `.env` to keep using Bullseye on future builds.

Other guides

- If you want to use Nginx as a reverse proxy, see [Cloudreve Docker - Nginx](https://github.com/vedla/cloudreve-docker/blob/master/README-NAC.md).
- If you'd rather start the service with docker-compose, see [Cloudreve Docker - Docker Compose](https://github.com/vedla/cloudreve-docker/blob/master/README-DOCKER-COMPOSE.md).
- If you want to run the service remotely in the cloud, see [Cloudreve Docker - TeamCode](https://github.com/vedla/cloudreve-docker/blob/master/README-TEAMCODE.md) (free usage time is limited per month; usage beyond that is billed).

## Upgrading

Stop and remove the running container, then pull the new image

```bash
docker stop cloudreve \
  && docker rm cloudreve \
  && docker pull vedla/cloudreve
```

Repeat the run steps above to start the container again.
