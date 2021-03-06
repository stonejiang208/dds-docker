FROM ubuntu:latest
MAINTAINER stonejiang <jiangtao@tao-studio.net>
ADD sources.list /etc/apt/sources.list
RUN apt-get update -y  && apt-get install -y \
    build-essential \
    wget \
    curl \
    tzdata \
    gdb \
    libssl-dev \
    libxerces-c-dev \
    ca-certificates \
    libpython2.7-dev \
    gzip \
    tar \
    unzip \
    git
ENV LANG C.UTF-8

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime

RUN mkdir /opt/dre
## RUN cd /tmp && wget http://download.dre.vanderbilt.edu/previous_versions/ACE+TAO-src-6.4.5.tar.bz2
## RUN cd /opt/dre && tar xvf /tmp/ACE+TAO-src-6.4.5.tar.bz2
ADD ACE+TAO-src-6.4.5.tar.bz2 /opt/dre

ENV ACE_ROOT /opt/dre/ACE_wrappers
ENV TAO_ROOT ${ACE_ROOT}/TAO
ADD OpenDDS-3.12.tar.gz  ${ACE_ROOT}/TAO
RUN mv ${ACE_ROOT}/TAO/OpenDDS-3.12 ${ACE_ROOT}/TAO/DDS
ENV DDS_ROOT ${TAO_ROOT}/DDS
ENV PATH ${PATH}:${ACE_ROOT}/bin:${DDS_ROOT}/bin
ENV LD_LIBRARY_PATH /usr/local/lib:${ACE_ROOT}/lib:${DDS_ROOT}/lib

#RUN cd /tmp &&  wget https://github.com/objectcomputing/OpenDDS/releases/download/DDS-3.12/OpenDDS-3.12.tar.gz
#RUN cd ${TAO_ROOT} && tar xvf /tmp/OpenDDS-3.12.tar.gz
#RUN cd ${TAO_ROOT} && mv OpenDDS-3.12 DDS
ADD config.h ${ACE_ROOT}/ace/
ADD platform_macros.GNU ${ACE_ROOT}/include/makeinclude/

RUN cd ${DDS_ROOT} \
  && mwc.pl -type gnuace DDS_TAOv2.mwc \
  && make -j 4
RUN cd ${ACE_ROOT} \
   && find . -name ".obj" | xargs rm -rf
