#!/bin/bash


DIR_PATH=$PWD
if [ "$1" ]; then
	DIR_PATH=$1
fi

if [ ! -d "$DIR_PATH" ]; then
    echo "Directory $DIR_PATH not exists"
fi

GIT_CURR_COMMIT=
if [  "$2" ]; then
    GIT_CURR_COMMIT=$2
fi

VERSION=local
if [ "$3" ]; then
    VERSION=$3
fi

GIT_PRE_COMMIT=
if [ "$4" ]; then
    GIT_PRE_COMMIT=$4
fi

SOURCE_BRANCH=
if [ "$5" ]; then
    SOURCE_BRANCH=$5
fi

TARGET_BRANCH=
if [ "$6" ]; then
    TARGET_BRANCH=$6
fi



echo "GIT_CURR_COMMIT=$GIT_CURR_COMMIT"
echo "GIT_PRE_COMMIT=$GIT_PRE_COMMIT"


# check folder contain tar file is exist, if not create it, else clear it
if [ ! -d $HOME/k8s-example-tar-folder ]; then
	echo "$HOME/k8s-example-tar-folder does not exist. Create it !!!"
else 
    echo "$HOME/k8s-example-tar-folder existed, clean all child."
	sudo rm -r $HOME/k8s-example-tar-folder
fi

mkdir "$HOME"/k8s-example-tar-folder
mkdir "$HOME"/k8s-example-tar-folder/$GIT_CURR_COMMIT/
mkdir "$HOME"/k8s-example-tar-folder/$GIT_CURR_COMMIT/image
mkdir "$HOME"/k8s-example-tar-folder/$GIT_CURR_COMMIT/config


function build_docker_image {
	local containerName=$1
	if [ -e $containerName/Dockerfile ]; then
	    echo "########## sudo docker build . -t ${containerName}_${GIT_COMMIT}:$VERSION -f $containerName/Dockerfile ...."
	 	sudo docker build . -t ${containerName}_${GIT_CURR_COMMIT}:$VERSION -f $containerName/Dockerfile
		if [ ! -e "$HOME"/k8s-example-tar-folder/$GIT_CURR_COMMIT/image/${containerName}_${GIT_CURR_COMMIT}.tar ]; then
			sudo docker save ${containerName}_${GIT_CURR_COMMIT} > "$HOME"/k8s-example-tar-folder/$GIT_CURR_COMMIT/image/${containerName}_${GIT_CURR_COMMIT}.tar
		fi
	fi
}

#
# *************) Chatgpt give the command to check file change.

#git --git-dir=$MONOREPO_PATH/.git diff --quiet HEAD^ HEAD -- $service

##### explain:

# git --git-dir=$MONOREPO_PATH/.git: This specifies the location of the .git directory for the monorepo. By default, Git looks for the .git directory in the current working directory, but we're specifying the location of the top-level .git directory for the monorepo.

# diff: This is the Git command to show the differences between two commits.

# --quiet: This option tells Git to not output any differences if there are no changes.

# HEAD^ HEAD: This specifies the range of commits to compare. HEAD^ represents the previous commit (i.e. the commit before the current HEAD commit), and HEAD represents the current commit.

# -- $service: This limits the comparison to only the changes in the $service directory.
#
#
# check if a variable is not null using -n
if [  -n "${TARGET_BRANCH}" ] || [ "$GIT_PRE_COMMIT" != "$GIT_CURR_COMMIT" ]; then
	set -eo pipefail
	CHANGED_FILE_FOLDER=
	echo "########### detect GIT_PRE_COMMIT and GIT_CURR_COMMIT is differences or not. If not using another command. "
	if [[ -n "${GIT_PRE_COMMIT}" && -n "${GIT_CURR_COMMIT}" && "$GIT_PRE_COMMIT" != "$GIT_CURR_COMMIT" ]]; then
	  echo "####### Valid command: git diff --name-only $GIT_PRE_COMMIT $GIT_CURR_COMMIT $DIR_PATH";
		if git diff --name-only $GIT_PRE_COMMIT $GIT_CURR_COMMIT "$DIR_PATH"; then
		  echo "############# running command: git diff --name-only $GIT_PRE_COMMIT $GIT_CURR_COMMIT $DIR_PATH"
			CHANGED_FILE_FOLDER=$(git diff --name-only $GIT_PRE_COMMIT $GIT_CURR_COMMIT "$DIR_PATH")
		fi
	else
	   echo "####### Valid command: git diff --name-only $SOURCE_BRANCH..$TARGET_BRANCH $DIR_PATH";
		if git diff --name-only $SOURCE_BRANCH..$TARGET_BRANCH "$DIR_PATH"; then
			echo "############# running command: git diff --name-only $SOURCE_BRANCH..$TARGET_BRANCH $DIR_PATH"
			CHANGED_FILE_FOLDER=$(git diff --name-only $SOURCE_BRANCH..$TARGET_BRANCH "$DIR_PATH")
		fi
	fi

	if [ -z "$CHANGED_FILE_FOLDER" ]; then
		echo "############### No changes detected..."
	else
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

		#check list folder will apply in jenkins global environment in the future
		declare -a LIST_PROJECT_FOLDER=("containerized-accounts/" "containerized-config-server/" "containerized-discovery/" "containerized-gateway/" "containerized-logstash/" "containerized-main/" "containerized-orders/" "containerized-products/" "containerized-prometheus/" "zipkin-server/");
		declare -a LIST_CONTAINER_NAME=("containerized-accounts" "containerized-config-server" "containerized-discovery" "containerized-gateway" "containerized-logstash" "containerized-main" "containerized-orders" "containerized-products" "containerized-prometheus" "zipkin-server")
		declare -A FOLDER_NEED_TO_CHECK

		declare -a LIST_K8S_CONFIG=("configmap" "deployment" "service" "ingress" "nginx" "namespace" "config")
		listK8sConfigLength=${#LIST_K8S_CONFIG[@]}
		declare -A LIST_K8S_FILE

		for filePath in ${CHANGED_FILE_FOLDER[@]}
		do
			echo "######################### File change path to check: ${filePath} "
			IFS='/' read -ra PATHS <<< "${filePath}"
			file_ext=$(printf '%s' "$filePath" | awk -F . '{if (NF>1) {print $NF}}')

			isIgnore=1
			for (( index=0; index<${#PATHS[@]}; index++ ));
			do
				if [ "${HM_IGNORE_TRAVERSAL_FOLDER_MVN["${PATHS[index]}"]}" ]; then
					isIgnore=0
					break
				fi
			done

			if [[ $isIgnore -eq 1 ]]; then
				for (( ind=0; ind<${#LIST_PROJECT_FOLDER[@]}; ind++ ));
				do
					echo "${LIST_PROJECT_FOLDER[$ind]} with ${PATHS[0]}/"
					if [[ "${LIST_PROJECT_FOLDER[$ind]}" == "${PATHS[0]}/" ]]; then
						echo "######### Equal ${LIST_PROJECT_FOLDER[$ind]}==*${PATHS[0]}*"
						FOLDER_NEED_TO_CHECK["${LIST_PROJECT_FOLDER[$ind]}"]="${LIST_CONTAINER_NAME[$ind]}"
					fi
				done
			fi

			for (( pos=0; pos<${listK8sConfigLength}; pos++ ));
			do
			  echo "############# Detect change ${PATHS[-1]} == *${LIST_K8S_CONFIG[$pos]}* and ext=$file_ext"
				if [[ "${PATHS[-1]}" == *"${LIST_K8S_CONFIG[$pos]}"* && ( "$file_ext" == "yml" || "$file_ext" == "yaml" ) ]]; then
					LIST_K8S_FILE["$filePath"]=$filePath
				fi
			done
		done


		for key in ${!FOLDER_NEED_TO_CHECK[@]}
		do
			echo "exist image key:  $key"
			if [ -e "${key}pom.xml" ]; then
				mvn -f "${key}pom.xml" -Dmaven.test.skip=false -Dmaven.test.failure.ignore=false clean package
			fi
		done

		for value in ${FOLDER_NEED_TO_CHECK[@]}
		do
			echo "############### exist image value: $value"
			build_docker_image "$value"
		done

		#for key in ${!LIST_K8S_FILE[@]}; do echo $key; done
		#for value in ${LIST_K8S_FILE[@]}; do echo $value; done
		for i in ${!LIST_K8S_FILE[@]}
		do
		  echo "move file path: ${LIST_K8S_FILE[$i]}"
		  TEMP="${LIST_K8S_FILE[$i]}"
		  IFS='/' read -ra PATHS <<< "${LIST_K8S_FILE[$i]}"

		  NEWNAME=
		  for (( ind=0; ind<$(( ${#PATHS[@]} - 1 )); ind++ ));
		  do
			  NEWNAME+="${PATHS[$ind]}_"
		  done
		  NEWNAME+="${PATHS[-1]}"

		  #sudo touch $HOME/k8s-example-tar-folder/$GIT_CURR_COMMIT/config/${NEWNAME}
		  sudo mv "$TEMP" "$HOME"/k8s-example-tar-folder/$GIT_CURR_COMMIT/config/"${NEWNAME}"

		done

		unset CHANGED_FILE_FOLDER;
		unset HM_IGNORE_TRAVERSAL_FOLDER_MVN;
		unset LIST_PROJECT_FOLDER;
		unset DIR_PATH;
		unset LIST_CONTAINER_NAME;
		unset FOLDER_NEED_TO_CHECK;
		unset LIST_K8S_CONFIG;
		unset NEWNAME;
		unset TEMP;
		unset listK8sConfigLength;
		
	fi
fi


