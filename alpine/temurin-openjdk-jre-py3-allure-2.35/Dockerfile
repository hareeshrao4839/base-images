FROM alpine:3.22

ENV JAVA_HOME=/opt/java/openjdk
ENV JAVA_VERSION=jdk-24.0.2+12
# Default to UTF-8 file.encoding
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
ENV ALLURE_VERSION=2.35.1
ENV ALLURE_HOME=/opt/allure/allure-$ALLURE_VERSION 
ENV PATH="/usr/local/bin:$JAVA_HOME/bin:$ALLURE_HOME/bin:$PATH"
ENV GPG_KEY 7169605F62C751356D054A26A821E680E5FA6305
ENV PYTHON_VERSION 3.13.7
ENV PYTHON_SHA256 5462f9099dfd30e238def83c71d91897d8caa5ff6ebc7a50f14d4802cdaaa79a
ENV UID=1010 USER=appuser


RUN adduser -D -u $UID -s /bin/sh $USER && \
    mkdir -p /home/$USER && \
    chown -R $USER:$USER /home/$USER

RUN set -eux; \
    apk add --no-cache \
        fontconfig ttf-dejavu \
        gnupg \
        ca-certificates p11-kit-trust \
        musl-locales musl-locales-lang \
        tzdata \
        coreutils \
        openssl
RUN set -eux; \
    ARCH="$(apk --print-arch)"; \
    case "${ARCH}" in \
       aarch64) \
         ESUM='389100187cf328c7b6b6b390fc0f5071ab38e93e8a6c06beb11e59363d2fd0d0'; \
         BINARY_URL='https://github.com/adoptium/temurin24-binaries/releases/download/jdk-24.0.2%2B12/OpenJDK24U-jre_aarch64_alpine-linux_hotspot_24.0.2_12.tar.gz'; \
         ;; \
       x86_64) \
         ESUM='b63b888d2415828168c4d35a62d88f385a5532a20b7391e30a5d5d0a9a73b892'; \
         BINARY_URL='https://github.com/adoptium/temurin24-binaries/releases/download/jdk-24.0.2%2B12/OpenJDK24U-jre_x64_alpine-linux_hotspot_24.0.2_12.tar.gz'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    wget -O /tmp/openjdk.tar.gz ${BINARY_URL}; \
    wget -O /tmp/openjdk.tar.gz.sig ${BINARY_URL}.sig; \
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
    rm -f /tmp/openjdk.tar.gz;

RUN set -eux; \
    echo "Verifying install ..."; \
    echo "java --version"; java --version; \
    echo "Complete."
COPY --chmod=775 entrypoint.sh /__cacert_entrypoint.sh

    RUN set -eux; \
    \
    apk add --no-cache --virtual .build-deps \
      gnupg \
      tar \
      xz \
      \
      bluez-dev \
      bzip2-dev \
      dpkg-dev dpkg \
      findutils \
      gcc \
      gdbm-dev \
      libc-dev \
      libffi-dev \
      libnsl-dev \
      libtirpc-dev \
      linux-headers \
      make \
      ncurses-dev \
      openssl-dev \
      pax-utils \
      readline-dev \
      sqlite-dev \
      tcl-dev \
      tk \
      tk-dev \
      util-linux-dev \
      xz-dev \
      zlib-dev \
    ; \
    \
    wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz"; \
    echo "$PYTHON_SHA256 *python.tar.xz" | sha256sum -c -; \
    wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc"; \
    GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$GPG_KEY"; \
    gpg --batch --verify python.tar.xz.asc python.tar.xz; \
    gpgconf --kill all; \
    rm -rf "$GNUPGHOME" python.tar.xz.asc; \
    mkdir -p /usr/src/python; \
    tar --extract --directory /usr/src/python --strip-components=1 --file python.tar.xz; \
    rm python.tar.xz; \
    \
    cd /usr/src/python; \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    ./configure \
      --build="$gnuArch" \
      --enable-loadable-sqlite-extensions \
      --enable-option-checking=fatal \
      --enable-shared \
      $(test "${gnuArch%%-*}" != 'riscv64' && echo '--with-lto') \
      --with-ensurepip \
    ; \
    nproc="$(nproc)"; \
    EXTRA_CFLAGS="-DTHREAD_STACK_SIZE=0x100000"; \
    LDFLAGS="${LDFLAGS:--Wl},--strip-all"; \
      arch="$(apk --print-arch)"; \
      case "$arch" in \
        x86_64|aarch64) \
          EXTRA_CFLAGS="${EXTRA_CFLAGS:-} -fno-omit-frame-pointer -mno-omit-leaf-frame-pointer"; \
          ;; \
        x86) \
          ;; \
        *) \
          EXTRA_CFLAGS="${EXTRA_CFLAGS:-} -fno-omit-frame-pointer"; \
          ;; \
      esac; \
    make -j "$nproc" \
      "EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" \
      "LDFLAGS=${LDFLAGS:-}" \
    ; \
    rm python; \
    make -j "$nproc" \
      "EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" \
      "LDFLAGS=${LDFLAGS:--Wl},-rpath='\$\$ORIGIN/../lib'" \
      python \
    ; \
    make install; \
    \
    cd /; \
    rm -rf /usr/src/python; \
    \
    find /usr/local -depth \
      \( \
        \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
        -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name 'libpython*.a' \) \) \
      \) -exec rm -rf '{}' + \
    ; \
    \
    find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec scanelf --needed --nobanner --format '%n#p' '{}' ';' \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
      | xargs -rt apk add --no-network --virtual .python-rundeps \
    ; \
    apk del --no-network .build-deps; \
    \
    export PYTHONDONTWRITEBYTECODE=1; \
    python3 --version; \
    pip3 --version
  
RUN set -eux; \
    for src in idle3 pip3 pydoc3 python3 python3-config; do \
      dst="$(echo "$src" | tr -d 3)"; \
      [ -s "/usr/local/bin/$src" ]; \
      [ ! -e "/usr/local/bin/$dst" ]; \
      ln -svT "$src" "/usr/local/bin/$dst"; \
    done
RUN apk update && apk add --no-cache \
    python3 \
    py3-pip \
    build-base \
    libffi-dev \
    openssl-dev \
    bash \
    ca-certificates \
    traceroute \
    busybox-extras \
    curl \
    yq \
    && rm -rf /tmp/*
# Upgrade pip and install setuptools

RUN curl -o allure-commandline.zip https://repo.maven.apache.org/maven2/io/qameta/allure/allure-commandline/${ALLURE_VERSION}/allure-commandline-${ALLURE_VERSION}.zip \
    && unzip allure-commandline.zip -d /opt/allure \
    && rm -rf allure-commandline.zip
RUN pip3 install --upgrade pip setuptools

ENTRYPOINT ["/__cacert_entrypoint.sh"]
CMD ["python3"]