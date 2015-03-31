FROM jboss/wildfly:latest

MAINTAINER Lin Gao <lgao@redhat.com>

USER root

# install softwares
RUN yum -y update \
  && yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel \
  postgresql-server postgresql-libs postgresql \
  openssh-server \
  passwd wget which curl tree \
  && yum clean all

# prepare mount point
RUN chown -R jboss.jboss /opt/

# configure postgresql server
USER postgres
WORKDIR /var/lib/pgsql
RUN rm -rf /var/lib/pgsql/data
RUN initdb -A trust -D /var/lib/pgsql/data
RUN echo "host all all 0.0.0.0/0 trust" >> /var/lib/pgsql/data/pg_hba.conf
RUN echo "listen_addresses = '*'" >> /var/lib/pgsql/data/postgresql.conf
RUN pg_ctl start -D /var/lib/pgsql/data -l data/pg.log && sleep 5 && createuser -s -w newcastle && createdb -O newcastle newcastle

USER jboss
WORKDIR /opt/
RUN rm -rf /opt/jboss/wildfly/standalone/configuration/standalone.xml && rm -rf /opt/jboss/wildfly/standalone/deployments && ln -s /mnt/deployments /opt/jboss/wildfly/standalone/deployments 

RUN echo "JAVA_OPTS=\"\$JAVA_OPTS -Dpnc-config-file=/mnt/config/pnc-config.json -Djenkins-job-template=/mnt/config/job-template.xml\"" >> /opt/jboss/wildfly/bin/standalone.conf

# pnc standalone.xml
ADD standalone.xml /opt/jboss/wildfly/standalone/configuration/

# postgresql jdbc driver module
RUN mkdir -p /opt/jboss/wildfly/modules/system/layers/base/org/postgresql/main/
ADD module.xml /opt/jboss/wildfly/modules/system/layers/base/org/postgresql/main/
RUN wget -O /opt/jboss/wildfly/modules/system/layers/base/org/postgresql/main/postgresql-9.3-1103-jdbc4.jar http://repo1.maven.org/maven2/org/postgresql/postgresql/9.3-1103-jdbc4/postgresql-9.3-1103-jdbc4.jar

# install aprox
RUN wget -O aprox.zip http://repo1.maven.org/maven2/org/commonjava/aprox/launch/aprox-launcher-savant/0.19.1/aprox-launcher-savant-0.19.1-launcher.zip
RUN unzip -q -d /opt/ aprox.zip

ENV APROX_HOME "/opt/aprox/"

EXPOSE 5432 8080 8090 9990

ADD start.sh /opt/

VOLUME ["/mnt/deployments", "/mnt/config"]

USER root
RUN chmod a+x /opt/start.sh
RUN update-alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java

CMD ["/opt/start.sh"]
