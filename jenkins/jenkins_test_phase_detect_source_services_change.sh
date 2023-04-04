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

GIT_PRE_COMMIT=
if [ "$3" ]; then
    GIT_PRE_COMMIT=$3
fi

SOURCE_BRANCH=
if [ "$4" ]; then
    SOURCE_BRANCH=$4
fi

TARGET_BRANCH=
if [ "$5" ]; then
    TARGET_BRANCH=$5
fi


echo "GIT_CURR_COMMIT=$GIT_CURR_COMMIT"
echo "GIT_PRE_COMMIT=$GIT_PRE_COMMIT"


if [ -n "${ghprbTargetBranch}" ] || [ "$GIT_PRE_COMMIT" != "$GIT_CURR_COMMIT" ]; then
	set -eo pipefail
	CHANGED_FILE_FOLDER=
		echo "########### detect GIT_PRE_COMMIT and GIT_CURR_COMMIT is differences or not. If not using another command. "
	if [[ -n "$GIT_PRE_COMMIT" && -n "$GIT_CURR_COMMIT" && "$GIT_PRE_COMMIT" != "$GIT_CURR_COMMIT" ]]; then
	  echo "####### Valid and run command: git diff --name-only $GIT_PRE_COMMIT $GIT_CURR_COMMIT $DIR_PATH";
		if git diff --name-only $GIT_PRE_COMMIT $GIT_CURR_COMMIT "$DIR_PATH"; then
			echo "############# running command: git diff --name-only $GIT_PRE_COMMIT $GIT_CURR_COMMIT $DIR_PATH"
			CHANGED_FILE_FOLDER=$(git diff --name-only $GIT_PRE_COMMIT $GIT_CURR_COMMIT "$DIR_PATH")
		fi
	else
    echo "####### Valid command: git diff --name-only $SOURCE_BRANCH..$TARGET_BRANCH";
		if git diff --name-only "$SOURCE_BRANCH".."$TARGET_BRANCH"; then
			echo "############# running command: git diff --name-only $SOURCE_BRANCH..$TARGET_BRANCH $DIR_PATH"
			CHANGED_FILE_FOLDER=$(git diff --name-only "$SOURCE_BRANCH".."$TARGET_BRANCH" "$DIR_PATH")
		else
      echo "############# No detect change. Run all then exit."
    	mvn -Dmaven.test.failure.ignore=false clean package
    	exit 0;
		fi
	fi
	
	
	if [ -z "$CHANGED_FILE_FOLDER" ]; then
		echo "No changes detected..."
	else
		#check list folder will apply in jenkins global environment in the future
		declare -a LIST_PROJECT_FOLDER=("containerized-accounts/" "containerized-config-server/" "containerized-discovery/" "containerized-gateway/" "containerized-logstash/" "containerized-main/" "containerized-orders/" "containerized-products/" "containerized-prometheus/" "zipkin-server/");
		arrayListProjectLength=${#LIST_PROJECT_FOLDER[@]}
		declare -A FOLDER_NEED_TO_CHECK

		for filePath in ${CHANGED_FILE_FOLDER[@]}
		do
			IFS='/' read -ra PATHS <<< "${filePath}"
			for (( ind=0; ind<arrayListProjectLength; ind++ ));
			do
				if [[ "${LIST_PROJECT_FOLDER[$ind]}" == *"${PATHS[0]}"* ]]; then
					FOLDER_NEED_TO_CHECK["${LIST_PROJECT_FOLDER[$ind]}"]=1
				fi 
			done
		done

		for key in ${!FOLDER_NEED_TO_CHECK[@]}
		do 
			echo "exist $key"
			if [ -e "${key}pom.xml" ]; then
				mvn -f "${key}pom.xml" -Dmaven.test.skip=true -Dmaven.test.failure.ignore=true clean package
			fi
		done

		unset CHANGED_FILE_FOLDER;
		unset HM_IGNORE_TRAVERSAL_FOLDER_MVN;
		unset LIST_PROJECT_FOLDER;
		unset DIR_PATH;
		unset arrayListProjectLength;
	fi
fi


