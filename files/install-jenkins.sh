#!/bin/bash
git clone https://github.com/KelvinVenancio/alpine-jenkins.git
cd alpine-jenkins
docker build -t jenkins_image .
docker run -d -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock jenkins_image