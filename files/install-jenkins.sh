#!/bin/bash

#
# build jenkins image for docker
#

git clone https://github.com/KelvinVenancio/alpine-jenkins.git
cd alpine-jenkins
docker build -t jenkins_image .
docker run -d -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock jenkins_image

#
# download jenkins-cli and test
#

wget http://$(curl icanhazip.com):8080/jnlpJars/jenkins-cli.jar
java -jar jenkins-cli.jar -s http://$(curl icanhazip.com):8080/ list-jobs
