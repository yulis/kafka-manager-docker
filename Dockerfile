FROM ubuntu:trusty

MAINTAINER yulis

ENV SCALA_VERSION="2.11.6"
ENV SBT_VERSION="0.13.8"
ENV KAFKA_MANAGER_REVISION="5c6eb4c093d9d6a34d54d42684c175a4427bc088"

# Override with correct values
ENV ZK_HOSTS="zk1:2181,zk2:2181,zk3:2181"

# Install Java
RUN apt-get update && apt-get install -y \
  openjdk-7-jre-headless \
  openjdk-7-jdk \
  wget \
  curl \
  git \
  unzip

# Install Scala
RUN \
  cd /root && \
  curl -o scala-${SCALA_VERSION}.tgz http://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz && \
  tar -xf scala-${SCALA_VERSION}.tgz && \
  rm scala-${SCALA_VERSION}.tgz && \
  echo >> /root/.bashrc && \
  echo 'export PATH=~/scala-${SCALA_VERSION}/bin:$PATH' >> /root/.bashrc

# Install sbt
RUN \
  cd /root && \
  curl -L -o sbt-${SBT_VERSION}.deb https://bintray.com/artifact/download/sbt/debian/sbt-${SBT_VERSION}.deb && \
  dpkg -i sbt-${SBT_VERSION}.deb && \
  rm sbt-${SBT_VERSION}.deb && \
  apt-get update && \
  apt-get install sbt

# Build Kafka Manager
RUN \
  cd /root && \
  git clone https://github.com/yahoo/kafka-manager && \
  cd kafka-manager && \
  git checkout ${KAFKA_MANAGER_REVISION} && \
  sbt clean dist && \
  unzip  -d / ./target/universal/kafka-manager-1.1.zip 

# Set Workdir
WORKDIR /kafka-manager-1.1

# Run
EXPOSE 9000
ENTRYPOINT ["./bin/kafka-manager"]