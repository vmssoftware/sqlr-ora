FROM oraclelinux:8-slim AS build

RUN  microdnf  -y install oracle-instantclient-release-el8 && \
     microdnf  -y install oracle-instantclient-basic oracle-instantclient-devel oracle-instantclient-sqlplus

# Compile environment installation
RUN microdnf  -y install gcc-c++ make readline-devel openssl-devel krb5-devel libcurl-devel

# download and tar sqlrelay
RUN microdnf  -y install wget tar gzip && \
    cd /opt/ && \
	wget http://downloads.sourceforge.net/project/sqlrelay/sqlrelay/1.9.3/sqlrelay-1.9.3.tar.gz && \
	wget http://downloads.sourceforge.net/project/rudiments/rudiments/1.4.2/rudiments-1.4.2.tar.gz && \
    cd /opt/ && \
    tar -xvf  rudiments-1.4.2.tar.gz && \
    tar -xvf  sqlrelay-1.9.3.tar.gz

# build and install sqlrelay
RUN cd /opt/rudiments-1.4.2 && \
    ./configure --prefix=/opt/firstworks && \
    make && make install

RUN cd /opt/sqlrelay-1.9.3 && \
    ./configure --prefix=/opt/firstworks  --with-rudiments-prefix=/opt/firstworks \
    --disable-postgresql --disable-sap --disable-odbc --disable-db2  --disable-firebird \
    --disable-informix --disable-router --disable-odbc-driver --disable-perl --disable-python --disable-ruby \
    --disable-java --disable-tcl  --disable-php --disable-nodejs --disable-cs && \
    make && make install

RUN rm -f /opt/rudiments-1.4.2.tar.gz && \
    rm -f /opt/sqlrelay-1.9.3.tar.gz && \
    rm -rf /opt/rudiments-1.4.2 && \
    rm -rf /opt/sqlrelay-1.9.3


FROM oraclelinux:8-slim

RUN  microdnf  -y install oracle-instantclient-release-el8
RUN  microdnf  -y install oracle-instantclient-basic oracle-instantclient-devel oracle-instantclient-sqlplus

COPY --from=build /opt/. /opt/

ENV PATH=/opt/firstworks/bin:$PATH
ENV PATH=/opt/bin:$PATH

COPY sqlrelay.conf /opt/firstworks/etc/sqlrelay.conf.d/sqlrelay.conf

COPY sqlr-entrypoint.sh /opt/bin/sqlr-entrypoint.sh
RUN chmod +x /opt/bin/sqlr-entrypoint.sh

ENTRYPOINT ["/opt/bin/sqlr-entrypoint.sh"]
