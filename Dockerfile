FROM golang:alpine AS builder

ARG VERSION='v4.24.2'

RUN apk update && apk add --no-cache git bash wget curl && mkdir -p /go/src/v2ray.com/core

WORKDIR /go/src/v2ray.com/core

COPY user-package.sh /user-package.sh

RUN cd /go/src/v2ray.com/core && git clone --branch=$VERSION --depth=1 https://github.com/v2fly/v2ray-core.git ./ && \
   
    chmod +x /user-package.sh && mv -f /user-package.sh ./release/user-package.sh && \

    bash ./release/user-package.sh nosource noconf  abpathtgz=/tmp/v2ray.tar.gz && \

    rm /go/src/v2ray.com/core -rf
    

FROM alpine:latest

COPY --from=builder /tmp/v2ray.tar.gz /tmp

RUN apk update && apk add --no-cache ca-certificates tzdata && \
    
    mkdir -p /usr/bin/v2ray && \

    tar xvfz /tmp/v2ray.tar.gz -C /usr/bin/v2ray &&\
    
    rm /tmp/v2ray.tar.gz && \

    mkdir /var/log/v2ray
    
ENV PATH /usr/bin/v2ray:$PATH

ENV TZ=Asia/Shanghai


CMD ["v2ray", "-config=/etc/v2ray/config.json"]
