#!/usr/bin/env sh

#sudo docker compose -f elasticsearch-k8s/elasticsearch.yml build
#sudo docker compose -f kibana-k8s/kibana.yml build
#sudo docker compose -f docker-composes/logstash.yml build
sudo docker compose -f docker-compose-v1.yml build

# register a docker private registry
#sudo microk8s kubectl create secret docker-registry <name> \
#  --docker-server=DOCKER_REGISTRY_SERVER \
#  --docker-username=DOCKER_USER \
#  --docker-password=DOCKER_PASSWORD \
#  --docker-email=DOCKER_EMAIL


#sudo docker build -t containerized-gateway containerized-gateway/ .
#sudo docker build -t containerized-accounts containerized-accounts/ .
#sudo docker build -t containerized-products containerized-products/ .
#sudo docker build -t containerized-orders containerized-orders/ .
#sudo docker build -t containerized-main containerized-main/ .
#sudo docker build -t containerized-gateway containerized-gateway/ .
#sudo docker build -t containerized-config-server containerized-config-server/ .
#sudo docker build -t zipkin-server zipkin-server/ .

##########################################################################################################################################################################################################
###                  Because we have to use a docker privatge registry (or docker hub) when pulling image to node: https://kubernetes.io/docs/concepts/containers/images/#pre-pulled-images            ###
###                  without docker hub we can build it locally with microk8s: https://microk8s.io/docs/registry-images                                                                                ###
##########################################################################################################################################################################################################

#################### 1, Commands with using docker hub ##############################################################

######################### push to docker hub, first you need to login first #####################################
#sudo docker tag containerized-orders:v1.0.0 linhpv5555/containerized-orders:v1.0.0
#sudo docker push linhpv5555/containerized-orders:v1.0.0
 
#sudo docker tag containerized-main:v1.0.0 linhpv5555/containerized-main:v1.0.0
#sudo docker push linhpv5555/containerized-main:v1.0.0
 
#sudo docker tag containerized-accounts:v1.0.0 linhpv5555/containerized-accounts:v1.0.0
#sudo docker push linhpv5555/containerized-accounts:v1.0.0
 
#sudo docker tag containerized-discovery:v1.0.0 linhpv5555/containerized-discovery:v1.0.0
#sudo docker push linhpv5555/containerized-discovery:v1.0.0
  
#sudo docker tag containerized-products:v1.0.0 linhpv5555/containerized-products:v1.0.0
#sudo docker push linhpv5555/containerized-products:v1.0.0
 
#sudo docker tag zipkin-server:v1.0.0 linhpv5555/zipkin-server:v1.0.0
#sudo docker push linhpv5555/zipkin-server:v1.0.0
  
#sudo docker tag containerized-gateway:v1.0.0 linhpv5555/containerized-gateway:v1.0.0
#sudo docker push linhpv5555/containerized-gateway:v1.0.0

#sudo docker tag containerized-config-server:v1.0.0 linhpv5555/containerized-config-server:v1.0.0
#sudo docker push linhpv5555/containerized-config-server:v1.0.0

K8S_TOOL_NAME=microk8s

CONTAINTER_NAMESPACES=k8s-containerized-services
if [ "$1" ]; then
  CONTAINTER_NAMESPACES=$1
fi



#################### 2, Commands with using localy docker ##############################################################
if ! [ -d "$HOME/microservice-k8s-tar" ]; then
	mkdir $HOME/microservice-k8s-tar 
fi

# import docker image to local registry of $K8S_TOOL_NAME
sudo docker save containerized-orders > $HOME/microservice-k8s-tar/containerized-orders.tar
sudo $K8S_TOOL_NAME ctr image import $HOME/microservice-k8s-tar/containerized-orders.tar

sudo docker save containerized-main > $HOME/microservice-k8s-tar/containerized-main.tar
sudo $K8S_TOOL_NAME ctr image import $HOME/microservice-k8s-tar/containerized-main.tar

sudo docker save containerized-accounts > $HOME/microservice-k8s-tar/containerized-accounts.tar
sudo $K8S_TOOL_NAME ctr image import $HOME/microservice-k8s-tar/containerized-accounts.tar

sudo docker save containerized-discovery > $HOME/microservice-k8s-tar/containerized-discovery.tar
sudo $K8S_TOOL_NAME ctr image import $HOME/microservice-k8s-tar/containerized-discovery.tar

# ######### delete services, deployments, pods, ingress if exits in 'k8s-containerized-services' and 'ingress-nginx' namespaces
sudo microk8s kubectl delete --all services --namespace=k8s-containerized-services
sudo microk8s kubectl delete --all deployments --namespace=k8s-containerized-services
sudo microk8s kubectl delete --all pods --namespace=k8s-containerized-services
sudo microk8s kubectl delete --all ingress-nginx --namespace=k8s-containerized-services
sudo microk8s kubectl delete --all ingress --namespace=k8s-containerized-services
sudo microk8s kubectl delete --all configmap --namespace=k8s-containerized-services
sudo microk8s kubectl delete namespace k8s-containerized-services

#sudo microk8s kubectl delete --all services --namespace=ingress-nginx
#sudo microk8s kubectl delete --all deployments --namespace=ingress-nginx
#sudo microk8s kubectl delete --all pods --namespace=ingress-nginx
#sudo microk8s kubectl delete --all pods --namespace=ingress

#sudo microk8s kubectl delete --all ingress --namespace=ingress-nginx
#sudo microk8s kubectl delete --all ingress --namespace=ingress
#sudo microk8s kubectl delete namespace ingress-nginx
#sudo microk8s kubectl delete namespace ingress

sudo docker save containerized-gateway > $HOME/microservice-k8s-tar/containerized-gateway.tar
sudo $K8S_TOOL_NAME ctr image import $HOME/microservice-k8s-tar/containerized-gateway.tar

sudo docker save containerized-config-server > $HOME/microservice-k8s-tar/containerized-config-server.tar
sudo $K8S_TOOL_NAME ctr image import $HOME/microservice-k8s-tar/containerized-config-server.tar

# show list images in $K8S_TOOL_NAME after import
sudo $K8S_TOOL_NAME ctr images ls


# sudo $K8S_TOOL_NAME kubectl get pods | grep k8s-service | awk '{print $1}' | xargs sudo $K8S_TOOL_NAME kubectl delete pod

# ######### delete services, deployments, pods, ingress if exits in '$CONTAINTER_NAMESPACES' and 'ingress-nginx' namespaces
sudo $K8S_TOOL_NAME kubectl delete --all services --namespace=$CONTAINTER_NAMESPACES
sudo $K8S_TOOL_NAME kubectl delete --all deployments --namespace=$CONTAINTER_NAMESPACES
sudo $K8S_TOOL_NAME kubectl delete --all pods --namespace=$CONTAINTER_NAMESPACES
sudo $K8S_TOOL_NAME kubectl delete --all ingress-nginx --namespace=$CONTAINTER_NAMESPACES
sudo $K8S_TOOL_NAME kubectl delete --all ingress --namespace=$CONTAINTER_NAMESPACES
sudo $K8S_TOOL_NAME kubectl delete --all configmap --namespace=$CONTAINTER_NAMESPACES
sudo $K8S_TOOL_NAME kubectl delete namespace $CONTAINTER_NAMESPACES

#sudo $K8S_TOOL_NAME kubectl delete --all services --namespace=ingress-nginx
#sudo $K8S_TOOL_NAME kubectl delete --all deployments --namespace=ingress-nginx
#sudo $K8S_TOOL_NAME kubectl delete --all pods --namespace=ingress-nginx
#sudo $K8S_TOOL_NAME kubectl delete --all pods --namespace=ingress

#sudo $K8S_TOOL_NAME kubectl delete --all ingress --namespace=ingress-nginx
#sudo $K8S_TOOL_NAME kubectl delete --all ingress --namespace=ingress
#sudo $K8S_TOOL_NAME kubectl delete namespace ingress-nginx
#sudo $K8S_TOOL_NAME kubectl delete namespace ingress


#$K8S_TOOL_NAME kubectl create namespace $CONTAINTER_NAMESPACES
sudo $K8S_TOOL_NAME kubectl create -f k8s/namespace.yml
sudo $K8S_TOOL_NAME kubectl config view
sudo $K8S_TOOL_NAME kubectl config set-context dev --namespace=$CONTAINTER_NAMESPACES \
  --cluster=$USER \
  --user=$USER

# ################################# elasticsearch ##################################################
sudo $K8S_TOOL_NAME kubectl create -f elasticsearch-k8s/elasticsearch-deployment.yaml
sudo $K8S_TOOL_NAME kubectl create -f elasticsearch-k8s/elasticsearch-service.yaml

# ################################# kibana ##################################################
sudo $K8S_TOOL_NAME kubectl create -f kibana-k8s/kibana-deployment.yaml
sudo $K8S_TOOL_NAME kubectl create -f kibana-k8s/kibana-service.yaml

# ################################# logstash ##################################################
sudo $K8S_TOOL_NAME kubectl create -f containerized-logstash/k8s/configmap.yml
sudo $K8S_TOOL_NAME kubectl create -f containerized-logstash/k8s/deployment.yml
sudo $K8S_TOOL_NAME kubectl create -f containerized-logstash/k8s/service.yml

# ################################# zipkin-server ##################################################
sudo $K8S_TOOL_NAME kubectl wait pods -n $CONTAINTER_NAMESPACES -l app=k8s-service-logstash  --for=jsonpath='{.status.phase}'=Running --timeout=180s
sleep 30
sudo $K8S_TOOL_NAME kubectl create -f zipkin-server/k8s/deployment.yml
sudo $K8S_TOOL_NAME kubectl create -f zipkin-server/k8s/service.yml

# ################################# discovery service ##################################################
#while [[ $($K8S_TOOL_NAME kubectl get pods -l app=k8s-service-zipkin -n $CONTAINTER_NAMESPACES -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
sudo $K8S_TOOL_NAME kubectl wait pods -n $CONTAINTER_NAMESPACES -l app=k8s-service-zipkin --for=jsonpath='{.status.phase}'=Running --timeout=180s
sleep 30
sudo $K8S_TOOL_NAME kubectl create -f containerized-discovery/k8s/deployment.yml
sudo $K8S_TOOL_NAME kubectl create -f containerized-discovery/k8s/service.yml

# ################################# server config service ##################################################
sudo $K8S_TOOL_NAME kubectl wait pods -n $CONTAINTER_NAMESPACES -l app=k8s-service-discovery --for=jsonpath='{.status.phase}'=Running --timeout=180s
sleep 30
sudo $K8S_TOOL_NAME kubectl create -f containerized-config-server/k8s/configmap.yml
sudo $K8S_TOOL_NAME kubectl create -f containerized-config-server/k8s/deployment.yml
sudo $K8S_TOOL_NAME kubectl create -f containerized-config-server/k8s/service.yml

# ################################# accounts service ##################################################
sudo $K8S_TOOL_NAME kubectl wait pods -n $CONTAINTER_NAMESPACES -l app=k8s-service-discovery --for=jsonpath='{.status.phase}'=Running --timeout=180s
sudo $K8S_TOOL_NAME kubectl wait pods -n $CONTAINTER_NAMESPACES -l app=k8s-service-config-server --for=jsonpath='{.status.phase}'=Running --timeout=180s
sleep 30
sudo $K8S_TOOL_NAME kubectl create -f containerized-accounts/k8s/configmap.yml
sudo $K8S_TOOL_NAME kubectl create -f containerized-accounts/k8s/deployment.yml
sudo $K8S_TOOL_NAME kubectl create -f containerized-accounts/k8s/service.yml
#sudo $K8S_TOOL_NAME kubectl port-forward svc/containerized-accounts 2222:2222
# curl localhost:2222/account/api/v1/accounts

# ################################# products service ##################################################
sudo $K8S_TOOL_NAME kubectl wait pods -n $CONTAINTER_NAMESPACES -l app=k8s-service-discovery --for=jsonpath='{.status.phase}'=Running --timeout=180s
sudo $K8S_TOOL_NAME kubectl wait pods -n $CONTAINTER_NAMESPACES -l app=k8s-service-config-server --for=jsonpath='{.status.phase}'=Running --timeout=180s
sleep 30
sudo $K8S_TOOL_NAME kubectl create -f containerized-products/k8s/configmap.yml
sudo $K8S_TOOL_NAME kubectl create -f containerized-products/k8s/deployment.yml
sudo $K8S_TOOL_NAME kubectl create -f containerized-products/k8s/service.yml
#sudo $K8S_TOOL_NAME kubectl port-forward svc/containerized-products 2227:2227
# curl http://localhost:2227/product/api/v1/products

# ################################# orders service ##################################################
sudo $K8S_TOOL_NAME kubectl wait pods -n $CONTAINTER_NAMESPACES -l app=k8s-service-discovery --for=jsonpath='{.status.phase}'=Running --timeout=180s
sudo $K8S_TOOL_NAME kubectl wait pods -n $CONTAINTER_NAMESPACES -l app=k8s-service-config-server --for=jsonpath='{.status.phase}'=Running --timeout=180s
sleep 30
sudo $K8S_TOOL_NAME kubectl create -f containerized-orders/k8s/configmap.yml
sudo $K8S_TOOL_NAME kubectl create -f containerized-orders/k8s/deployment.yml
sudo $K8S_TOOL_NAME kubectl create -f containerized-orders/k8s/service.yml
#sudo $K8S_TOOL_NAME kubectl port-forward svc/containerized-orders 2226:2226
# curl localhost:2226/order/api/v1/orders

# ################################# main service ##################################################
sudo $K8S_TOOL_NAME kubectl wait pods -n $CONTAINTER_NAMESPACES -l app=k8s-service-discovery --for=jsonpath='{.status.phase}'=Running --timeout=180s
sudo $K8S_TOOL_NAME kubectl wait pods -n $CONTAINTER_NAMESPACES -l app=k8s-service-config-server --for=jsonpath='{.status.phase}'=Running --timeout=180s
sleep 30
sudo $K8S_TOOL_NAME kubectl create -f containerized-main/k8s/configmap.yml
sudo $K8S_TOOL_NAME kubectl create -f containerized-main/k8s/deployment.yml
sudo $K8S_TOOL_NAME kubectl create -f containerized-main/k8s/service.yml
#sudo $K8S_TOOL_NAME kubectl port-forward svc/containerized-main 2223:2223
# curl localhost:2223/backoffice/api/v1/backoffice/orders

# ################################# gateway service ##################################################
sudo $K8S_TOOL_NAME kubectl wait pods -n $CONTAINTER_NAMESPACES -l app=k8s-service-discovery --for=jsonpath='{.status.phase}'=Running --timeout=180s
sudo $K8S_TOOL_NAME kubectl wait pods -n $CONTAINTER_NAMESPACES -l app=k8s-service-config-server --for=jsonpath='{.status.phase}'=Running --timeout=180s
sleep 30
sudo $K8S_TOOL_NAME kubectl create -f containerized-gateway/k8s/deployment.yml
sudo $K8S_TOOL_NAME kubectl create -f containerized-gateway/k8s/service.yml
#sudo $K8S_TOOL_NAME kubectl port-forward svc/gateway 8762:8762

sleep 30

LOCALHOST=127.0.0.1
#https://unix.stackexchange.com/questions/149419/how-to-check-whether-a-particular-port-is-open-on-a-machine-from-a-shell-script
if nc -vz $LOCALHOST 8762 >/dev/null ; then
    echo "this port 8762 is occupied."
else
    echo "this port 8762 not running"
	sudo $K8S_TOOL_NAME kubectl port-forward -n $CONTAINTER_NAMESPACES service/containerized-gateway 8762:8762 --address 0.0.0.0 &
fi

#curl localhost:8762/backoffice/api/v1/backoffice/orders

if nc -vz $LOCALHOST 10443 >/dev/null ; then
	 echo "this port 10443 is occupied."
else 
     echo "this port 10443 not running"
	 sudo $K8S_TOOL_NAME kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443 --address 0.0.0.0 &
fi

# ################################# ingress k8s ##################################################
sudo $K8S_TOOL_NAME kubectl apply -f ingress-k8s/ingress.yml
sudo $K8S_TOOL_NAME kubectl apply -f ingress-k8s/nginx-config.yml