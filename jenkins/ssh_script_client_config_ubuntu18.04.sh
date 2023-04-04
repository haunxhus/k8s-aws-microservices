#!/bin/bash

sudo apt-get update

############
SSH_TYPE=$(dpkg --list | grep ssh)
if [[ "$SSH_TYPE" == *"openssh-client"* ]]; then
	echo "################################# ssh client was installed ##############################"
    ssh -V
else 	
    echo "################################### installing ssh-client #################################################################"
	sudo apt-get upgrade
	sudo apt-get install openssh-client
	sudo systemctl enable ssh --now
	sudo systemctl start ssh
	
	sudo ufw allow ssh
	sudo ufw enable
	sudo ufw status
fi
unset SSH_TYPE


if [ ! -d "$HOME"/.ssh ]; then
  echo "folder $HOME/.ssh does not exist. Created it !!!"
  mkdir "$HOME"/.ssh
fi

if [ ! -e "$HOME"/.ssh/config ]; then
	 echo "################################### file $HOME/.ssh/config does not exist. Created it !!!"
	 sudo touch "$HOME"/.ssh/config
	 sudo chown -R "$USER:$USER" "$HOME"/.ssh/config
	 sudo chmod 600 "$HOME"/.ssh/config
fi

if [ ! -e "$HOME"/.ssh/known_hosts ]; then
	 echo "################################### file $HOME/.ssh/known_hosts does not exist. Created it !!!"
	 sudo touch "$HOME"/.ssh/known_hosts
	 #sudo chgrp -R $USER $HOME/.ssh/known_hosts
	 sudo chown -v "$USER" "$HOME"/.ssh/known_hosts
fi

REMOTE_HOST_NAME=34.126.75.224
if [ "$1" ]; then
  REMOTE_HOST_NAME=$1
fi

REMOTE_USER=vienlv
if [ "$2" ]; then
 REMOTE_USER=$2
fi

FOLDER_STORE_SSH_KEY="$HOME/.ssh/remote-host-key"

FILE_NAME=$(echo $RANDOM | md5sum | head -c 20)


PATH_KEY="$FOLDER_STORE_SSH_KEY/$FILE_NAME"
if [ ! -d "$FOLDER_STORE_SSH_KEY" ]; then
  echo "################################### $FOLDER_STORE_SSH_KEY does not exist. Create it !!!"
  sudo mkdir "$FOLDER_STORE_SSH_KEY"
  sudo ssh-keygen -f "$PATH_KEY"  -t ed25519 -b 4096 -N '' # -N '' mean not enter passphrase
  sudo chgrp -R "$USER" "$FOLDER_STORE_SSH_KEY"
  sudo chgrp -R "$USER" "$PATH_KEY"
  sudo chgrp -R "$USER" "$PATH_KEY.pub"
  sudo chown -R "$USER:$USER" "$PATH_KEY"
  sudo chown -R "$USER:$USER" "$PATH_KEY.pub"
  sudo chmod 600 "$PATH_KEY"
fi

########### add public key to remote server (authorized_keys) under $PATH_KEY folder 

if ! sudo grep -q "$REMOTE_HOST_NAME" $HOME/.ssh/config; then 
	sudo echo "# ####zenkins server config to build host###" | sudo tee -a $HOME/.ssh/config > /dev/null
	sudo echo "# try to ssh $REMOTE_USER@$REMOTE_HOST_NAME" | sudo tee -a $HOME/.ssh/config > /dev/null
	sudo echo "Host $REMOTE_HOST_NAME" | sudo tee -a $HOME/.ssh/config > /dev/null
	sudo echo "     HostName $REMOTE_HOST_NAME" | sudo tee -a $HOME/.ssh/config > /dev/null
	sudo echo "     User $REMOTE_USER" | sudo tee -a $HOME/.ssh/config > /dev/null
	sudo echo "     PreferredAuthentications publickey" | sudo tee -a $HOME/.ssh/config > /dev/null
	sudo echo "     IdentitiesOnly yes" | sudo tee -a $HOME/.ssh/config > /dev/null
	sudo echo "     IdentityFile $PATH_KEY" | sudo tee -a $HOME/.ssh/config > /dev/null
	sudo echo "     UserKnownHostsFile $HOME/.ssh/known_hosts" | sudo tee -a $HOME/.ssh/config > /dev/null
	sudo echo "     Port 22" | sudo tee -a $HOME/.ssh/config > /dev/null
	eval $(ssh-agent -s)
	sudo ssh-keyscan -H $REMOTE_HOST_NAME >> $HOME/.ssh/known_hosts
    
	echo "################################### Random ssh keys was created at path: $PATH_KEY, please remember it."
	#add jenkins user to group
	groups
	#sudo usermod -a -G vienlv jenkins
	#sudo chmod g+rw $HOME/.ssh/
	#sudo chmod g+rw $HOME/.ssh/authorized_keys
	#sudo chmod g+r $HOME/.ssh/config
	#sudo chmod g+rw $HOME/.ssh/known_hosts
	
	#sudo chgrp -R $USER $FOLDER_STORE_SSH_KEY
	#sudo chgrp -R $USER $PATH_KEY
	#sudo chmod g+rw $FOLDER_STORE_SSH_KEY
	#sudo chmod g+rw $PATH_KEY
	
fi

unset MY_NAME
unset REMOTE_HOST_NAME
unset REMOTE_USER
unset FOLDER_STORE_SSH_KEY
unset FILE_NAME
unset PATH_KEY