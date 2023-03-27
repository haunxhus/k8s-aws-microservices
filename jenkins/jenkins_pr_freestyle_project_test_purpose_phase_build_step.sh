#!/bin/bash

echo "####################################################### step 1 ##################################################################"
######################################### step 1 #####################################################################################
export MAVEN_HOME=/opt/apache-maven-3.6.3
export PATH=$PATH:$MAVEN_HOME/bin
mvn --version
#mvn -Dmaven.test.failure.ignore=true clean package


# improvement 

if [ -z "$GIT_COMMIT" ]; then
    echo "No current commit... !"
    mvn -Dmaven.test.failure.ignore=false clean package
	exit 0
fi

if [ -z "$GIT_PREVIOUS_COMMIT" ]; then
    echo "No previous commit !"
fi


echo "GIT_COMMIT=$GIT_COMMIT"
echo "GIT_PREVIOUS_COMMIT=$GIT_PREVIOUS_COMMIT"



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

# get last commit of current branch (already checkout) in repo
CURRENT_HASH=$(git rev-parse HEAD)
# get lastest commit of curent branch from local
#CURRENT_HASH=$(git log -n 1 $CURRENT_BRANCH_NAME | grep commit | awk '{ print $2 }')

DIR_PATH=$PWD
if [ "$1" ]; then
	DIR_PATH=$1
fi

if [ ! -d "$DIR_PATH" ]; then
    echo "Directory $DIR_PATH not exists"
fi

#CHANGED=`git diff --name-only $GIT_PREVIOUS_COMMIT $GIT_COMMIT $PWD`
#
set -eo pipefail
echo "CURRENT BRANCH NAME: $CURRENT_BRANCH_NAME"
#CURRENT_HASH=$(git rev-parse $CURRENT_BRANCH_NAME)

CURRENT_BRANCH_NAME_FORMAT=$(echo "$CURRENT_BRANCH_NAME"| awk '{c=$1; gsub(/[/]/,"__"); $1=c; print; }' FS= OFS=)
CURRENT_BRANCH_NAME_FORMAT_AS_FILE_NAME="$CURRENT_BRANCH_NAME_FORMAT.txt"

if [ ! -d $HOME/git-hist ]; then
	echo "$HOME/git-hist does not exist. Create it !!!"
	mkdir "$HOME"/git-hist
else 
    if [ ! -e "$HOME"/git-hist/$CURRENT_BRANCH_NAME_FORMAT_AS_FILE_NAME ]; then
		  echo "$HOME/git-hist does not exist. Create it !!!"
	    touch "$HOME"/git-hist/$CURRENT_BRANCH_NAME_FORMAT_AS_FILE_NAME
	  fi
fi


#git log master..feature/test --format=format:"%H" --oneline | tail -1
PREVIOUS_BUILD_COMMIT_HASH=
PREVIOUS_BUILD_COMMIT_HASH_TIME=0
if [ -s "$HOME/git-hist/$CURRENT_BRANCH_NAME_FORMAT_AS_FILE_NAME" ]; then
	echo "$CURRENT_BRANCH_NAME_FORMAT_AS_FILE_NAME has commit. Check it."
	set -eo pipefail
	PREVIOUS_BUILD_COMMIT_HASH="$(<$HOME/git-hist/$CURRENT_BRANCH_NAME_FORMAT_AS_FILE_NAME)"
	set -e
	SHA=
	if git cat-file -t $PREVIOUS_BUILD_COMMIT_HASH; then
		SHA=$(git cat-file -t $PREVIOUS_BUILD_COMMIT_HASH)
	fi
	
	if [ "$SHA" == "commit" ]; then
		set -eo pipefail
		PREVIOUS_BUILD_COMMIT_HASH_TIME=$(git show -s --format=%ct $PREVIOUS_BUILD_COMMIT_HASH)
	fi
	unset SHA
fi

echo "PREVIOUS_BUILD_COMMIT_HASH = $PREVIOUS_BUILD_COMMIT_HASH"
echo "PREVIOUS_BUILD_COMMIT_HASH_TIME = $PREVIOUS_BUILD_COMMIT_HASH_TIME"


unset PREVIOUS_BUILD_COMMIT_HASH;
unset CURRENT_BRANCH_NAME_FORMAT;



# can we using ${ghprbActualCommit} replace for $GIT_COMMIT ????
if [ -n "${ghprbTargetBranch}" ] || [ "$GIT_PREVIOUS_COMMIT" != "$GIT_COMMIT" ]; then
    # 1 dir path workplace
	# 2 current git commit
	# 3 previous git commit 
	#
	chmod +x "$PWD"/jenkins/jenkins_test_phase_detect_source_services_change.sh
	bash "$PWD"/jenkins/jenkins_test_phase_detect_source_services_change.sh "$PWD" $GIT_COMMIT $GIT_PREVIOUS_COMMIT "${ghprbSourceBranch}" "${ghprbTargetBranch}"
	
	
	# keep success hash commit to file
	echo "$CURRENT_HASH" > "$HOME"/git-hist/$CURRENT_BRANCH_NAME_FORMAT_AS_FILE_NAME
	unset CURRENT_BRANCH_NAME_FORMAT_AS_FILE_NAME;
	
	exit 0;
fi



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


#https://unix.stackexchange.com/questions/437680/set-data-structure-equivalent-in-bash-shell
# ignore some folders we dont need to traversal
declare -A HM_IGNORE_TRAVERSAL_FOLDER_MVN
HM_IGNORE_TRAVERSAL_FOLDER_MVN[java]=1
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



echo "####################################################### step 3 ##################################################################"
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

echo "############# execute $LIST_FOLDER_NEWEST_UPDATE"

#check list folder will apply in jenkins global environment in the future
declare -a LIST_PROJECT_FOLDER=("containerized-accounts/" "containerized-config-server/" "containerized-discovery/" "containerized-gateway/" "containerized-logstash/" "containerized-main/" "containerized-orders/" "containerized-products/" "containerized-prometheus/" "zipkin-server/")

echo "############ the PWD is : ${PWD}"
for folder in ${LIST_FOLDER_NEWEST_UPDATE[@]}
do
    echo $folder
	for (( i=0; i<${#LIST_PROJECT_FOLDER[@]}; i++ ));
	do
	  echo "index: $i, value: ${LIST_PROJECT_FOLDER[$i]}"
	  if [[ "${LIST_PROJECT_FOLDER[$i]}" == *"$folder"* ]]; then
		if [ -e "${LIST_PROJECT_FOLDER[$i]}pom.xml" ]; then
			mvn -f "${LIST_PROJECT_FOLDER[$i]}pom.xml" -Dmaven.test.skip=false -Dmaven.test.failure.ignore=false clean package
		fi
	  fi
	done
done


# keep success hash commit to file
echo "$CURRENT_HASH" > "$HOME"/git-hist/$CURRENT_BRANCH_NAME_FORMAT_AS_FILE_NAME
unset CURRENT_BRANCH_NAME_FORMAT_AS_FILE_NAME;

unset LIST_FOLDER_NEWEST_UPDATE;
unset LIST_PROJECT_FOLDER;
unset HM_IGNORE_TRAVERSAL_FOLDER_MVN;

unset CURRENT_HASH;
unset CURRENT_BRANCH_NAME;
unset PREVIOUS_BUILD_COMMIT_HASH;