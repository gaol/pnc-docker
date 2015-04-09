FROM jboss/wildfly:latest

MAINTAINER Lin Gao <lgao@redhat.com>

USER root

# install softwares
RUN yum -y update \
  && yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel \
  openssh-server \
  passwd wget which curl tree \
  && yum clean all

ADD start.sh /opt/
ADD ear-package.ear /opt/jboss/wildfly/standalone/deployments/
RUN chmod a+x /opt/start.sh
RUN update-alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java

# install aprox
RUN wget -O aprox.zip http://repo1.maven.org/maven2/org/commonjava/aprox/launch/aprox-launcher-savant/0.19.1/aprox-launcher-savant-0.19.1-launcher.zip
RUN unzip -q -d /opt/ aprox.zip

# aprox configurations
ADD aprox-etc.zip /opt/
RUN unzip -d /opt/aprox/etc/aprox/ -o /opt/aprox-etc.zip
#ADD aprox-data.zip /opt/
#RUN unzip -d /opt/aprox/var/lib/aprox/data/ -o /opt/aprox-data.zip

ADD pnc-config.json /opt/
RUN echo "JAVA_OPTS=\"\$JAVA_OPTS -Dpnc-config-file=/opt/pnc-config.json\"" >> /opt/jboss/wildfly/bin/standalone.conf

RUN chown -R jboss.jboss /opt/

# environments
ENV APROX_HOME "/opt/aprox/"

ENV PNC_JENKINS_USERNAME "pnc-system-user"
ENV PNC_JENKINS_PASSWORD "changeme"
ENV PNC_APROX_URL "http://localhost:8090/api"
ENV PNC_DOCKER_IP "172.17.42.1"
ENV PNC_DOCKER_CONT_USER "root"
ENV PNC_DOCKER_CONT_PASSWORD "changeme"
ENV PNC_DOCKER_IMAGE_ID "mareknovotny/pnc-jenkins:v0.3"
ENV PNC_DOCKER_IMAGE_FIREWALL_ALLOWED "172.17.42.1"

EXPOSE 22 8080 8090 9990

CMD ["/opt/start.sh"]
