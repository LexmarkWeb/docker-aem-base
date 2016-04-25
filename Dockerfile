# DOCKER-VERSION 1.0.1
FROM centos:7

MAINTAINER mikemarr

RUN if [[ ! -z "${HTTP_PROXY}" ]] ; then { echo "proxy=${HTTP_PROXY}" >> /etc/yum.conf; } fi
ENV http_proxy=${HTTP_PROXY}

#Update and install wget
RUN yum -y update; yum clean all
RUN yum install -y --enablerepo=centosplus libselinux-devel
RUN yum install -y --enablerepo=centosplus httpd
RUN yum install -y wget
RUN yum install -y --enablerepo=centosplus epel-release
RUN yum install -y zip

#Enables Centos EPL repository, and then installs python modules.
RUN yum -y install ipython
RUN yum install -y python-psutil
RUN yum install -y python-pycurl
RUN yum install -y python-requests
RUN easy_install simplejson==3.3.1

RUN echo $http_proxy

# install java 8
RUN wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u92-b14/jdk-8u92-linux-x64.rpm" -O /tmp/jdk-8-linux-x64.rpm

RUN yum -y install /tmp/jdk-8-linux-x64.rpm

# Install utility for AEM
ADD aemInstaller.py /aem/aemInstaller.py
