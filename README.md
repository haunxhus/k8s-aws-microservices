##################################################### ingress ###########################################################
**) microk8s ingress
 *) Prerequisites
 -  Enable metallb to support ingress:  microk8s enable metallb
 -  Choose ip ranges
 
 *) Check config file in ingres.yml
 
 *) Build ingress in microk8s: 
  - sudo microk8s kubectl apply -f ingress.yml
 
 *) Demo link:
  - Account services api: http://35.247.153.185/account/api/v1/accounts/1
  - Check logs in doasboard, check account services pods:  http://35.247.153.185:10443/
	 Login tokens: eyJhbGciOiJSUzI1NiIsImtpZCI6Ik9STl9pRGlnaFUwZ1dwVW1SUzhHX0NQMHF2bVR1UExXSVRsd1lINVZzeE0ifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJtaWNyb2s4cy1kYXNoYm9hcmQtdG9rZW4iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVmYXVsdCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjQ0YTZiM2Y4LTRkZWItNDEwOS1hODllLTk2MzJlNGE0Y2NjMCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTpkZWZhdWx0In0.ctNNpCyM5Ca3y9Y4jykBmSkquy6g2Ra0GsDhNfWlk25pUFPW4B6TsDmPHFe83dbwA_ESes89cKpK54CYVxogQkdJbl_WRietQh512snzNrKVZ1Ph72U1-Fm4zYUmpXhp-wMLMUfDGVyoEvAF73dYwbWLNVB4QGXgfhhiNTJ3qnBb6cdMEbNnUKlJg9bH_SbC9aZHT3llvPt1J-yH-xEkNxHDT1BKGpLkrru9revsztfElY6TJN2X6WXxYsnGIYbGV5lHCYp5PYm8hX1lbrBUpHppACT4VmS_Bmus-pWBrpVz5Vd7VI_xOn8If9PZUlD39DM9_5W7UVQgQzXeH86_eg
 => See the how load balancer works by using ingress :)))).
 
**) build all services scripts in k8s using mircok8s:
  - sudo chmod +x ./microk8s_kubernetes_build_script.sh
  - ./microk8s_kubernetes_build_script.sh
  
**) build all service using docker (can check docker-composes folder to get more details each service):
  - sudo docker compose -f docker-compose-v1.yml up -d  