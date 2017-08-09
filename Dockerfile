FROM ubuntu:xenial
MAINTAINER imorti <imorti@gmail.com>

# expose the port
EXPOSE 8080
# required to make docker in docker to work
VOLUME /var/lib/docker

# default jenkins home directory
ENV JENKINS_HOME /var/jenkins
# set our user home to the same location
ENV HOME /var/jenkins

# set our wrapper
ENTRYPOINT ["/usr/local/bin/docker-wrapper"]
# default command to launch jenkins
CMD java -jar /usr/share/jenkins/jenkins.war

# setup our local files first
ADD docker-wrapper.sh /usr/local/bin/docker-wrapper


# for installing docker related files first
RUN echo deb http://archive.ubuntu.com/ubuntu precise universe > /etc/apt/sources.list.d/universe.list
# apparmor is required to run docker server within docker container
RUN apt-get update -qq && apt-get install -qqy wget curl git iptables ca-certificates apparmor

RUN apt-get install -y lsb-core apt-utils

RUN apt-get install -y --no-install-recommends software-properties-common
RUN apt-get install apt-transport-https

#install docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

RUN apt-get update

RUN apt-cache policy docker-ce

RUN apt-get install -y docker-ce

# Install Docker Compose
RUN curl -L https://github.com/docker/compose/releases/download/1.14.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

#Install Rancher Compose
ADD rancher-compose /usr/local/bin/rancher-compose
RUN chmod +x /usr/local/bin/rancher-compose

#install nodeJS
RUN apt-get update
RUN apt-get install build-essential libssl-dev -y
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
RUN apt-get install npm -y

# for jenkins
RUN echo deb http://pkg.jenkins-ci.org/debian binary/ >> /etc/apt/sources.list \
    && wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
RUN apt-get update -qq && apt-get install -qqy jenkins
