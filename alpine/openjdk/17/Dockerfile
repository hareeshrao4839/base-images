FROM alpine:3.20
LABEL maintainer="hareesh <hareesh.uk4839@gmail.com>"

ENV JAVA_HOME=/sr/lib/jvm/default-jvm \
    PATH=${JAVA_HOME}/bin:$PATH

RUN apk update && apk upgrade && \
    apk add --no-cache openjdk17-jdk openssl bash busybox-extras && \
    java -version && openssl -version
