############################
# STEP 1 build executable binary
############################
FROM golang:alpine AS builder

RUN apk update && apk add --no-cache git bash wget curl

WORKDIR /

RUN mkdir /go/src/v2ray.com/core

COPY user-package.sh /go/src/v2ray.com/core/user-package.sh

RUN git clone --depth=1 https://github.com/v2ray/v2ray-core.git /go/src/v2ray.com/core && \
    bash ./user-package.sh nosource noconf  abpathtgz=/tmp/v2ray.tar.gz && \
    rm /go/src/vwray.com/xore -rf
    
    
############################
# STEP 2 build a small image
############################

FROM alpine:latest

LABEL maintainer "V2Fly Community <admin@v2fly.org>"

COPY --from=builder /tmp/v2ray.tgz /tmp

RUN apk update && apk add ca-certificates tzdata && \
    mkdir -p /usr/bin/v2ray && \
    tar xvfz /tmp/v2ray.tar.gz -C /usr/bin/v2ray &&\
    rm /tmp/v2ray.tar.gz && \
    mkdir /var/log/v2ray
    
ENV PATH /usr/bin/v2ray:$PATH

ENV TZ=Asia/Shanghai


CMD ["v2ray", "-config=/etc/v2ray/config.json"]
