ARG BUILD_FROM=ghcr.io/hassio-addons/base:stable
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set S6 wait time
ENV S6_CMD_WAIT_FOR_SERVICES=1 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    S6_SERVICES_GRACETIME=0

ENV LANG C.UTF-8

ENV APP_DIR "/app"

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
# hadolint ignore=DL3003
# Install app dependencies

RUN apk -U update
RUN apk -U upgrade
RUN apk -U add --no-cache \
    ipmitool
RUN apk -U add --no-cache \
    nginx

RUN apk -U add --no-cache \
    php \
    php-fpm \
    php-curl \
    php-dom \
    php-gettext \
    php-xml \
    php-simplexml \
    php-zip \
    php-zlib \
    php-gd \
    php-openssl \
    php-json \
    php-mbstring \
    php-ctype \
    php-opcache \
    php-session \
    php-tokenizer

RUN mkdir -p /app \
    && mkdir /app/cache \
    && mkdir /var/tmp/nginx

# Copy root filesystem
COPY rootfs /

# Corrects permissions for /app directory
RUN if [ -d /app ]; then chown -R nginx /app; fi
RUN chown -R nginx /var/lib/nginx
RUN chmod -R 777 /var/lib/nginx

# Corrects permissions for s6 v3
RUN if [ -d /etc/cont-init.d ]; then chmod -R 755 /etc/cont-init.d; fi && \
    if [ -d /etc/services.d ]; then chmod -R 755 /etc/services.d; fi && \
    if [ -f /entrypoint.sh ]; then chmod 755 /entrypoint.sh; fi

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION
ARG BUILD_REPOSITORY="MNeverOff/ipmi-server"

LABEL \
    maintainer="Mike Neverov <mike@neveroff.dev>" \
    org.opencontainers.image.title="IPMI Server for Docker" \
    org.opencontainers.image.description="Standalone ipmi server docker container with a Symfony app from @ateodorescu" \
    org.opencontainers.image.vendor="Mike Neverov" \
    org.opencontainers.image.authors="Mike Neverov <mike@neveroff.dev>, Adrian Teodorescu <ateodorescu@gmail.com>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://neveroff.dev" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
