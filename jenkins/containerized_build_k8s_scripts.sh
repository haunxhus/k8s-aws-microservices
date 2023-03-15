#!/bin/bash

# https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/
# https://www.containiq.com/post/kubernetes-rolling-update-deployment
# https://linuxhint.com/kubectl-set-image-command/
# https://www.bluematador.com/blog/kubernetes-deployments-rolling-update-configuration

#version=v1.0.0
#sudo microk8s ctr image import $HOME/microservice-k8s-tar/containerized-discovery-.*.tar
# kubectl set image deployment/<<deployment-name>> -n=<<namespace>> <<container_name>>=<<your_dockerhub_username>>/<<image_name you want to set now>>:<<tag_of_the_image_you_want>>
#sudo microk8s kubectl set image deployment/k8s-service-discovery -n=k8s-containerized-services containerized-discovery=containerized-discovery:$version --record

#sudo microk8s kubectl apply -f ../containerized-discovery/k8s/deployment.yml

#sudo microk8s kubectl rollout status deployment/k8s-service-discovery

#sudo microk8s kubectl rollout history deployment/k8s-service-discovery
#sudo microk8s kubectl get deployments -n=k8s-containerized-services

#undo most recent update 
#sudo microk8s kubectl rollout undo deployment/k8s-service-discovery

COMMIT_HASH=
if [ "$1" ]; then
  COMMIT_HASH=$1
fi

IMAGE_VERSION=local
if [ "$2" ]; then
  IMAGE_VERSION=$2
fi

REGISTRY_URL=localhost:32000
if [ "$3" ]; then
  REGISTRY_URL=$3
fi

K8S_SERVICE_NAMSPACE=k8s-containerized-services
if [ "$4" ]; then
  K8S_SERVICE_NAMSPACE=$4
fi

echo "Move file all content in  $HOME/microservice-k8s-tar/k8s-example-tar-folder/ go outside"
if [ -d "$HOME"/microservice-k8s-tar/k8s-example-tar-folder/ ]; then
	mv -v "$HOME"/microservice-k8s-tar/k8s-example-tar-folder/* $HOME/microservice-k8s-tar/
	sudo rm -r "$HOME"/microservice-k8s-tar/k8s-example-tar-folder
fi

echo "Move file all content in $HOME/microservice-k8s-tar/$COMMIT_HASH/k8s-example-tar-folder/ go outside"
if [ -d "$HOME"/microservice-k8s-tar/$COMMIT_HASH/k8s-example-tar-folder/ ]; then
	mv -v "$HOME"/microservice-k8s-tar/$COMMIT_HASH/k8s-example-tar-folder/* "$HOME"/microservice-k8s-tar/
	sudo rm -r "$HOME"/microservice-k8s-tar/$COMMIT_HASH/k8s-example-tar-folder
fi

echo "Move file all content in $HOME/microservice-k8s-tar/$COMMIT_HASH/$COMMIT_HASH/ go outside"
if [ -d "$HOME"/microservice-k8s-tar/$COMMIT_HASH/$COMMIT_HASH/ ]; then
	mv -v "$HOME"/microservice-k8s-tar/$COMMIT_HASH/$COMMIT_HASH/* $HOME/microservice-k8s-tar/$COMMIT_HASH/
	sudo rm -r "$HOME"/microservice-k8s-tar/$COMMIT_HASH/$COMMIT_HASH
fi

echo "############################################### My name is $USER";




######################################################### change config first ###############################

for entry in "$HOME/microservice-k8s-tar/$COMMIT_HASH/config"/*
do
    echo "######################## microk8s kubectl apply -f $entry ..."
	
	#for (( i=0; i<${#CONTAINER_NAME[@]}; i++ ));
	#do
	#	containerN="${CONTAINER_NAME[$i]}"
	#	echo "#############################3 config file: $entry"
	#	if [[ "$entry" == *"$containerN"* ]]; then
	#		echo "############################# replace data s|image:\s+$containerN.*|image: $containerN$COMMIT_HASH:$IMAGE_VERSION|g to $entry"
	#		#sudo sed -i -E "s|(\s+)image:\s*.*$containerN.*|\1image: $REGISTRY_URL/${containerN}_${COMMIT_HASH}:$IMAGE_VERSION|g" $entry
	#		break;
	#	fi
	#done
	
	sudo microk8s kubectl apply -f "$entry"
done


#################################################################change image and resource later#######################

declare -a CONTAINER_NAME=("containerized-accounts" "containerized-config-server" "containerized-discovery" "containerized-gateway" "containerized-logstash" "containerized-main" "containerized-orders" "containerized-products" "containerized-prometheus" "zipkin-server")
declare -a DEPLOYMENT_NAME=("k8s-service-accounts" "k8s-service-config-server" "k8s-service-discovery" "k8s-service-gateway" "k8s-service-logstash" "k8s-service-main" "k8s-service-orders" "k8s-service-products" "k8s-service-prometheus" "k8s-service-zipkin")

for entry in "$HOME/microservice-k8s-tar/$COMMIT_HASH/image"/*
do
	IFS='/' read -ra ADDR <<< "$entry"
	FILE="${ADDR[-1]}"
	
	IFS='.' read -ra SPLIT <<< "$FILE"
	
	echo "######################## sudo docker load -i $HOME/microservice-k8s-tar/$COMMIT_HASH/image/$FILE "
	# https://microk8s.io/docs/registry-built-in
	sudo docker load -i "$HOME"/microservice-k8s-tar/$COMMIT_HASH/image/"$FILE"
	
	echo "######################## sudo docker tag ${SPLIT[0]}:$IMAGE_VERSION $REGISTRY_URL/${SPLIT[0]}:$IMAGE_VERSION"
	sudo docker tag "${SPLIT[0]}:$IMAGE_VERSION"  "$REGISTRY_URL/${SPLIT[0]}:$IMAGE_VERSION"
	
	echo "sudo docker push $REGISTRY_URL/${SPLIT[0]}:$IMAGE_VERSION"
	sudo docker push "$REGISTRY_URL/${SPLIT[0]}:$IMAGE_VERSION"
	
	echo "sudo docker images $REGISTRY_URL/*"
	sudo docker images "$REGISTRY_URL"/*
	#sudo docker image tag "$SPLIT[0]":$IMAGE_VERSION linhpv5555/"$SPLIT[0]":$IMAGE_VERSION
	#sudo docker image push linhpv5555/"$SPLIT[0]":$IMAGE_VERSION
	
	
	echo "######################## microk8s ctr image import $FILE ... "
	# https://microk8s.io/docs/registry-images
	sudo microk8s ctr image import $HOME/microservice-k8s-tar/$COMMIT_HASH/image/"$FILE"
    #sudo microk8s ctr images ls
	
	IFS='_' read -ra NAME <<< "${ADDR[-1]}"
	containerName="${NAME[0]}"
	
	for (( i=0; i<${#CONTAINER_NAME[@]}; i++ ));
	do
	  if [[ "$containerName" == *"${CONTAINER_NAME[$i]}"* ]]; then
	  
	    echo "######################## microk8s kubectl set image deployment/${DEPLOYMENT_NAME[$i]} ..."
	    # kubectl set image deployment/<<deployment-name>> -n=<<namespace>> <<container_name>>=<<your_dockerhub_username>>/<<image_name you want to set now>>:<<tag_of_the_image_you_want>>
		DEPLOYNAME="${DEPLOYMENT_NAME[$i]}"
		CONTAINERNAME="${CONTAINER_NAME[$i]}"
		
		sudo microk8s kubectl set image deployment/"$DEPLOYNAME" -n=$K8S_SERVICE_NAMSPACE $CONTAINERNAME=$REGISTRY_URL/"${SPLIT[0]}:$IMAGE_VERSION" --record
		
		echo "######################## microk8s kubectl microk8s kubectl rollout history deployment/$DEPLOYNAME..."
		#sudo microk8s kubectl rollout status deployment/$DEPLOYMENT_NAME[$i] -n=$K8S_SERVICE_NAMSPACE
		sudo microk8s kubectl rollout history deployment/"$DEPLOYNAME" -n=$K8S_SERVICE_NAMSPACE

		#undo most recent update 
		#sudo microk8s kubectl rollout undo deployment/${DEPLOYMENT_NAME[$i]}
	  fi
	done
	
done



########################################################################################

# remove oldest folder or file
echo "Remove oldest folder or file in $HOME/microservice-k8s-tar/ folder. Keeping max 5 file or folder in it."
LIST_DATA="($(ls -1t -d "$HOME/microservice-k8s-tar/"*))"
#lentghLD=$(( ${#LIST_DATA[@]} - 6))
lentghLD=${#LIST_DATA[@]}

for (( i=5; i<lentghLD; i++ ));
  do
    echo "DATA: ${LIST_DATA[$i]}"
	if [[ -d "${LIST_DATA[$i]}" ]]; then
		sudo rm -r "${LIST_DATA[$i]}"
    fi
	if [[ -e "${LIST_DATA[$i]}" ]]; then
		sudo rm "${LIST_DATA[$i]}"
    fi
done

unset COMMIT_HASH;
unset IMAGE_VERSION;
unset K8S_SERVICE_NAMSPACE;
unset CONTAINER_NAME;
unset DEPLOYMENT_NAME;
unset LIST_DATA;
unset lentghLD;
unset REGISTRY_URL;