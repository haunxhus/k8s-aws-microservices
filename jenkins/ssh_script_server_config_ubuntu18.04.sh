#!/bin/bash

sudo apt-get update

##########################
SSH_TYPE=$(dpkg --list | grep ssh)
if [[ "$SSH_TYPE" == *"openssh-server"* ]]; then
	echo "################################# ssh server was installed ##############################"
    ssh -V
else 	
    echo "################################### installing ssh-server #################################################################"
	sudo apt-get upgrade
	sudo apt-get install openssh-server
	# https://www.cyberciti.biz/faq/ubuntu-linux-install-openssh-server/
	sudo systemctl enable ssh --now
	sudo systemctl start ssh
	
	sudo ufw allow ssh
	sudo ufw enable
	sudo ufw status
fi
unset SSH_TYPE

############################

MY_NAME=$(whoami)

if [ "$1" ]; then
 MY_NAME=$1
fi

echo "######################### storage my name to file $HOME/storageName.txt"
sudo touch $HOME/storageName.txt
sudo echo "$MY_NAME" | sudo tee -a $HOME/storageName.txt > /dev/null
unset MY_NAME

if [ -e $HOME/sudoers.bak ]; then
    echo "######################### file $HOME/sudoers.bak is existed"
else
	echo "######################### File $HOME/sudoers.bak does not existed. Create it."
	sudo touch $HOME/sudoers.bak;
	
	sudo cp /etc/sudoers $HOME/sudoers.bak
    
	userName=$(cat $HOME/storageName.txt)
	sudo rm $HOME/storageName.txt
	# https://www.cyberciti.biz/faq/linux-unix-running-sudo-command-without-a-password/
	echo "######################### modify /etc/sudoers, allow $userName can do anything in system. $userName ALL=(ALL) NOPASSWD:ALL"
	File=/etc/sudoers
	if ! sudo grep -q "$userName ALL=(ALL)" "$File" ;then
	  # sudo echo $MY_NAME ALL = NOPASSWD: /bin/systemctl restart httpd.service, /bin/kill >> /etc/sudoers
	  # careful with that command
	  sudo echo "#config allow for $userName user" | sudo tee -a /etc/sudoers > /dev/null
	  sudo echo "$userName ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers > /dev/null
	fi
	unset File
	unset userName
fi


if [ ! -d $HOME/.ssh ]; then
  echo "$HOME/.ssh does not exist. Create it"
  mkdir $HOME/.ssh
fi

if [ ! -e $HOME/.ssh/config ]; then
	 echo "######################### $HOME/.ssh/config does not exist. Create it"
	 sudo touch $HOME/.ssh/config
	 sudo chown -R $USER:$USER /home/$USER/.ssh/config 
	 sudo chmod 600 $HOME/.ssh/config
fi

if [ ! -e $HOME/.ssh/known_hosts ]; then
	 echo "######################### $HOME/.ssh/known_hosts does not exist. Create it"
	 sudo touch $HOME/.ssh/known_hosts
	 sudo chown -v $USER $HOME/.ssh/known_hosts
	 sudo chmod 600 $HOME/.ssh/known_hosts
fi

##############################
if [ -e $HOME/.ssh/authorized_keys ]; then
	echo "######################### authorized_keys is existed. Do nothing";
else
	#sudo cat id_rsa.pub>>/home/$USER/.ssh/authorized_keys
	echo "######################### authorized_keys does not existed. Create it";
	sudo touch authorized_keys
	sudo chmod 700 $HOME/.ssh && chmod 600 $HOME/.ssh/authorized_keys
	sudo chown -R $USER:$USER $HOME/.ssh
fi

echo "######################### Config /etc/ssh/sshd_config to allow ssh withou password, using public key";
sudo sed -i -E "s|#?PasswordAuthentication.*|PasswordAuthentication no|g" /etc/ssh/sshd_config
sudo sed -i -E "s|#?PubkeyAuthentication.*|PubkeyAuthentication yes|g" /etc/ssh/sshd_config

sudo systemctl restart sshd