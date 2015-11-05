FROM sjoerdmulder/java8

RUN wget -O /usr/local/bin/docker https://get.docker.com/builds/Linux/x86_64/docker-1.8.2
RUN chmod +x /usr/local/bin/docker
RUN wget -O /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/1.4.0/docker-compose-Linux-x86_64
RUN chmod +x /usr/local/bin/docker-compose
ADD 10_wrapdocker.sh /etc/my_init.d/10_wrapdocker.sh
RUN groupadd docker

RUN apt-get update
RUN apt-get install -y unzip iptables lxc fontconfig

ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8
ENV AGENT_DIR  /opt/buildAgent

# Check install and environment
ADD 00_checkinstall.sh /etc/my_init.d/00_checkinstall.sh

RUN adduser --disabled-password --gecos "" teamcity
RUN sed -i -e "s/%sudo.*$/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/" /etc/sudoers
RUN usermod -a -G docker,sudo teamcity
RUN mkdir -p /data

EXPOSE 9090

VOLUME /var/lib/docker
VOLUME /data

# Install sbt and node.js build repositories
RUN echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
RUN add-apt-repository ppa:ondrej/php5-5.6
RUN sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823
RUN apt-get update

# Install php environment
RUN apt-get install -y curl git sbt python-software-properties php5
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=bin

ADD service /etc/service
