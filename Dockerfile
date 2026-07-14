# syntax=docker/dockerfile:1

# Stage 1: fetch the official prebuilt Cloudreve v4 binary for the target platform.
FROM alpine:latest AS downloader

ARG CLOUDREVE_VERSION
ARG TARGETARCH
ARG TARGETVARIANT

WORKDIR /download

RUN apk add --no-cache curl tar

RUN set -eux; \
    case "${TARGETARCH}${TARGETVARIANT}" in \
      "amd64") CR_ARCH="amd64" ;; \
      "arm64") CR_ARCH="arm64" ;; \
      "armv7") CR_ARCH="armv7" ;; \
      "armv6") CR_ARCH="armv6" ;; \
      *) echo "Unsupported platform: ${TARGETARCH}${TARGETVARIANT}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o cloudreve.tar.gz \
      "https://github.com/cloudreve/Cloudreve/releases/download/${CLOUDREVE_VERSION}/cloudreve_${CLOUDREVE_VERSION}_linux_${CR_ARCH}.tar.gz"; \
    tar -xzf cloudreve.tar.gz; \
    find . -maxdepth 2 -type f -name cloudreve -exec mv {} /download/cloudreve-bin \;

# Stage 2: runtime image, mirrors upstream's own Dockerfile plus a build-time default timezone.
FROM alpine:latest

ARG CLOUDREVE_VERSION
ENV TZ="America/Toronto"

LABEL maintainer="Xavier Niu"
LABEL org.opencontainers.image.source="https://github.com/xavier-niu/cloudreve-docker"
LABEL org.opencontainers.image.version="${CLOUDREVE_VERSION}"

WORKDIR /cloudreve

RUN apk update \
    && apk add --no-cache tzdata vips-tools ffmpeg libreoffice aria2 supervisor font-noto font-noto-cjk libheif libraw-tools \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && mkdir -p ./data/temp/aria2 \
    && chmod -R 766 ./data/temp/aria2

ENV CR_ENABLE_ARIA2=1 \
    CR_SETTING_DEFAULT_thumb_ffmpeg_enabled=1 \
    CR_SETTING_DEFAULT_thumb_vips_enabled=1 \
    CR_SETTING_DEFAULT_thumb_libreoffice_enabled=1 \
    CR_SETTING_DEFAULT_media_meta_ffprobe=1 \
    CR_SETTING_DEFAULT_thumb_libraw_enabled=1

COPY aria2.supervisor.conf entrypoint.sh ./
COPY --from=downloader /download/cloudreve-bin ./cloudreve

RUN chmod +x ./cloudreve ./entrypoint.sh

EXPOSE 5212 6888 6888/udp

VOLUME ["/cloudreve/data"]

ENTRYPOINT ["sh", "./entrypoint.sh"]
