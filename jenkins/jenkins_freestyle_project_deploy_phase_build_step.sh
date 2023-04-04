#!/bin/bash

echo "####################################################### step 1 ##################################################################"
######################################### step 1 #####################################################################################
export MAVEN_HOME=/opt/apache-maven-3.6.3
export PATH=$PATH:$MAVEN_HOME/bin
mvn --version
#mvn -Dmaven.test.failure.ignore=true clean package




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

# improvement  

if [ -z "$GIT_COMMIT" ]; then
    echo "No current commit... !"
    mvn -Dmaven.test.failure.ignore=false clean package
	exit 0
fi

if [ -z "$GIT_PREVIOUS_SUCCESSFUL_COMMIT" ]; then
    echo "No previous success commit !"
fi


echo "GIT_COMMIT=$GIT_COMMIT"
echo "GIT_PREVIOUS_SUCCESSFUL_COMMIT=$GIT_PREVIOUS_SUCCESSFUL_COMMIT"

VERSION=local
#check is exist global environment $IMAGE_VERSION (create by you)
if [[ -n "${IMAGE_VERSION}" ]]; then 
	VERSION=${IMAGE_VERSION}
fi





echo "####################################################### step 2 ##################################################################"
######################################### step 2 #######################################################################################

# in jenkins we can use ${GIT_BRANCH} env
CURRENT_BRANCH_NAME=
if [[ -n "${GIT_BRANCH}" ]]; then 
	CURRENT_BRANCH_NAME=${GIT_BRANCH}
else 
	CURRENT_BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
fi

echo "CURRENT BRANCH NAME: $CURRENT_BRANCH_NAME"
#CURRENT_HASH=$(git rev-parse HEAD)
CURRENT_HASH=$(git rev-parse $CURRENT_BRANCH_NAME)

CURRENT_BRANCH_NAME_FORMAT=$(echo "$CURRENT_BRANCH_NAME"| awk '{c=$1; gsub(/[/]/,"__"); $1=c; print; }' FS= OFS=)
CURRENT_BRANCH_NAME_FORMAT_AS_FILE_NAME="$CURRENT_BRANCH_NAME_FORMAT.txt"

if [ ! -d $HOME/git-hist ]; then
	echo "############### $HOME/git-hist does not exist. Create it !!!"
	mkdir $HOME/git-hist
else 
    if [ ! -e $HOME/git-hist/$CURRENT_BRANCH_NAME_FORMAT_AS_FILE_NAME ]; then
		echo "############### $HOME/git-hist does not exist. Create it !!!"
	    touch $HOME/git-hist/$CURRENT_BRANCH_NAME_FORMAT_AS_FILE_NAME	
	fi
fi

PREVIOUS_BUILD_COMMIT_HASH=
PREVIOUS_BUILD_COMMIT_HASH_TIME=0
if [ -s "$HOME/git-hist/$CURRENT_BRANCH_NAME_FORMAT_AS_FILE_NAME" ]; then
	set -eo pipefail
	PREVIOUS_BUILD_COMMIT_HASH=$(<$HOME/git-hist/$CURRENT_BRANCH_NAME_FORMAT_AS_FILE_NAME)
	
	#https://unix.stackexchange.com/questions/307690/checking-for-errors-in-bash-script
	SHA=
	if git cat-file -t $PREVIOUS_BUILD_COMMIT_HASH; then
		SHA=$(git cat-file -t $PREVIOUS_BUILD_COMMIT_HASH)
	fi
	
	if [ "$SHA" == "commit" ]; then
		PREVIOUS_BUILD_COMMIT_HASH_TIME=$(git show -s --format=%ct $PREVIOUS_BUILD_COMMIT_HASH)
	fi
	unset SHA
fi
echo "PREVIOUS_BUILD_COMMIT_HASH = $PREVIOUS_BUILD_COMMIT_HASH"
echo "PREVIOUS_BUILD_COMMIT_HASH_TIME = $PREVIOUS_BUILD_COMMIT_HASH_TIME"

unset CURRENT_BRANCH_NAME_FORMAT;
unset PREVIOUS_BUILD_COMMIT_HASH;



# -z option is used to check whether a string variable is null
# check if a variable is not null using -n
if [ -n "${ghprbTargetBranch}" ] || [ -n "$GIT_PREVIOUS_SUCCESSFUL_COMMIT" ]; then
	 # 1 dir path workplace
	 # 2 current git commit
	 # 3 previous git commit 
	 # 4 image docker version
	 #
	chmod +x $PWD/jenkins/jenkins_deploy_phase_detect_source_services_change.sh
	bash $PWD/jenkins/jenkins_deploy_phase_detect_source_services_change.sh $PWD $GIT_COMMIT $VERSION $GIT_PREVIOUS_SUCCESSFUL_COMMIT $ghprbSourceBranch $ghprbTargetBranch
	
	# keep success hash commit to file
	echo "$CURRENT_HASH" > $HOME/git-hist/$CURRENT_BRANCH_NAME_FORMAT_AS_FILE_NAME
	unset CURRENT_BRANCH_NAME_FORMAT_AS_FILE_NAME;
	
	chmod +x $PWD/jenkins/ssh_run_k8s_remote_server_script.sh
	bash $PWD/jenkins/ssh_run_k8s_remote_server_script.sh $REMOTE_USER $REMOTE_IP $REMOTE_HOME_PATH $JENKIN_SSH_KEY_PATH $GIT_COMMIT $VERSION
	
	exit 0;
fi




#CURRENT_HASH="${CURRENT_HASH:0:7}"

echo "CURRENT_HASH (of branch $CURRENT_BRANCH_NAME) = $CURRENT_HASH"
# Define a function to check if a file has the newest commit
function is_later_commit {
  # newest_hash=$(git log --pretty=format:'%h' -n 1 -- "$1") =>  take the first seven characters of commit hash
  set -eo pipefail
  local newest_hash=$(git log --pretty=format:'%H' -n 1 -- "$1")
  
  #if dont have any hash
  if [[ -z $newest_hash ]]; then
	return $(false)
  fi
  
  # echo "newest hash $newest_hash"
  set -eo pipefail
  local newest_hash_time=$(git show -s --format=%ct $newest_hash)
  # -ge => greater than or equal
  # -gt => greater than
  if [[ "$newest_hash_time" -ge "$PREVIOUS_BUILD_COMMIT_HASH_TIME" || "$PREVIOUS_BUILD_COMMIT_HASH_TIME" == 0 ]]; then
    return $(true)
  fi
  return $(false)
}








######################################## step 2.1 #######################################################################################
echo "####################################################### step 2.1 ##################################################################"
# check folder contain tar file is exist, if not create it, else clear it
if [ ! -d $HOME/k8s-example-tar-folder ]; then
	echo "$HOME/k8s-example-tar-folder does not exist. Create it !!!"
else 
    echo "$HOME/k8s-example-tar-folder existed, clean all child."
	sudo rm -r $HOME/k8s-example-tar-folder
fi

mkdir $HOME/k8s-example-tar-folder
mkdir $HOME/k8s-example-tar-folder/$CURRENT_HASH/
mkdir $HOME/k8s-example-tar-folder/$CURRENT_HASH/image
mkdir $HOME/k8s-example-tar-folder/$CURRENT_HASH/config

function build_docker_image {
	
	#sudo docker build . -t containerized-discovery-$GIT_COMMIT:v1.0.0 -f containerized-discovery/Dockerfile
	#if [ ! -d $HOME/k8s-example-tar-folder ]; then
	#	echo "$HOME/k8s-example-tar-folder does not exist. Create it !!!"
	#	mkdir $HOME/k8s-example-tar-folder
	#fi

	#if [ ! -e $HOME/k8s-example-tar-folder/containerized-discovery-$GIT_COMMIT:v1.0.0.tar ]; then
	#	sudo docker save containerized-discovery-$GIT_COMMIT:v1.0.0 > $HOME/k8s-example-tar-folder/containerized-discovery-$GIT_COMMIT:v1.0.0.tar
	#fi
	
	local containerName=$1
	if [ -e $containerName/Dockerfile ]; then
		#https://unix.stackexchange.com/questions/88452/concatenating-two-variables-with-an-underscore
		echo "########## sudo docker build . -t ${containerName}_${GIT_COMMIT}:$VERSION -f $containerName/Dockerfile ...."
		sudo docker build . -t ${containerName}_${GIT_COMMIT}:$VERSION -f $containerName/Dockerfile
		if [ ! -e $HOME/k8s-example-tar-folder/$CURRENT_HASH/image/${containerName}_${GIT_COMMIT}.tar ]; then
			sudo docker save ${containerName}_${GIT_COMMIT} > $HOME/k8s-example-tar-folder/$CURRENT_HASH/image/${containerName}_${GIT_COMMIT}.tar
		fi
	fi
}


#https://unix.stackexchange.com/questions/437680/set-data-structure-equivalent-in-bash-shell
# ignore some folders we dont need to traversal
declare -A HM_IGNORE_TRAVERSAL_FOLDER_MVN
#HM_IGNORE_TRAVERSAL_FOLDER_MVN[java]=1
HM_IGNORE_TRAVERSAL_FOLDER_MVN[target]=1
HM_IGNORE_TRAVERSAL_FOLDER_MVN[.settings]=1
HM_IGNORE_TRAVERSAL_FOLDER_MVN[.mvn]=1
HM_IGNORE_TRAVERSAL_FOLDER_MVN[assets]=1
HM_IGNORE_TRAVERSAL_FOLDER_MVN[.git]=1
HM_IGNORE_TRAVERSAL_FOLDER_MVN[k8s]=1
HM_IGNORE_TRAVERSAL_FOLDER_MVN[containerized-zipkin]=1
HM_IGNORE_TRAVERSAL_FOLDER_MVN[jenkins]=1
HM_IGNORE_TRAVERSAL_FOLDER_MVN[server-config-git-repository]=1
HM_IGNORE_TRAVERSAL_FOLDER_MVN[microk8s-system-config]=1

# Define a function to check if a folder has the newest commit
function check_folder_has_newest_commit {
  # Check if any file or child folder has the newest commit
  for item in *; do
    #echo "check $item"
    if is_later_commit "$item"; then
      return $(true)
    fi
    if [[ -d "$item" ]]; then
		if [ ! "${HM_IGNORE_TRAVERSAL_FOLDER_MVN["$item"]}" ]; then
	       #echo "go to child folder $item"
		  cd $item
		  if check_folder_has_newest_commit "$item"; then
			return $(true)
		  fi
		  cd ..
		fi
    fi
  done
  return $(false)
}






echo "####################################################### step 2.2 ##################################################################"
######################################## step 2.2 #######################################################################################
declare -a LIST_FOLDER_NEWEST_UPDATE=()
# Loop through each subdirectory
for folder in */; do
  # Move into the subdirectory
  #echo "move to $folder"
  cd "$folder"
  # Check if the subdirectory has the newest commit
  if check_folder_has_newest_commit "."; then
    echo "$folder is up to date"
	LIST_FOLDER_NEWEST_UPDATE+=("$folder")
  else
    echo "$folder is not up to date"
  fi
  # Move back to the parent directory
  cd ..
done

echo "execute $LIST_FOLDER_NEWEST_UPDATE"


# // TODO
#check list folder will apply in jenkins global environment in the future
declare -a LIST_PROJECT_FOLDER=("containerized-accounts/" "containerized-config-server/" "containerized-discovery/" "containerized-gateway/" "containerized-logstash/" "containerized-main/" "containerized-orders/" "containerized-products/" "containerized-prometheus/" "zipkin-server/")
declare -a LIST_CONTAINER_NAME=("containerized-accounts" "containerized-config-server" "containerized-discovery" "containerized-gateway" "containerized-logstash" "containerized-main" "containerized-orders" "containerized-products" "containerized-prometheus" "zipkin-server")
arrayListProjectLength=${#LIST_PROJECT_FOLDER[@]}

echo "the PWD is : ${PWD}"
for folder in ${LIST_FOLDER_NEWEST_UPDATE[@]}
do
    echo $folder
	for (( i=0; i<arrayListProjectLength; i++ ));
	do
	  echo "index: $i, value: ${LIST_PROJECT_FOLDER[$i]}"
	  if [[ "${LIST_PROJECT_FOLDER[$i]}" == *"$folder"* ]]; then
		if [ -e "${LIST_PROJECT_FOLDER[$i]}pom.xml" ]; then
			mvn -f "${LIST_PROJECT_FOLDER[$i]}pom.xml" -Dmaven.test.failure.ignore=true clean package
			# mvn -Dmaven.test.failure.ignore=true clean package
			build_docker_image "${LIST_CONTAINER_NAME[$i]}"
		fi
	  fi
	done
done

unset LIST_FOLDER_NEWEST_UPDATE;
unset LIST_PROJECT_FOLDER;
unset LIST_CONTAINER_NAME;
unset arrayListProjectLength;
unset HM_IGNORE_TRAVERSAL_FOLDER_MVN;








echo "####################################################### step 2.3 ##################################################################"
####################################################################################### step 2.3 #######################################################################################

# //TODO
# will apply in jenkins global environment
declare -a LIST_K8S_CONFIG=("configmap" "deployment" "service" "ingress" "nginx" "namespace" "config")
declare -A LIST_K8S_FILE

declare -A HM_IGNORE_TRAVERSAL_FOLDER
HM_IGNORE_TRAVERSAL_FOLDER[java]=1
HM_IGNORE_TRAVERSAL_FOLDER[target]=1
HM_IGNORE_TRAVERSAL_FOLDER[.settings]=1
HM_IGNORE_TRAVERSAL_FOLDER[.mvn]=1
HM_IGNORE_TRAVERSAL_FOLDER[assets]=1
HM_IGNORE_TRAVERSAL_FOLDER[.git]=1

#recursive check all config file with newest hash commit git
function recurs_check_config {
	for entry in "$1"/*
	do
	  IFS='/' read -ra ADDR <<< "$entry"
	  if [[ -d "$entry" ]]; then
	     if [ ! "${HM_IGNORE_TRAVERSAL_FOLDER["${ADDR[-1]}"]}" ]; then
	       recurs_check_config "$entry"
		 fi
	  else
        file_ext=$(printf '%s' "$entry" | awk -F . '{if (NF>1) {print $NF}}')
		for (( i=0; i<${#LIST_K8S_CONFIG[@]}; i++ ));
		do
		  set -eo pipefail
		  local newest_hash=$(git log --pretty=format:'%H' -n 1 -- "$entry")
		  set -eo pipefail
		  local newest_hash_time=$(git show -s --format=%ct $newest_hash)
		  # check config file is mapping with LIST_K8S_CONFIG
		  #                   with extension file is yml or yaml
		  #                   newest hash is equal with newest hash of file
		  if [[ "${ADDR[-1]}" == *"${LIST_K8S_CONFIG[$i]}"* && ( "$file_ext" == "yml" || "$file_ext" == "yaml" ) && ( "$newest_hash_time" -ge "$PREVIOUS_BUILD_COMMIT_HASH_TIME" || "$PREVIOUS_BUILD_COMMIT_HASH_TIME" == 0 ) ]]; then
			LIST_K8S_FILE["$entry"]=$entry
		  fi
		done
	  fi
	done
}

recurs_check_config $PWD;

#for key in ${!LIST_K8S_FILE[@]}; do echo $key; done
#for value in ${LIST_K8S_FILE[@]}; do echo $value; done
for i in ${!LIST_K8S_FILE[@]}
do
  echo "move file path: ${LIST_K8S_FILE[$i]}"
  TEMP="${LIST_K8S_FILE[$i]}"
  IFS='/' read -ra PATHS <<< "${LIST_K8S_FILE[$i]}"
  
  NEWNAME=
  lastIndex=$(( ${#PATHS[@]} - 1 ))
  for (( ind=0; ind<lastIndex; ind++ ));
  do
	  NEWNAME+="${PATHS[$ind]}_"
  done
  NEWNAME+="${PATHS[-1]}"
  
  #sudo touch $HOME/k8s-example-tar-folder/$CURRENT_HASH/config/${NEWNAME}
  sudo mv $TEMP $HOME/k8s-example-tar-folder/$CURRENT_HASH/config/${NEWNAME}
  
done

unset LIST_K8S_CONFIG;
unset LIST_K8S_FILE;
unset HM_IGNORE_TRAVERSAL_FOLDER;
unset NEWNAME;


echo "####################################################### step 3 ##################################################################"
####################################### step 3 #######################################################################################


# keep success hash commit to file
echo "$CURRENT_HASH" > $HOME/git-hist/$CURRENT_BRANCH_NAME_FORMAT_AS_FILE_NAME
unset CURRENT_BRANCH_NAME_FORMAT_AS_FILE_NAME;

/bin/bash -xe $PWD/jenkins/ssh_run_k8s_remote_server_script.sh $REMOTE_USER $REMOTE_IP $REMOTE_HOME_PATH $JENKIN_SSH_KEY_PATH $CURRENT_HASH $VERSION
    
unset CURRENT_HASH;
unset VERSION;
unset CURRENT_BRANCH_NAME;
unset PREVIOUS_BUILD_COMMIT_HASH;

unset REMOTE_USER;
unset REMOTE_IP;
unset REMOTE_HOME_PATH;
unset JENKIN_SSH_KEY_PATH;