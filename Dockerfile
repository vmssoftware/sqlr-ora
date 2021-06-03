# LICENSE UPL 1.0
#
# Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved.
#
# Copyright (c) 2021, VMS Software, Inc. and/or its affiliates.
#
# Container image template for Oracle Instant Client & SQLRelay Server
#
#  HOW TO BUILD:
#       Edit sqlrelay.conf with your oracle connection string first!
#       Execute command for build:
#       docker build --pull -t sqlr-ora:21 . 
#
#  HOW TO RUN:
#       Run as a daemon:
#       docker run -p xxxx:xxxx -itd sqlr-ora:21
#
#       Run interactively:
#       docker run -p xxxx:xxxx -it sqlr-ora:21
#

FROM oraclelinux:7-slim AS build

RUN  yum -y install oracle-instantclient-release-el7 && \
     yum -y install oracle-instantclient-basic oracle-instantclient-devel oracle-instantclient-sqlplus

# Compile environment installation
RUN yum -y install gcc-c++ make readline-devel openssl-devel krb5-devel libcurl-devel

# download and tar sqlrelay
RUN yum -y install wget tar gzip && \
    cd /opt/ && \
	wget http://downloads.sourceforge.net/sqlrelay/sqlrelay-1.9.0.tar.gz && \
	wget http://downloads.sourceforge.net/rudiments/rudiments-1.4.0.tar.gz && \
    cd /opt/ && \
    tar -xvf  rudiments-1.4.0.tar.gz && \
    tar -xvf  sqlrelay-1.9.0.tar.gz

# build and install sqlrelay
RUN cd /opt/rudiments-1.4.0 && \
    ./configure --prefix=/opt/firstworks && \
    make && make install

RUN cd /opt/sqlrelay-1.9.0 && \
    ./configure --prefix=/opt/firstworks  --with-rudiments-prefix=/opt/firstworks \
    --disable-postgresql --disable-sap --disable-odbc --disable-db2  --disable-firebird \
    --disable-informix --disable-router --disable-odbc-driver --disable-perl --disable-python --disable-ruby \
    --disable-java --disable-tcl  --disable-php --disable-nodejs --disable-cs && \
    make && make install

RUN rm -f /opt/rudiments-1.4.0.tar.gz && \
    rm -f /opt/sqlrelay-1.9.0.tar.gz && \
    rm -rf /opt/rudiments-1.4.0 && \
    rm -rf /opt/sqlrelay-1.9.0

FROM oraclelinux:7-slim

RUN  yum -y install oracle-instantclient-release-el7 && \
     yum -y install oracle-instantclient-basic oracle-instantclient-devel oracle-instantclient-sqlplus && \
     rm -rf /var/cache/yum

COPY --from=build /opt/. /opt/

ENV PATH /opt/firstworks/bin:$PATH
ENV PATH /opt/bin:$PATH

COPY sqlrelay.conf /opt/firstworks/etc/sqlrelay.conf.d/sqlrelay.conf
COPY sqlr-entrypoint.sh /opt/bin/sqlr-entrypoint.sh

ENTRYPOINT ["sqlr-entrypoint.sh"]
