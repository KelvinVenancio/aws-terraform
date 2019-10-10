#!/bin/bash

#
# build jenkins image for docker
#

git clone https://github.com/KelvinVenancio/alpine-jenkins.git
cd alpine-jenkins
docker build -t jenkins_image .

#
# disable ufw and configure swap
#

systemctl stop ufw
systemctl disable ufw
iptables -F

dd if=/dev/zero of=/swapfile count=1024 bs=1M
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

iptables -nL && free -m

#
# start the container
#

systemctl restart docker
docker run -d -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock jenkins_image

#
# download jenkins-cli and test
#

sleep 30
wget http://$(curl -k icanhazip.com):8080/jnlpJars/jenkins-cli.jar
java -jar jenkins-cli.jar -s http://$(curl -k icanhazip.com):8080/ list-jobs