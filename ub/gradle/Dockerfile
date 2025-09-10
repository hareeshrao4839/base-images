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
    apt-get update -y ; \
    apt-get upgrade -y ; \
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
        openssl \
        bash \
        busybox \
        net-tools \
        traceroute \
        dnsutils \        
    ; \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; \
    locale-gen en_US.UTF-8;

ENV JAVA_VERSION=jdk-17.0.16+8

RUN set -eux; \
            ARCH="$(dpkg --print-architecture)"; \
            case "${ARCH}" in \
               amd64) \
                 ESUM='166774efcf0f722f2ee18eba0039de2d685b350ee14d7b69e6f83437dafd2af1'; \
                 BINARY_URL='https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.16%2B8/OpenJDK17U-jdk_x64_linux_hotspot_17.0.16_8.tar.gz'; \
                 ;; \
               arm64) \
                 ESUM='423416447885d9e45f96dd9e0b2c1367da5e1b0353e187cfdf9388c9820ac147'; \
                 BINARY_URL='https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.16%2B8/OpenJDK17U-jdk_aarch64_linux_hotspot_17.0.16_8.tar.gz'; \
                 ;; \
               armhf) \
                 ESUM='bc8ba665df25378cfca76b2d2ca6821ba32c4d45934aa5beea5b542d6658f5d6'; \
                 BINARY_URL='https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.16%2B8/OpenJDK17U-jdk_arm_linux_hotspot_17.0.16_8.tar.gz'; \
                 ;; \
               ppc64el) \
                 ESUM='eb020f74e00870379522be0b44fc6322c2214e77971c258400c8b5af704d5c0a'; \
                 BINARY_URL='https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.16%2B8/OpenJDK17U-jdk_ppc64le_linux_hotspot_17.0.16_8.tar.gz'; \
                 ;; \
               riscv64) \
                 ESUM='42cc01235222a27576de8331a532da200ce36c9d155c93e9e0b4d565dcaf684a'; \
                 BINARY_URL='https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.16%2B8/OpenJDK17U-jdk_riscv64_linux_hotspot_17.0.16_8.tar.gz'; \
                 ;; \
               s390x) \
                 ESUM='03dd99d34d2d1b88395765df3acbec2cb81de286f64b1d9e6df3682bee365168'; \
                 BINARY_URL='https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.16%2B8/OpenJDK17U-jdk_s390x_linux_hotspot_17.0.16_8.tar.gz'; \
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
            rm -rf "${GNUPGHOME}" /tmp/openjdk.tar.gz.sig; \
            echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
            mkdir -p "$JAVA_HOME"; \
            tar --extract \
                --file /tmp/openjdk.tar.gz \
                --directory "$JAVA_HOME" \
                --strip-components 1 \
                --no-same-owner \
            ; \
            rm -f /tmp/openjdk.tar.gz ${JAVA_HOME}/lib/src.zip; \
            # https://github.com/docker-library/openjdk/issues/331#issuecomment-498834472
            find "$JAVA_HOME/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf; \
            ldconfig; \
            # https://github.com/docker-library/openjdk/issues/212#issuecomment-420979840
            # https://openjdk.java.net/jeps/341
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
        subversion \
    && rm --recursive --force /var/lib/apt/lists/* \
    \
    && echo "Testing VCSes" \
    && which bzr \
    && which git \
    && which git-lfs \
    && which hg \
    && which svn

ENV GRADLE_VERSION=7.6.6
ARG GRADLE_DOWNLOAD_SHA256=673d9776f303bc7048fc3329d232d6ebf1051b07893bd9d11616fad9a8673be0
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
        && ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle
RUN apt-get remove wget git unzip openssl busybox git-lfs subversion mercurial bzr -y \
    && rm -rf /var/cache/apt/archives /var/lib/apt/lists

USER 1020

RUN set -o errexit -o nounset \
    && echo "Testing Gradle installation" \
    && gradle --version

CMD ["gradle"]