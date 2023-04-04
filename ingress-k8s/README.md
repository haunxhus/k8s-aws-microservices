##################################################### ingress ###########################################################
**) microk8s ingress
 *) Prerequisites
 -  Enable metallb to support ingress:  microk8s enable metallb
 -  Choose ip ranges

 *) Check config file in ingres.yml
 
 *) Build ingress in microk8s: 
  - sudo microk8s kubectl apply -f ingress.yml
 
 *) Demo link:
  - Account services api: http://<cluster_ip>/account/api/v1/accounts/1
  - Check logs in doasboard, check account services pods:  http://<cluster_ip>:10443/
	 Login tokens: <dash_board token>
 => See the how load balancer works by using ingress :)))).
 
**) build all services scripts in k8s using mircok8s:
  - sudo chmod +x ./microk8s_kubernetes_build_script.sh
  - ./microk8s_kubernetes_build_script.sh
  
**) build all service using docker (can check docker-composes folder to get more details each service):
  - sudo docker compose -f docker-compose-v1.yml up -d


**) create config file for ingress: ingress.yml, please open and check for more detail : /ingress-k8s/ingress.yml

**) create config file for ingress controller: nginx-config.yml, please open and check for more detail : /ingress-k8s/nginx-config.yml