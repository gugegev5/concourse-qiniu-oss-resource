FROM alpine:edge
MAINTAINER gup <1725763838@qq.com>

RUN apk update && \
        apk upgrade && \
        apk add --update bash jq git openssh && \
    wget -c http://devtools.qiniu.com/qshell-linux-x86-v2.4.0.zip && \
        unzip qshell-linux-x86-v2.4.0.zip && \
        mkdir -p /util_modules && \
        mv qshell-linux-x86-v2.4.0 util_modules/qshell && \
		chmod 777 /util_modules/qshell

COPY ./assets/* /opt/resource/
RUN chmod 777 -R /opt/resource
