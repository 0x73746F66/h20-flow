FROM ubuntu:17.10
MAINTAINER Christopher Langton <chris@langton.cloud>

ARG DATA_DIR=/data
ARG WEB_PORT=54321
ARG SOCKET_PORT=54322
ARG JAVA_HOME=/usr/bin/java
ARG H2O_VERSION=wheeler/2/h2o-3.16.0.2

ENV JAVA_HOME ${JAVA_HOME}
ENV H2O_VERSION ${H2O_VERSION}

RUN groupadd --gid 1000 h2o \
  && useradd --uid 1000 --gid h2o --shell /bin/bash --create-home h2o

RUN \
  echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' | tee /etc/apt/apt.conf.d/no-cache && \
  echo "deb http://ap-northeast-1.ec2.archive.ubuntu.com/ubuntu trusty main universe" >> /etc/apt/sources.list && \
  apt-get update -q -y && \
  apt-get dist-upgrade -y && \
  apt-get clean && \
  rm -rf /var/cache/apt/*

RUN \
  DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils wget unzip software-properties-common python-software-properties && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update -q && \
  echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java8-installer && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java8-set-default && \
  apt-get clean


RUN \
  wget https://h2o-release.s3.amazonaws.com/h2o/rel-${H2O_VERSION}.zip -O /opt/h2o.zip && \
  unzip -d /opt /opt/h2o.zip && \
  rm /opt/h2o.zip && \
  cd /opt && \
  cd `find . -name 'h2o.jar' | sed 's/.\///;s/\/h2o.jar//g'` && \
  cp h2o.jar /opt

VOLUME ["${DATA_DIR}"]
EXPOSE $WEB_PORT $SOCKET_PORT

USER h2o
WORKDIR "${DATA_DIR}"

ENTRYPOINT ["-Xmx4g", "-jar", "/opt/h2o.jar"]
CMD ["${JAVA_HOME}"]