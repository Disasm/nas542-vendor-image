FROM ubuntu:14.04.3 as base

# libncurses5-dev is needed for make menuconfig
RUN ulimit -n 524288 \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y g++ libxml2 u-boot-tools autoconf-archive build-essential gawk \
    && apt-get install -y libncurses5-dev \
    && apt-get clean autoclean \
    && apt-get autoremove --yes

RUN useradd -m builder \
    && echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER builder:builder
WORKDIR /home/builder


FROM base as extractor
COPY host.tar.gz staging.tar.gz tool.tar.gz x-tools.tar.gz e2fsprogs-1.47.0.tar.xz /home/builder/

RUN sudo mkdir -p /opt/sdk/arm-msp-linux-gnueabihf/staging \
    && sudo tar zxf x-tools.tar.gz -C /opt \
    && sudo tar zxf staging.tar.gz -C /opt/sdk/arm-msp-linux-gnueabihf/staging \
    && sudo tar zxf host.tar.gz -C /opt/sdk/arm-msp-linux-gnueabihf/

RUN tar zxf tool.tar.gz \
    && mv tools tools.tmp \
    && mkdir tools \
    && mv tools.tmp/m4-1.4.13.tar.gz tools/ \
    && mv tools.tmp/bison-1.875.tar.gz tools/ \
    && mv tools.tmp/libtool-2.4.2.tar.gz tools/ \
    && mv tools.tmp/autoconf-2.68.tar.gz tools/ \
    && mv tools.tmp/automake-1.11.1.tar.gz tools/ \
    && mv tools.tmp/Python-2.7.6.tar.gz tools/ \
    && mv tools.tmp/flex-2.5.33.tar.gz tools/ \
    && mv e2fsprogs-1.47.0.tar.xz tools/


FROM base as builder
COPY --from=extractor /opt /opt
COPY --from=extractor --chown=builder:builder /home/builder/tools /home/builder/tools

WORKDIR /home/builder/tools
RUN echo "Building m4" \
    && tar zxf m4-1.4.13.tar.gz \
    && cd m4-1.4.13 \
    && ./configure --prefix=/usr \
    && make \
    && sudo make install \
    && cd .. \
    && rm -r m4-1.4.13.tar.gz m4-1.4.13

RUN echo "Building bison" \
    && tar zxf bison-1.875.tar.gz \
    && cd bison-1.875 \
    && ./configure --prefix=/usr \
    && make \
    && sudo make install \
    && cd .. \
    && rm -r bison-1.875.tar.gz bison-1.875

RUN echo "Building libtool" \
    && tar zxf libtool-2.4.2.tar.gz \
    && cd libtool-2.4.2 \
    && ./configure --prefix=/usr \
    && make \
    && sudo make install \
    && cd .. \
    && rm -r libtool-2.4.2.tar.gz libtool-2.4.2

RUN echo "Building autoconf" \
    && tar zxf autoconf-2.68.tar.gz \
    && cd autoconf-2.68 \
    && ./configure --prefix=/usr \
    && make \
    && sudo make install \
    && cd .. \
    && rm -r autoconf-2.68.tar.gz autoconf-2.68

RUN echo "Building automake" \
    && tar zxf automake-1.11.1.tar.gz \
    && cd automake-1.11.1 \
    && ./configure --prefix=/usr \
    && make \
    && sudo make install \
    && cd .. \
    && rm -r automake-1.11.1.tar.gz automake-1.11.1

RUN echo "Building python" \
    && tar zxf Python-2.7.6.tar.gz \
    && cd Python-2.7.6 \
    && ./configure --prefix=/usr/local \
    && make \
    && sudo make install \
    && cd .. \
    && rm -r Python-2.7.6.tar.gz Python-2.7.6

RUN echo "Building flex" \
    && tar zxf flex-2.5.33.tar.gz \
    && cd flex-2.5.33 \
    && ./configure --prefix=/usr \
    && make \
    && sudo make install \
    && cd .. \
    && rm -r flex-2.5.33.tar.gz flex-2.5.33

RUN echo "Building e2fsprogs" \
    && tar xf e2fsprogs-1.47.0.tar.xz \
    && cd e2fsprogs-1.47.0 \
    && ./configure --prefix=/usr \
    && make \
    && sudo make install \
    && cd .. \
    && rm -r e2fsprogs-1.47.0.tar.xz e2fsprogs-1.47.0

RUN sudo ln -f -s /bin/bash /bin/sh
RUN sudo ln -f -s `which gawk` /usr/bin/awk

WORKDIR /home/builder
