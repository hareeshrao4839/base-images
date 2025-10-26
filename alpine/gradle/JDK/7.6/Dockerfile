FROM alpine:3.20
LABEL maintainer="hareesh <hareesh.uk4839@gmail.com>"

ENV JAVA_HOME=/usr/lib/jvm/default-jvm \
    PATH=${JAVA_HOME}/bin:$PATH \
    LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8' \
    GRADLE_HOME=/opt/gradle

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

RUN set -o errexit -o nounset \
    && echo "Installing VCSes" \
    && apk add --no-cache \
      git \
      git-lfs \
      mercurial \
      subversion \
    \
    && echo "Testing VCSes" \
    && which git \
    && which git-lfs \
    && which hg \
    && which svn

RUN apk add --no-cache openjdk17-jdk

RUN set -eux; \
    echo "Verifying install ..."; \
    fileEncoding="$(echo 'System.out.println(System.getProperty("file.encoding"))' | jshell -s -)"; [ "$fileEncoding" = 'UTF-8' ]; rm -rf ~/.java; \
    echo "javac --version"; javac --version; \
    echo "java --version"; java --version; \
    # echo "keytool --version"; keytool --version; \
    echo "Completed Installation." ; \
    echo "Removing Cache. \n "
COPY --chmod=755 entrypoint.sh /entrypoint.sh
#########GRADLE######
RUN set -o errexit -o nounset \
    && echo "Adding gradle user and group" \
    && addgroup --system --gid 1010 gradle \
    && adduser --system --ingroup gradle --uid 1010 --shell /bin/ash gradle \
    && mkdir /home/gradle/.gradle \
    && chown -R gradle:gradle /home/gradle \
    && chmod -R o+rwx /home/gradle \
    \
    && echo "Symlinking root Gradle cache to gradle Gradle cache" \
    && ln -s /home/gradle/.gradle /root/.gradle

VOLUME /home/gradle/.gradle

WORKDIR /home/gradle

ENV GRADLE_VERSION 7.6.4
ARG GRADLE_DOWNLOAD_SHA256=bed1da33cca0f557ab13691c77f38bb67388119e4794d113e051039b80af9bb1
RUN set -o errexit -o nounset \
    && echo "Downloading Gradle" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    \
    && echo "Checking Gradle download hash" \
    && echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum -c - \
    \
    && echo "Installing Gradle" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
    && ln -s "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle

RUN set -o errexit -o nounset \
    && echo "Testing Gradle installation" \
    && gradle --version &&  rm -rf /var/cache/apk/*

ENTRYPOINT ["/entrypoint.sh"]
USER 1010
CMD ["gradle"]