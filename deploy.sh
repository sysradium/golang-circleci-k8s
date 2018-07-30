#!/bin/bash

if [ -z "$KUBERNETES_CA" ]; then
	echo "\$KUBERNETES_CA is not set"
	exit 1
fi

if [ -z "$KUBERNETES_SERVER" ]; then
	echo "\$KUBERNETES_SERVER is not set"
	exit 1
fi

if [ -z "$KUBERNETES_TOKEN" ]; then
	echo "\$KUBERNETES_TOKEN is not set"
	exit 1
fi

echo "Building image"

docker login -p $DOCKER_PASSWORD -u $DOCKER_USERNAME $DOCKER_REPO
docker build . -t ${DOCKER_REPO}/${NAME}:latest && docker tag ${DOCKER_REPO}/${NAME}:latest ${DOCKER_REPO}/${NAME}:${CIRCLE_SHA1}
docker push ${DOCKER_REPO}/${NAME}:latest && docker push ${DOCKER_REPO}/${NAME}:${CIRCLE_SHA1}

echo "Setting k8s cluster configuration"

mkdir ~/.kube
echo $KUBERNETES_CA | base64 -d - > ~/.kube/ca.crt
kubectl config set-cluster cfc --server=$KUBERNETES_SERVER --certificate-authority=$HOME/.kube/ca.crt
kubectl config set-context cfc --cluster=cfc
kubectl config set-credentials user --token=$(echo $KUBERNETES_TOKEN | base64 -d -)
kubectl config set-context cfc --user=user --namespace=${NAMESPACE}
kubectl config use-context cfc

echo "Upgrading or installing helm chart"
helm upgrade --install --namespace=${NAMESPACE} --set image.repository=${DOCKER_REPO}/${NAME} --set image.tag=${CIRCLE_SHA1} ${NAME} ${CHART_PATH}
