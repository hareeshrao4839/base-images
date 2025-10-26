FROM eclipse-temurin:17.0.16_8-jdk-alpine-3.22
LABEL maintainer="hareesh <hareesh.uk4839@gmail.com>"

ENV LANG='en_US.UTF-8'
ENV LANGUAGE='en_US:en'
ENV LC_ALL='en_US.UTF-8'
ENV JAVA_HOME=/opt/java/openjdk
ENV JAVA_VERSION=jdk-17.0.16+8
ENV PATH=$JAVA_HOME/bin:$PATH
RUN set -eux; \
    apk update && apk upgrade && \
    apk add --no-cache \
        fontconfig ttf-dejavu \
        gnupg \
        ca-certificates p11-kit-trust \
        musl-locales musl-locales-lang \
        tzdata \
        coreutils \
        openssl \
        busybox-extras \
        bash \
        coreutils \
        curl \
        yq
RUN addgroup -g 1010 appuser \
    && adduser -u 1010 -G appuser -s /bin/sh -D appuser
USER 1010