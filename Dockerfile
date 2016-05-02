# DOCKER-VERSION 1.0.1
FROM java:8

MAINTAINER mikemarr

RUN if [[ ! -z "${HTTP_PROXY}" ]] ; then { echo "proxy=${HTTP_PROXY}" >> /etc/yum.conf; } fi
ENV http_proxy=${HTTP_PROXY}

# Install utility for AEM
ADD aemInstaller.sh /aem/aemInstaller.sh
