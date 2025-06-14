FROM ubuntu:24.04

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8' \
    JAVA_VERSION=jdk-17.0.13+11 \
    GRADLE_HOME=/opt/gradle \
    GRADLE_VERSION=7.6.4 \
    UID=1010 \
    USER=app-user

RUN set -eux; \
    apt-get update; \
    apt-get upgrade; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl \
        wget \
        gnupg \
        fontconfig \
        ca-certificates p11-kit \
        binutils \
        tzdata \
        locales \
        fonts-dejavu-core \
    ; \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; \
    locale-gen en_US.UTF-8; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       amd64) \
         ESUM='8682892fc02965930b9022c066fa164dd6f458ef4a5dc262016aa28333b30f49'; \
         BINARY_URL='https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%2B11/OpenJDK17U-jdk_x64_linux_hotspot_17.0.13_11.tar.gz'; \
         ;; \
       arm64) \
         ESUM='0c17fa4f14c0d2cc9e9334f996fccdddc5da4459d768f3105c7ff0283c47bf62'; \
         BINARY_URL='https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%2B11/OpenJDK17U-jdk_aarch64_linux_hotspot_17.0.13_11.tar.gz'; \
         ;; \
       armhf) \
         ESUM='e69d43be937e05dbccae4cc98f732ed86aa11993234bf5ad6e81c30475a78ce7'; \
         BINARY_URL='https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%2B11/OpenJDK17U-jdk_arm_linux_hotspot_17.0.13_11.tar.gz'; \
         ;; \
       ppc64el) \
         ESUM='d4e553c6fa7afdfe2577420c6e77a558db8113a3cef84e755384148f5610834e'; \
         BINARY_URL='https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%2B11/OpenJDK17U-jdk_ppc64le_linux_hotspot_17.0.13_11.tar.gz'; \
         ;; \
       riscv64) \
         ESUM='e7c82833a7381a05cae2be0e947c08e971bbae4f2e4142c6ec87bbd7530a5646'; \
         BINARY_URL='https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%2B11/OpenJDK17U-jdk_riscv64_linux_hotspot_17.0.13_11.tar.gz'; \
         ;; \
       s390x) \
         ESUM='1f824d7369dfd570dc561e2a56035fdcd2970c97cbd355f6deb6ed0e7c6bcb79'; \
         BINARY_URL='https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%2B11/OpenJDK17U-jdk_s390x_linux_hotspot_17.0.13_11.tar.gz'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    wget --progress=dot:giga -O /tmp/openjdk.tar.gz ${BINARY_URL}; \
    wget --progress=dot:giga -O /tmp/openjdk.tar.gz.sig ${BINARY_URL}.sig; \
    export GNUPGHOME="$(mktemp -d)"; \
    # gpg: key 843C48A565F8F04B: "Adoptium GPG Key (DEB/RPM Signing Key) <temurin-dev@eclipse.org>" imported
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 3B04D753C9050D9A5D343F39843C48A565F8F04B; \
    gpg --batch --verify /tmp/openjdk.tar.gz.sig /tmp/openjdk.tar.gz; \
    rm -r "${GNUPGHOME}" /tmp/openjdk.tar.gz.sig; \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p "$JAVA_HOME"; \
    tar --extract \
        --file /tmp/openjdk.tar.gz \
        --directory "$JAVA_HOME" \
        --strip-components 1 \
        --no-same-owner \
    ; \
    rm -f /tmp/openjdk.tar.gz ${JAVA_HOME}/lib/src.zip; \
    find "$JAVA_HOME/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf; \
    ldconfig; \
    java -Xshare:dump;

RUN set -eux; \
    echo "Verifying install ..."; \
    fileEncoding="$(echo 'System.out.println(System.getProperty("file.encoding"))' | jshell -s -)"; [ "$fileEncoding" = 'UTF-8' ]; rm -rf ~/.java; \
    echo "javac --version"; javac --version; \
    echo "java --version"; java --version; \
    echo "Complete."
COPY --chmod=755 entrypoint.sh /__cacert_entrypoint.sh
RUN adduser \
    --disabled-password \
	--gecos "" \
	--no-create-home \
	--uid "$UID" \
	--shell "/bin/bash" \
	$USER && \
  chmod 755 /__cacert_entrypoint.sh \
  && apt-get remove wget -y 
  # && rm -rf /var/cache/apt/archives /var/lib/apt/lists
ENTRYPOINT ["/__cacert_entrypoint.sh"]

### gradle installation
RUN set -o errexit -o nounset \
    && echo "Adding gradle user and group" \
    && groupadd --system --gid 1020 gradle \
    && useradd --system --gid gradle --uid 1020 --shell /bin/bash --create-home gradle \
    && mkdir /home/gradle/.gradle \
    && chown --recursive gradle:gradle /home/gradle \
    && chmod --recursive o+rwx /home/gradle \
    \
    && echo "Symlinking root Gradle cache to gradle Gradle cache" \
    && ln --symbolic /home/gradle/.gradle /root/.gradle

VOLUME /home/gradle/.gradle

WORKDIR /home/gradle

RUN set -o errexit -o nounset \
    && apt-get update \
    && apt-get install --yes --no-install-recommends \
        unzip \
        wget \
        \
        bzr \
        git \
        git-lfs \
        mercurial \
        openssh-client \
        subversion \
    && rm --recursive --force /var/lib/apt/lists/* \
    \
    && echo "Testing VCSes" \
    && which bzr \
    && which git \
    && which git-lfs \
    && which hg \
    && which svn

ENV GRADLE_VERSION 7.6.4
ARG GRADLE_DOWNLOAD_SHA256=bed1da33cca0f557ab13691c77f38bb67388119e4794d113e051039b80af9bb1
RUN set -o errexit -o nounset \
    && echo "Downloading Gradle" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    \
    && echo "Checking Gradle download hash" \
    && echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum --check - \
    \
    && echo "Installing Gradle" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
    && ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle \
    && apt-get remove wget unzip -y \
    && rm -rf /var/cache/apt/archives /var/lib/apt/lists

USER 1020

RUN set -o errexit -o nounset \
    && echo "Testing Gradle installation" \
    && gradle --version

CMD ["gradle"]