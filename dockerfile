FROM artifactrepo.tpp.tsysecom.com:9095/openjdk-slim-sid:11.0.1
USER root
ARG user=jenkins 
ARG group=jenkins
ARG uid=208 
ARG gid=208 
ARG VERSION=3.28 
ARG AGENT_WORKDIR=/home/jenkins/agent  
ARG JAVA_OPTS 

ENV DOCKER_HOST=tcp://172.17.0.1:2375 \
    DOCKER_CERT_PATH=/var/lib/jenkins/.docker \
    DOCKER_TLS_VERIFY=1 \
    AGENT_WORKDIR=/home/jenkins/agent \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/jdk/bin \
    JAVA_HOME=/opt/jdk


COPY logging.properties /var/lib/${user}/logging.properties 
COPY jenkins-slave /usr/local/bin/jenkins-slave
COPY publicaws.crt /tmp/publicaws.crt
COPY publiconprem.crt /tmp/publiconprem.crt
RUN apt-get update -y && apt-get install -o APT::Install-Suggests=0 -o APT::Install-Recommends=0  --no-install-recommends -y \
    python-qt4 \
    python-pyside \
    python-pip \
    python3-pip \
    python3-pyqt5 \
    git \
    vim \
    curl \
    wget \
    bash \
    build-essential \
    openssh-client \
    unzip \ 
    libltdl7 \
    docker \
    ncdu \ 
    htop \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && addgroup --gid 208 --group jenkins \
  && useradd -g jenkins --uid 208 --shell /bin/bash --home /var/lib/jenkins jenkins \
  && mkdir -p /usr/share/jenkins \
  && mkdir /var/lib/jenkinsreadonly \
  && mkdir -p /var/lib/jenkinsreadonly/.ssh \
  && chmod 777 /usr/share/jenkins \
  && chmod 777  /var/lib/jenkinsreadonly \
  && curl -k -L https://services.gradle.org/distributions/gradle-2.5-bin.zip -o gradle-2.5-bin.zip \
  && mkdir -p /usr/gradle /usr/share/jenkins \
  && unzip gradle-2.5-bin.zip -d /usr/gradle \
  && rm -rf gradle-2.5-bin.zip \
  && cd /usr/share/jenkins \
  && curl -k -v --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar \
  && mkdir -p /home/jenkins/agent && chown jenkins:jenkins /home/jenkins \
  && mkdir -p /host/usr/bin \
  && mkdir -p /var/lib/jenkins \
  && touch /host/usr/bin/docker \
  && ln -s /host/usr/bin/docker /usr/bin/docker \
  && chmod 755 /usr/bin/docker \
  && mkdir -p /workspace \
  && mkdir -p /var/lib/jenkins/workspace \
  && mkdir -p  /host/usr/bin ${HOME} \
  && touch /host/usr/bin/docker \
  && chmod 755 /usr/bin/docker \
  && chown -R jenkins:jenkins /var/lib/jenkins \
  && chown -R jenkins:jenkins /workspace \
  && chown -R jenkins:jenkins /home/jenkins \
  && mkdir -p /etc/pki  \
  && mkdir -p /host/usr/bin  \
  && mkdir -p /host/usr/sbin  \
  && mkdir -p /var/lib/jenkins  \
  && chmod 755 /var/lib/jenkins  \
  && chown -R jenkins:jenkins /var/lib/jenkins  \
  && chmod +x /usr/local/bin/jenkins-slave  \
  && chgrp jenkins /home/jenkins \
  && chmod 775 -R /usr/bin/ \
  && ln -s /usr/lib/jvm/java-11-openjdk-amd64/ /opt/jdk \
  && keytool -import -alias tsyscertaws -keystore /opt/jdk/lib/security/cacerts -file /tmp/publicaws.crt -storepass changeit -noprompt \
  && keytool -import -alias tsyscert -keystore /opt/jdk/lib/security/cacerts -file /tmp/publiconprem.crt -storepass changeit -noprompt \
  && chmod 777 /var/lib/jenkins 

VOLUME /var/lib/jenkins 
WORKDIR /var/lib/jenkins
USER jenkins
ENTRYPOINT ["/usr/local/bin/jenkins-slave"]
