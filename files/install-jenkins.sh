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
docker exec -it $(docker ps | grep "jenkins_image" | awk {'print $1'}) cd /var/jenkins_home/plugins/ ; rm -rf workflow-*.jpi workflow-*.jpi.pinned workflow-*.jpi* variant* variant* trilead* ssh-* pubsub-* matrix* h* *.pinned *.version_from_image
docker stop $(docker ps | grep "jenkins_image" | awk {'print $1'})
docker start $(docker ps -a | grep "jenkins_image" | awk {'print $1'})
sleep 60
docker exec -it $(docker ps | grep "jenkins_image" | awk {'print $1'}) java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://$(curl -ks icanhazip.com):8080/ -auth admin:admin list-jobs
# wget http://$(curl -k icanhazip.com):8080/jnlpJars/jenkins-cli.jar
# java -jar jenkins-cli.jar -s http://$(curl -k icanhazip.com):8080/ list-jobs