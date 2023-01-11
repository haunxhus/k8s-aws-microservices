#!/usr/bin/env sh

sudo docker compose -f elasticsearch-k8s/elasticsearch.yml build
sudo docker compose -f kibana-k8s/kibana.yml build
sudo docker compose -f docker-composes/logstash.yml build
sudo docker compose -f docker-compose-elasticsearch-logstash-zipkin___.yml
#sudo docker build -t containerized-gateway containerized-gateway/.
#sudo docker build -t containerized-accounts containerized-accounts/.
#sudo docker build -t containerized-products containerized-products/.
#sudo docker build -t containerized-orders containerized-orders/.
#sudo docker build -t containerized-main containerized-main/.
#sudo docker build -t containerized-gateway containerized-gateway/.

# sudo microk8s kubectl get pods | grep k8s-service | awk '{print $1}' | xargs sudo microk8s kubectl delete pod

# ######### delete services, deployments, pods, ingress if exits
sudo microk8s kubectl delete --all services --namespace=k8s-containerized-services
sudo microk8s kubectl delete --all deployments --namespace=k8s-containerized-services
sudo microk8s kubectl delete --all pods --namespace=k8s-containerized-services
sudo microk8s kubectl delete --all ingress --namespace=k8s-containerized-services
sudo microk8s kubectl delete namespace k8s-containerized-services


#microk8s kubectl create namespace k8s-containerized-services
sudo microk8s kubectl create -f k8s/namespace.yml
sudo microk8s kubectl config view
sudo microk8s kubectl config set-context dev --namespace=k8s-containerized-services \
  --cluster=linhpv \
  --user=linhpv

# ################################# elasticsearch ##################################################
sudo microk8s kubectl create -f elasticsearch-k8s/k8s/configmap.yml
sudo microk8s kubectl create -f elasticsearch-k8s/k8s/deployment.yml
sudo microk8s kubectl create -f elasticsearch-k8s/k8s/service.yml

# ################################# kibana ##################################################
sudo microk8s kubectl create -f kibana-k8s/k8s/configmap.yml
sudo microk8s kubectl create -f kibana-k8s/k8s/deployment.yml
sudo microk8s kubectl create -f kibana-k8s/k8s/service.yml

# ################################# logstash ##################################################
sudo microk8s kubectl create -f containerized-logstash/k8s/configmap.yml
sudo microk8s kubectl create -f containerized-logstash/k8s/deployment.yml
sudo microk8s kubectl create -f containerized-logstash/k8s/service.yml

# ################################# zipkin-server ##################################################
sudo microk8s kubectl create -f zipkin-server/k8s/deployment.yml
sudo microk8s kubectl create -f zipkin-server/k8s/service.yml

# ################################# discovery service ##################################################
sudo microk8s kubectl create -f containerized-discovery/k8s/deployment.yml
sudo microk8s kubectl create -f containerized-discovery/k8s/service.yml

# ################################# accounts service ##################################################
sudo microk8s kubectl create -f containerized-accounts/k8s/configmap.yml
sudo microk8s kubectl create -f containerized-accounts/k8s/deployment.yml
sudo microk8s kubectl create -f containerized-accounts/k8s/service.yml
#sudo microk8s kubectl port-forward svc/containerized-accounts 2222:2222
# curl localhost:2222/account/api/v1/accounts

# ################################# products service ##################################################
sudo microk8s kubectl create -f containerized-products/k8s/configmap.yml
sudo microk8s kubectl create -f containerized-products/k8s/deployment.yml
sudo microk8s kubectl create -f containerized-products/k8s/service.yml
#sudo microk8s kubectl port-forward svc/containerized-products 2227:2227
# curl http://localhost:2227/product/api/v1/products

# ################################# orders service ##################################################
sudo microk8s kubectl create -f containerized-orders/k8s/configmap.yml
sudo microk8s kubectl create -f containerized-orders/k8s/deployment.yml
sudo microk8s kubectl create -f containerized-orders/k8s/service.yml
#sudo microk8s kubectl port-forward svc/containerized-orders 2226:2226
# curl localhost:2226/order/api/v1/orders

# ################################# main service ##################################################
sudo microk8s kubectl create -f containerized-main/k8s/configmap.yml
sudo microk8s kubectl create -f containerized-main/k8s/deployment.yml
sudo microk8s kubectl create -f containerized-main/k8s/service.yml
#sudo microk8s kubectl port-forward svc/containerized-main 2223:2223
# curl localhost:2223/backoffice/api/v1/backoffice/orders

# ################################# gatewayservice ##################################################
sudo microk8s kubectl create -f containerized-gateway/k8s/deployment.yml
sudo microk8s kubectl create -f containerized-gateway/k8s/service.yml
#sudo microk8s kubectl port-forward svc/gateway 8762:8762
sudo microk8s kubectl port-forward -n k8s-containerized-services service/containerized-gateway 8762:8762 --address 0.0.0.0 &
#curl localhost:8762/backoffice/api/v1/backoffice/orders

sudo microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443 --address 0.0.0.0 &

# ################################# ingress k8s ##################################################
sudo microk8s kubectl apply -f ingress.yml