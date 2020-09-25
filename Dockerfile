FROM golang:alpine AS builder

ARG VERSION='v4.28.2'

RUN set -ex && apk update && apk add --no-cache git bash wget curl && mkdir -p /go/src/v2ray.com/core

WORKDIR /go/src/v2ray.com/core

COPY user-package.sh /user-package.sh

RUN set -ex && cd /go/src/v2ray.com/core && git clone --branch=$VERSION https://github.com/v2fly/v2ray-core.git ./ && \
   
    chmod +x /user-package.sh && mv -f /user-package.sh ./release/user-package.sh && \

    bash ./release/user-package.sh nosource noconf  abpathtgz=/tmp/v2ray.tar.gz && \

    rm /go/src/v2ray.com/core -rf
    

FROM alpine:latest

COPY --from=builder /tmp/v2ray.tar.gz /tmp

RUN set -ex && apk update && apk add --no-cache ca-certificates tzdata libcap bash && \    
    mkdir -p /usr/local/bin/v2ray &&\
    bash -c 'chmod 755 /usr/local/bin/v2ray -R' &&\
    tar xvfz /tmp/v2ray.tar.gz -C /usr/local/bin/v2ray &&\    
    chmod +x /usr/local/bin/v2ray/v2ray &&\
    chmod +x /usr/local/bin/v2ray/v2ctl  &&\
    setcap 'cap_net_bind_service=+ep' /usr/local/bin/v2ray/v2ray &&\
    setcap 'cap_net_bind_service=+ep' /usr/local/bin/v2ray/v2ctl &&\
    rm /tmp/v2ray.tar.gz && \
    mkdir /var/log/v2ray && chmod 666 /var/log/v2ray -R
    

ENV TZ=Asia/Shanghai

WORKDIR /usr/local/bin/v2ray

CMD ["/usr/local/bin/v2ray/v2ray", "-config=/etc/v2ray/config.json"]
