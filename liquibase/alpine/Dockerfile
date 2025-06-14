# Use multi-stage build
# FROM docker:28.2.2 as static-docker-source

FROM alpine:3.22

ENV CLOUD_SDK_VERSION=526.0.0
ENV PATH /google-cloud-sdk/bin:$PATH
# COPY --from=static-docker-source /usr/local/bin/docker /usr/local/bin/docker
# COPY --from=static-docker-source /usr/local/libexec/docker/cli-plugins/docker-buildx /usr/local/libexec/docker/cli-plugins/docker-buildx
RUN addgroup -g 1000 -S cloudsdk && \
    adduser -u 1000 -S cloudsdk -G cloudsdk
RUN if [ `uname -m` = 'x86_64' ]; then echo -n "x86_64" > /tmp/arch; else echo -n "arm" > /tmp/arch; fi;
RUN ARCH=`cat /tmp/arch` && apk --no-cache upgrade && apk --no-cache add \
        curl \
        python3 \
        py3-crcmod \
        py3-openssl \
        bash \
        libc6-compat \
        openssh-client \
        git \
        coreutils \
        gnupg && \
        curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${CLOUD_SDK_VERSION}-linux-${ARCH}.tar.gz && \
        tar xzf google-cloud-cli-${CLOUD_SDK_VERSION}-linux-${ARCH}.tar.gz && \
        rm google-cloud-cli-${CLOUD_SDK_VERSION}-linux-${ARCH}.tar.gz && \
        gcloud config set core/disable_usage_reporting true && \
        gcloud config set component_manager/disable_update_check true && \
        gcloud config set metrics/environment github_docker_image && \
        gcloud components install kubectl istioctl terraform-tools kubectl-oidc && \
        gcloud --version && kubectl version --client 
# RUN curl -L https://git.io/getLatestIstio | sh -  && cp /istio*/bin/istioctl /usr/local/bin/istioctl  && chmod +x /usr/local/bin/istioctl  && rm -rf /istio*.tar.gz  && rm -rf /istio*
RUN git config --system credential.'https://source.developers.google.com'.helper gcloud.sh

RUN apk del curl git 
RUN rm -f /google-cloud-sdk/.install/.backup/platform/gsutil/third_party/google-auth-library-python/tests/data/es256_privatekey.pem \
        /google-cloud-sdk/.install/.backup/platform/gsutil/third_party/google-auth-library-python/tests/data/pem_from_pkcs12.pem \
        /google-cloud-sdk/.install/.backup/platform/gsutil/third_party/google-auth-library-python/tests/data/privatekey.pem \
        /google-cloud-sdk/-install/.backup/platform/gsutil/third_party/urllib3/dummyserver/certs/cacert.key \ 
        /google-cloud-sdk/.install/.backup/platform/gsutil/third_party/urllib3/dummyserver/certs/server.key \ 
        /google-cloud-sdk/.install/.backup/platform/gsutil/third_party/urllib3/dummyserver/certs/cacert.key \
        /google-cloud-sdk/platform/gsutil/third_party/google-auth-library-python/tests/data/es256_privatekey.pem \
        /google-cloud-sdk/platform/gsutil/third_party/google-auth-library-python/tests/data/pem_from_pkcs12.pem \
        /google-cloud-sdk/platform/gsutil/third_party/google-auth-library-python/tests/data/privatekey.pem \
        /google-cloud-sdk/platform/gsutil/third_party/urllib3/dummyserver/certs/cacert.key \ 
        /google-cloud-sdk/platform/gsutil/third_party/urllib3/dummyserver/certs/server.key
# USER 1000
VOLUME ["/root/.config"]


# Create liquibase user
RUN addgroup --gid 1001 liquibase && \
    adduser --disabled-password --uid 1001 --ingroup liquibase --home /liquibase liquibase && \
    chown liquibase /liquibase

# Install smaller JRE, if available and acceptable
RUN apk add --no-cache openjdk21-jre-headless bash

WORKDIR /liquibase

ARG LIQUIBASE_VERSION=4.32.0
ARG LB_SHA256=10910d42ae9990c95a4ac8f0a3665a24bd40d08fb264055d78b923a512774d54

# Download, verify, extract
RUN set -x && \
    apk add --no-cache --virtual .fetch-deps wget && \
    wget -q -O liquibase-${LIQUIBASE_VERSION}.tar.gz "https://github.com/liquibase/liquibase/releases/download/v${LIQUIBASE_VERSION}/liquibase-${LIQUIBASE_VERSION}.tar.gz" && \
    echo "$LB_SHA256 *liquibase-${LIQUIBASE_VERSION}.tar.gz" | sha256sum -c - && \
    tar -xzf liquibase-${LIQUIBASE_VERSION}.tar.gz && \
    rm liquibase-${LIQUIBASE_VERSION}.tar.gz && \
    apk del --no-network .fetch-deps && \
    ln -s /liquibase/liquibase /usr/local/bin/liquibase && \
    ln -s /liquibase/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh && \
    liquibase --version
    
ARG LPM_VERSION=0.2.9
ARG LPM_SHA256=b9caecd34c98a6c19a2bc582e8064aff5251c5f1adbcd100d3403c5eceb5373a
ARG LPM_SHA256_ARM=0adb3a96d7384b4da549979bf00217a8914f0df37d1ed8fdb1b4a4baebfa104c

# Add metadata labels
LABEL org.opencontainers.image.description="Liquibase Container Image (Alpine)"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.vendor="Liquibase"
LABEL org.opencontainers.image.version="${LIQUIBASE_VERSION}"
LABEL org.opencontainers.image.documentation="https://docs.liquibase.com"

# Download and Install lpm
RUN mkdir /liquibase/bin && \
    apk add --no-cache --virtual .fetch-deps wget unzip && \
    arch="$(apk --print-arch)" && \
    case "$arch" in \
      x86_64)   DOWNLOAD_ARCH=""  ;; \
      aarch64)  DOWNLOAD_ARCH="-arm64" && LPM_SHA256=$LPM_SHA256_ARM  ;; \
      *) echo >&2 "error: unsupported architecture '$arch'" && exit 1 ;; \
    esac && wget -q -O lpm-${LPM_VERSION}-linux${DOWNLOAD_ARCH}.zip "https://github.com/liquibase/liquibase-package-manager/releases/download/v${LPM_VERSION}/lpm-${LPM_VERSION}-linux${DOWNLOAD_ARCH}.zip" && \
    echo "$LPM_SHA256 *lpm-${LPM_VERSION}-linux${DOWNLOAD_ARCH}.zip" | sha256sum -c - && \
    unzip lpm-${LPM_VERSION}-linux${DOWNLOAD_ARCH}.zip -d bin/ && \
    rm lpm-${LPM_VERSION}-linux${DOWNLOAD_ARCH}.zip && \
    apk del --no-network .fetch-deps && \
    ln -s /liquibase/bin/lpm /usr/local/bin/lpm && \
    lpm --version
RUN apk add --no-cache curl gnupg postgresql-client
RUN curl -O https://download.microsoft.com/download/b/9/f/b9f3cce4-3925-46d4-9f46-da08869c6486/msodbcsql18_18.0.1.1-1_amd64.apk \
  && curl -O https://download.microsoft.com/download/b/9/f/b9f3cce4-3925-46d4-9f46-da08869c6486/mssql-tools18_18.0.1.1-1_amd64.apk


#(Optional) Verify signature, if 'gpg' is missing install it using 'apk add gnupg':
RUN curl -O https://download.microsoft.com/download/b/9/f/b9f3cce4-3925-46d4-9f46-da08869c6486/msodbcsql18_18.0.1.1-1_amd64.sig \
  && curl -O https://download.microsoft.com/download/b/9/f/b9f3cce4-3925-46d4-9f46-da08869c6486/mssql-tools18_18.0.1.1-1_amd64.sig

RUN curl https://packages.microsoft.com/keys/microsoft.asc  | gpg --import - \
  && gpg --verify msodbcsql18_18.0.1.1-1_amd64.sig msodbcsql18_18.0.1.1-1_amd64.apk \
  && gpg --verify mssql-tools18_18.0.1.1-1_amd64.sig mssql-tools18_18.0.1.1-1_amd64.apk

COPY docker-entrypoint.sh ./
COPY liquibase.docker.properties ./
#Install the package(s)
RUN apk add --allow-untrusted msodbcsql18_18.0.1.1-1_amd64.apk \
  && apk add --allow-untrusted mssql-tools18_18.0.1.1-1_amd64.apk \
  && rm -f msodbcsql18_18.0.1.1-1_amd64.apk mssql-tools18_18.0.1.1-1_amd64.apk

# Set LIQUIBASE_HOME environment variable
ENV LIQUIBASE_HOME=/liquibase
# Marker which indicates this is a Liquibase docker container
ENV DOCKER_LIQUIBASE=true

COPY docker-entrypoint.sh ./
COPY liquibase.docker.properties ./
RUN chmod -R 775 /liquibase
USER liquibase:liquibase

ENTRYPOINT ["/liquibase/docker-entrypoint.sh"]
CMD ["--help"]