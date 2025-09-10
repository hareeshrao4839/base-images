FROM ubuntu:24.04

# Set base environment variables
ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8' \
    JAVA_VERSION=jdk-24.0.2+12 \
    ALLURE_VERSION=2.35.1 \
    JAVA_HOME=/opt/java/openjdk \
    UID=1010 \
    USER=appuser

# Set PATH after JAVA_HOME and ALLURE_HOME are defined
ENV ALLURE_HOME=/opt/allure/allure-$ALLURE_VERSION 
ENV PATH="$JAVA_HOME/bin:$ALLURE_HOME/bin:$PATH"

RUN set -eux; \
    apt-get update; \
    apt-get upgrade; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl \
        wget \
        gnupg \
        unzip \
        fontconfig \
        ca-certificates p11-kit \
        binutils \
        tzdata \
        locales \
        fonts-dejavu-core \
        openssl \
        bash \
        net-tools \
        dnsutils \
    ; \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; \
    locale-gen en_US.UTF-8


RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       amd64) \
         ESUM='bee902852ae8b6698e04eb1599dc94af844ae45b72b3b8ec854350b9aba41335'; \
         BINARY_URL='https://github.com/adoptium/temurin24-binaries/releases/download/jdk-24.0.2%2B12/OpenJDK24U-jre_x64_linux_hotspot_24.0.2_12.tar.gz'; \
         ;; \
       arm64) \
         ESUM='6b06ed1d91930ef86afc7d2159948aa9b3054b154cd8afda35d1fddd158fc11d'; \
         BINARY_URL='https://github.com/adoptium/temurin24-binaries/releases/download/jdk-24.0.2%2B12/OpenJDK24U-jre_aarch64_linux_hotspot_24.0.2_12.tar.gz'; \
         ;; \
       ppc64el) \
         ESUM='de9ec7034fb369ec9b5d12bba9d51984d14d859006e89ef2b86bbae9bc4c7ae4'; \
         BINARY_URL='https://github.com/adoptium/temurin24-binaries/releases/download/jdk-24.0.2%2B12/OpenJDK24U-jre_ppc64le_linux_hotspot_24.0.2_12.tar.gz'; \
         ;; \
       riscv64) \
         ESUM='4a1177077bc5937ec93cfaaff60fd212a8591af241827869c73f87949a1268e9'; \
         BINARY_URL='https://github.com/adoptium/temurin24-binaries/releases/download/jdk-24.0.2%2B12/OpenJDK24U-jre_riscv64_linux_hotspot_24.0.2_12.tar.gz'; \
         ;; \
       s390x) \
         ESUM='b25ab757f131f965195fd2cb63853299ed6bef268c845283a5a9fff562840fe2'; \
         BINARY_URL='https://github.com/adoptium/temurin24-binaries/releases/download/jdk-24.0.2%2B12/OpenJDK24U-jre_s390x_linux_hotspot_24.0.2_12.tar.gz'; \
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
    rm -f /tmp/openjdk.tar.gz; \
    # https://github.com/docker-library/openjdk/issues/331#issuecomment-498834472
    find "$JAVA_HOME/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf; \
    ldconfig; \
    java -Xshare:dump;

RUN set -eux; \
    echo "Verifying install ..."; \
    echo "java --version"; java --version; \
    echo "Complete."
COPY --chmod=755 entrypoint.sh /cacert_entrypoint.sh
#############
RUN set -eux; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends python3 python3-pip
RUN curl -o allure-commandline.zip https://repo.maven.apache.org/maven2/io/qameta/allure/allure-commandline/${ALLURE_VERSION}/allure-commandline-${ALLURE_VERSION}.zip \
    && unzip allure-commandline.zip -d /opt/allure \
    && rm -rf allure-commandline.zip
RUN adduser \
    --disabled-password \
	  --gecos "" \
	# --no-create-home \
	  --uid "$UID" \
	  --shell "/bin/bash" \
	  $USER && \
  chmod 755 /cacert_entrypoint.sh;

RUN apt-get remove wget unzip -y \
  && rm -rf /var/cache/apt/archives /var/lib/apt/lists
ENTRYPOINT ["/cacert_entrypoint.sh"]
USER $USER
CMD ["jshell"]