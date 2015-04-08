#!/bin/sh

# start wildfly
sudo -u jboss /opt/jboss/wildfly/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0 &

# start aprox
sudo -u jboss /opt/aprox/bin/aprox.sh -p 8090

