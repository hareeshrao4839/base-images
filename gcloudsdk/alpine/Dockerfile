FROM docker:26.1.1 as static-docker-source

FROM alpine:3.20

ENV CLOUD_SDK_VERSION=479.0.0
ENV PATH /google-cloud-sdk/bin:$PATH
COPY --from=static-docker-source /usr/local/bin/docker /usr/local/bin/docker
COPY --from=static-docker-source /usr/local/libexec/docker/cli-plugins/docker-buildx /usr/local/libexec/docker/cli-plugins/docker-buildx
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
        gcloud components install kubectl && \
        gcloud --version && kubectl version --client 
RUN curl -L https://git.io/getLatestIstio | sh -  && cp /istio*/bin/istioctl /usr/local/bin/istioctl  && chmod +x /usr/local/bin/istioctl  && rm -rf /istio*.tar.gz  && rm -rf /istio*
RUN git config --system credential.'https://source.developers.google.com'.helper gcloud.sh

RUN apk del curl
RUN rm -f /google-cloud-sdk/.install/.backup/platform/gsutil/third_party/google-auth-library-python/tests/data/es256_privatekey.pem \
        /google-cloud-sdk/.install/.backup/platform/gsutil/third_party/google-auth-library-python/tests/data/pem_from_pkcs12.pem \
        /google-cloud-sdk/.install/.backup/platform/gsutil/third_party/google-auth-library-python/tests/data/privatekey.pem \
        /google-cloud-sdk/-install/.backup/platform/gsutil/third_party/urllib3/dummyserver/certs/cacert.key \ 
        /google-cloud-sdk/.install/.backup/platform/gsutil/third_party/urllib3/dummyserver/certs/server.key \ 
        /google-cloud-sdk/platform/gsutil/third_party/google-auth-library-python/tests/data/es256_privatekey.pem \
        /google-cloud-sdk/platform/gsutil/third_party/google-auth-library-python/tests/data/pem_from_pkcs12.pem \
        /google-cloud-sdk/platform/gsutil/third_party/google-auth-library-python/tests/data/privatekey.pem \
        /google-cloud-sdk/platform/gsutil/third_party/urllib3/dummyserver/certs/cacert.key \ 
        /google-cloud-sdk/platform/gsutil/third_party/urllib3/dummyserver/certs/server.key
USER 1000
VOLUME ["/root/.config"]
