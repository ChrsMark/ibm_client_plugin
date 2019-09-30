ARG BASE_IMAGE=ubuntu:19.04
FROM $BASE_IMAGE

ARG GOPATH_ARG="/go"

ENV GOVERSION=1.12 \
    GOPATH=$GOPATH_ARG \
    ORG="github.com/ChrsMark"


# Install the Go compiler and Git
RUN export DEBIAN_FRONTEND=noninteractive \
  && bash -c 'source /etc/os-release; \
     echo "deb http://archive.ubuntu.com/ubuntu/ ${UBUNTU_CODENAME} main restricted" > /etc/apt/sources.list; \
     echo "deb http://archive.ubuntu.com/ubuntu/ ${UBUNTU_CODENAME}-updates main restricted" >> /etc/apt/sources.list; \
     echo "deb http://archive.ubuntu.com/ubuntu/ ${UBUNTU_CODENAME}-backports main restricted universe" >> /etc/apt/sources.list; \
     echo "deb http://archive.ubuntu.com/ubuntu/ ${UBUNTU_CODENAME} universe" >> /etc/apt/sources.list; \
     echo "deb http://archive.ubuntu.com/ubuntu/ ${UBUNTU_CODENAME}-updates universe" >> /etc/apt/sources.list;' \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    golang-${GOVERSION} \
    git \
    ca-certificates \
    curl \
    vim \
    tar \
    bash \
    go-dep \
    build-essential \
  && rm -rf /var/lib/apt/lists/*

# Create location for the git clone and MQ installation
RUN mkdir -p $GOPATH/src $GOPATH/bin $GOPATH/pkg \
  && chmod -R 777 $GOPATH \
  && mkdir -p $GOPATH/src/$ORG \
  && mkdir -p $GOPATH/src/github.com/elastic \
  && mkdir -p $GOPATH/src/github.com/ibm-messaging \
  && mkdir -p /opt/mqm \
  && chmod a+rx /opt/mqm

# Location of the downloadable MQ client package \
ENV RDURL="https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqdev/redist" \
    RDTAR="IBM-MQC-Redist-LinuxX64.tar.gz" \
    VRMF=9.1.3.0
# curl -LO "https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqdev/redist/9.1.3.0-IBM-MQC-Redist-LinuxX64.tar.gz"

# Install the MQ client from the Redistributable package. This also contains the
# header files we need to compile against.
RUN cd /opt/mqm \
 && curl -LO "$RDURL/$VRMF-$RDTAR" \
 && tar -zxf ./*.tar.gz \
 && rm -f ./*.tar.gz

# Insert the script that will do the build
COPY buildInDocker.sh $GOPATH
RUN chmod 777 $GOPATH/buildInDocker.sh

# Copy the rest of the source tree from this directory into the container
# And make sure it's readable by the id that will run the compiles (not just root)
ENV  REPO="ibm_client_plugin"
COPY . $GOPATH/src/$ORG/$REPO
RUN cd $GOPATH/src/github.com/ibm-messaging && git clone https://github.com/ibm-messaging/mq-golang.git
#RUN cd $GOPATH/src/github.com/elastic && git clone https://github.com/elastic/beats.git
RUN cd $GOPATH/src/github.com/elastic && git clone --single-branch --branch mqMetricbeat https://github.com/felix-lessoer/beats.git

# Set the entrypoint to the script that will do the compilation
ENTRYPOINT $GOPATH/buildInDocker.sh
