FROM circleci/golang:1.10

ENV DOCKER_VERSION 17.03.0-ce
ENV K8S_VERSION v1.9.0
ENV HELM_VERSION v2.9.0
ENV HELM_FILENAME helm-v2.9.0-linux-amd64.tar.gz 

RUN curl -L -o /tmp/docker-$DOCKER_VERSION.tgz https://get.docker.com/builds/Linux/x86_64/docker-$DOCKER_VERSION.tgz && \
    tar -xz -C /tmp -f /tmp/docker-$DOCKER_VERSION.tgz && \
    sudo mv /tmp/docker/* /usr/bin

RUN curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && sudo mv kubectl /usr/local/bin/

RUN curl -Lo ${HELM_FILENAME} "https://kubernetes-helm.storage.googleapis.com/${HELM_FILENAME}" && \
    tar zxf ${HELM_FILENAME} linux-amd64/helm && \
    chmod +x linux-amd64/helm && \
    sudo mv linux-amd64/helm /usr/local/bin/

RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

ADD deploy.sh /deploy.sh
