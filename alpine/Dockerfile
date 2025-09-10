FROM alpine:3.22

LABEL maintainer="hareesh <hareesh.uk4839@gmail.com>"


ARG UID=1010
ARG GID=1010

# install prerequisites for public key and pkg-oss checks
RUN addgroup -g $GID -S appuser || true \
    && adduser -S -D -H -u $UID -h /var/cache/appuser -s /sbin/nologin -G appuser -g appuser appuser || true \
    && apk --no-cache upgrade && apk --no-cache add \
                binutils-gold \
                libstdc++ \
                g++ \
                gnupg \
                libgcc \
                gcc \
                libc-dev \
                pcre2-dev \
                zlib-dev \
                linux-headers \
                bash \
                alpine-sdk \
                findutils \
                curl \
                openssl \
                traceroute \
                busybox-extras \
                ca-certificates \
                yq \
                autoconf \
                automake \
                bzip2 \
                build-base \
                file \
                imagemagick \
                libbz2 \
                curl-dev \
                db-dev \
                libevent-dev \
                libffi-dev \
                gdbm-dev \
                glib-dev \
                gmp-dev \
                jpeg-dev \
                krb5-dev \
                xz-dev \
                libmaxminddb-dev \
                ncurses-dev \
                libpng-dev \
                postgresql-dev \
                readline-dev \
                sqlite-dev \
                openssl-dev \
                libtool \
                libwebp-dev \
                libxml2-dev \
                libxslt-dev \
                yaml-dev \
                make \
                patch \
                unzip \
                zlib-dev
RUN apk add --no-cache curl tar && \
                HELM_VERSION="v3.14.0" && \
                curl -L https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -xz && \
                mv linux-amd64/helm /usr/local/bin/helm && \
                rm -rf linux-amd64                          
USER $UID