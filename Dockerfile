FROM jenkins/jenkins:lts-jdk21

USER root

# Install Docker CLI, Git and AWS CLI
RUN apt-get update && \
    apt-get install -y \
        docker.io \
        git \
        awscli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Jenkins plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

USER jenkins
