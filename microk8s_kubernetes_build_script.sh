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



#################### 2, Commands with using localy docker ##############################################################
sudo docker save containerized-orders > containerized-orders.tar
sudo microk8s ctr image import containerized-orders.tar

sudo docker save containerized-main > containerized-main.tar
sudo microk8s ctr image import containerized-main.tar

sudo docker save containerized-accounts > containerized-orders.tar
sudo microk8s ctr image import containerized-orders.tar

sudo docker save containerized-discovery > containerized-discovery.tar
sudo microk8s ctr image import containerized-discovery.tar

sudo docker save containerized-products > containerized-products.tar
sudo microk8s ctr image import containerized-products.tar

sudo docker save zipkin-server > zipkin-server.tar
sudo microk8s ctr image import zipkin-server.tar

sudo docker save containerized-gateway > containerized-gateway.tar
sudo microk8s ctr image import containerized-gateway.tar

sudo docker save containerized-config-server > containerized-config-server.tar
sudo microk8s ctr image import containerized-config-server.tar

# show list images in microk8s after import
sudo microk8s ctr images ls


# sudo microk8s kubectl get pods | grep k8s-service | awk '{print $1}' | xargs sudo microk8s kubectl delete pod

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


#microk8s kubectl create namespace k8s-containerized-services
sudo microk8s kubectl create -f k8s/namespace.yml
sudo microk8s kubectl config view
sudo microk8s kubectl config set-context dev --namespace=k8s-containerized-services \
  --cluster=linhpvk8s \
  --user=linhpvk8s

# ################################# elasticsearch ##################################################
sudo microk8s kubectl create -f elasticsearch-k8s/elasticsearch-deployment.yaml
sudo microk8s kubectl create -f elasticsearch-k8s/elasticsearch-service.yaml

# ################################# kibana ##################################################
sudo microk8s kubectl create -f kibana-k8s/kibana-deployment.yaml
sudo microk8s kubectl create -f kibana-k8s/kibana-service.yaml

# ################################# logstash ##################################################
sudo microk8s kubectl create -f containerized-logstash/k8s/configmap.yml
sudo microk8s kubectl create -f containerized-logstash/k8s/deployment.yml
sudo microk8s kubectl create -f containerized-logstash/k8s/service.yml

# ################################# zipkin-server ##################################################
sudo microk8s kubectl wait pods -n k8s-containerized-services -l app=k8s-service-logstash  --for=jsonpath='{.status.phase}'=Running --timeout=180s
sleep 30
sudo microk8s kubectl create -f zipkin-server/k8s/deployment.yml
sudo microk8s kubectl create -f zipkin-server/k8s/service.yml

# ################################# discovery service ##################################################
#while [[ $(microk8s kubectl get pods -l app=k8s-service-zipkin -n k8s-containerized-services -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
sudo microk8s kubectl wait pods -n k8s-containerized-services -l app=k8s-service-zipkin --for=jsonpath='{.status.phase}'=Running --timeout=180s
sleep 30
sudo microk8s kubectl create -f containerized-discovery/k8s/deployment.yml
sudo microk8s kubectl create -f containerized-discovery/k8s/service.yml

# ################################# server config service ##################################################
sudo microk8s kubectl wait pods -n k8s-containerized-services -l app=k8s-service-discovery --for=jsonpath='{.status.phase}'=Running --timeout=180s
sleep 30
sudo microk8s kubectl create -f containerized-config-server/k8s/configmap.yml
sudo microk8s kubectl create -f containerized-config-server/k8s/deployment.yml
sudo microk8s kubectl create -f containerized-config-server/k8s/service.yml

# ################################# accounts service ##################################################
sudo microk8s kubectl wait pods -n k8s-containerized-services -l app=k8s-service-discovery --for=jsonpath='{.status.phase}'=Running --timeout=180s
sudo microk8s kubectl wait pods -n k8s-containerized-services -l app=k8s-service-config-server --for=jsonpath='{.status.phase}'=Running --timeout=180s
sleep 30
sudo microk8s kubectl create -f containerized-accounts/k8s/configmap.yml
sudo microk8s kubectl create -f containerized-accounts/k8s/deployment.yml
sudo microk8s kubectl create -f containerized-accounts/k8s/service.yml
#sudo microk8s kubectl port-forward svc/containerized-accounts 2222:2222
# curl localhost:2222/account/api/v1/accounts

# ################################# products service ##################################################
sudo microk8s kubectl wait pods -n k8s-containerized-services -l app=k8s-service-discovery --for=jsonpath='{.status.phase}'=Running --timeout=180s
sudo microk8s kubectl wait pods -n k8s-containerized-services -l app=k8s-service-config-server --for=jsonpath='{.status.phase}'=Running --timeout=180s
sleep 30
sudo microk8s kubectl create -f containerized-products/k8s/configmap.yml
sudo microk8s kubectl create -f containerized-products/k8s/deployment.yml
sudo microk8s kubectl create -f containerized-products/k8s/service.yml
#sudo microk8s kubectl port-forward svc/containerized-products 2227:2227
# curl http://localhost:2227/product/api/v1/products

# ################################# orders service ##################################################
sudo microk8s kubectl wait pods -n k8s-containerized-services -l app=k8s-service-discovery --for=jsonpath='{.status.phase}'=Running --timeout=180s
sudo microk8s kubectl wait pods -n k8s-containerized-services -l app=k8s-service-config-server --for=jsonpath='{.status.phase}'=Running --timeout=180s
sleep 30
sudo microk8s kubectl create -f containerized-orders/k8s/configmap.yml
sudo microk8s kubectl create -f containerized-orders/k8s/deployment.yml
sudo microk8s kubectl create -f containerized-orders/k8s/service.yml
#sudo microk8s kubectl port-forward svc/containerized-orders 2226:2226
# curl localhost:2226/order/api/v1/orders

# ################################# main service ##################################################
sudo microk8s kubectl wait pods -n k8s-containerized-services -l app=k8s-service-discovery --for=jsonpath='{.status.phase}'=Running --timeout=180s
sudo microk8s kubectl wait pods -n k8s-containerized-services -l app=k8s-service-config-server --for=jsonpath='{.status.phase}'=Running --timeout=180s
sleep 30
sudo microk8s kubectl create -f containerized-main/k8s/configmap.yml
sudo microk8s kubectl create -f containerized-main/k8s/deployment.yml
sudo microk8s kubectl create -f containerized-main/k8s/service.yml
#sudo microk8s kubectl port-forward svc/containerized-main 2223:2223
# curl localhost:2223/backoffice/api/v1/backoffice/orders

# ################################# gateway service ##################################################
sudo microk8s kubectl wait pods -n k8s-containerized-services -l app=k8s-service-discovery --for=jsonpath='{.status.phase}'=Running --timeout=180s
sudo microk8s kubectl wait pods -n k8s-containerized-services -l app=k8s-service-config-server --for=jsonpath='{.status.phase}'=Running --timeout=180s
sleep 30
sudo microk8s kubectl create -f containerized-gateway/k8s/deployment.yml
sudo microk8s kubectl create -f containerized-gateway/k8s/service.yml
#sudo microk8s kubectl port-forward svc/gateway 8762:8762

if lsof -Pi :8762 -sTCP:LISTEN -t >/dev/null ; then
    echo "this port 8762 is occupied."
else
    echo "this port 8762 not running"
	sudo microk8s kubectl port-forward -n k8s-containerized-services service/containerized-gateway 8762:8762 --address 0.0.0.0 &
fi

#curl localhost:8762/backoffice/api/v1/backoffice/orders

if lsof -Pi :10443 -sTCP:LISTEN -t >/dev/null ; then
	 echo "this port 10443 is occupied."
else 
     echo "this port 8762 not running"
	 sudo microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443 --address 0.0.0.0 &
fi

# ################################# ingress k8s ##################################################
sudo microk8s kubectl apply -f ingress-k8s/ingress.yml
sudo microk8s kubectl apply -f ingress-k8s/nginx-config.yml