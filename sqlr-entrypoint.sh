#!/bin/bash
rm -f /opt/firstworks/var/run/sqlrelay/*.pid
sqlr-start -config /opt/firstworks/etc/sqlrelay.conf.d/sqlrelay.conf -id oracle
/bin/bash
