#!/bin/bash

#sudo ssh -vvv vienlv@34.126.75.224
# cd $HOME
# sudo mkdir jenkins
# sudo ssh-keygen -t rsa -b 4096 -f /home/jenkins/id_rsa
# sudo chown -R jenkins:jenkins /home/jenkins
#

REMOTE_USER=vienlv
if [ "$1" ]; then
  REMOTE_USER=$1
fi


REMOTE_IP=34.124.237.137
if [ "$2" ]; then
  REMOTE_IP=$2
fi

REMOTE_HOME_PATH=/home/vienlv
if [ "$3" ]; then
  REMOTE_HOME_PATH=$3
fi

JENKIN_SSH_KEY_PATH=/home/jenkins/id_rsa
if [ "$4" ]; then
  JENKIN_SSH_KEY_PATH=$4
fi

CURRENT_HASH=
if [ "$5" ]; then
  CURRENT_HASH=$5
fi

VERSION=local
if [ "$6" ]; then
  VERSION=$6
fi

echo " ##################################### SSH to remote server $REMOTE_USER@$REMOTE_IP ###########################################";

#ssh -vvv -i /home/jenkins/id_rsa vienlv@34.126.75.224
#sudo scp /var/lib/jenkins/k8s-example-tar-folder/containerized-discovery-5eead8f264e217c7183cde558228e91e3b0684eb:v1.0.0.tar vienlv@34.126.75.224:/home/vienlv/microservice-k8s-tar/
#sudo scp $HOME/k8s-example-tar-folder/containerized-discovery-$GIT_COMMIT:v1.0.0.tar vienlv@34.126.75.224:/home/vienlv/microservice-k8s-tar/
#sudo scp $HOME/k8s-example-tar-folder/containerized-discovery-$GIT_COMMIT:v1.0.0.tar vienlv@34.126.75.224:/home/vienlv/microservice-k8s-tar/ && sudo ssh -vvv -o StrictHostKeyChecking=no -i /home/jenkins/id_rsa vienlv@34.126.75.224 << 'ENDSSH'

#sudo ssh -v -o StrictHostKeyChecking=no -i /home/jenkins/id_rsa $REMOTE_USER@$REMOTE_IP

# only remote to server if exist child file
# ref: https://stackoverflow.com/questions/91368/checking-from-shell-script-if-a-directory-contains-files
shopt -s nullglob dotglob     # To include hidden files
files=("$HOME"/k8s-example-tar-folder/$CURRENT_HASH/*)
if [ ${#files[@]} -gt 0 ]; then 
	
	echo "Starting SSH...."
	
	sudo ssh -v -o StrictHostKeyChecking=no -i "$JENKIN_SSH_KEY_PATH" "$REMOTE_USER"@$REMOTE_IP << EOSSH1
	echo "current location $(pwd)"
	echo "list directory"
	if [[ ! -d $REMOTE_HOME_PATH/microservice-k8s-tar/ ]]; then
		mkdir $REMOTE_HOME_PATH/microservice-k8s-tar/
	fi
EOSSH1
	
	set -eo pipefail
	sudo scp -r "$HOME"/k8s-example-tar-folder/ "$REMOTE_USER"@$REMOTE_IP:"$REMOTE_HOME_PATH"/microservice-k8s-tar/
	sudo scp -r "$PWD"/jenkins/containerized_build_k8s_scripts.sh "$REMOTE_USER"@$REMOTE_IP:"$REMOTE_HOME_PATH"/containerized_build_k8s_scripts.sh

#https://qirolab.com/posts/how-to-run-command-using-ssh-on-remote-machine-1602429142
	sudo ssh -v -o StrictHostKeyChecking=no -i $JENKIN_SSH_KEY_PATH $REMOTE_USER@$REMOTE_IP << EOSSH
	echo "current location $(pwd)"
	echo "list directory"
	sudo ls -la
	echo "What is my name: $USER"
	sudo chmod +x containerized_build_k8s_scripts.sh
	./containerized_build_k8s_scripts.sh $CURRENT_HASH $VERSION
	sudo rm containerized_build_k8s_scripts.sh
	
EOSSH
	#exit;
fi

unset CURRENT_HASH;
unset VERSION;
unset REMOTE_USER;
unset REMOTE_IP;
unset REMOTE_HOME_PATH;
unset JENKIN_SSH_KEY_PATH;
unset files;