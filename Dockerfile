FROM golang:alpine AS builder

ARG VERSION='v4.34.0'

RUN set -ex && apk update && apk add --no-cache git bash wget curl && mkdir -p /go/src/v2ray.com/core

WORKDIR /go/src/v2ray.com/core

COPY user-package.sh /user-package.sh

RUN set -ex && cd /go/src/v2ray.com/core && git clone --branch=$VERSION https://github.com/v2fly/v2ray-core.git ./ && \
   
    chmod +x /user-package.sh && mv -f /user-package.sh ./release/user-package.sh && \

    bash ./release/user-package.sh nosource noconf  abpathtgz=/tmp/v2ray.tar.gz && \

    mkdir -p /usr/bin/v2ray && tar xvfz /tmp/v2ray.tar.gz -C /usr/bin/v2ray &&\

    rm /go/src/v2ray.com/core -rf && rm /tmp/v2ray.tar.gz -rf
    

FROM alpine:latest

COPY --from=builder /usr/bin/v2ray /usr/bin/v2ray

RUN set -ex && apk update && apk add --no-cache ca-certificates tzdata libcap  && \    
    setcap 'cap_net_bind_service=+ep' /usr/bin/v2ray/v2ray &&\
    setcap 'cap_net_bind_service=+ep' /usr/bin/v2ray/v2ctl &&\
    mkdir /var/log/v2ray 
    

ENV TZ=Asia/Shanghai

WORKDIR /usr/bin/v2ray

CMD ["/usr/bin/v2ray/v2ray", "-config=/etc/v2ray/config.json"]
