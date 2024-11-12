FROM alpine:3.20
LABEL maintainer="hareesh <hareesh.uk4839@gmail.com>"

ENV JAVA_HOME=/usr/lib/jvm/default-jvm \
    PATH=${JAVA_HOME}/bin:$PATH \
    LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8'

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
        coreutils

RUN apk add --no-cache openjdk17-jdk

RUN set -eux; \
    echo "Verifying install ..."; \
    fileEncoding="$(echo 'System.out.println(System.getProperty("file.encoding"))' | jshell -s -)"; [ "$fileEncoding" = 'UTF-8' ]; rm -rf ~/.java; \
    echo "javac --version"; javac --version; \
    echo "java --version"; java --version; \
    # echo "keytool --version"; keytool --version; \
    echo "Completed Installation." ; \
    echo "Removing Cache. \n " ; \
    rm -rf /var/cache/apk/*
COPY --chmod=755 entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

USER 1000
CMD ["jshell"]

