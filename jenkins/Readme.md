*) requirement:

- build k8s server:
    - memory: min 16gi
    - disk: min 60Gi
    - os: ubuntu 18.04
    - build basic sofwares: ../install_software_ubuntu_18.04.sh
        + run commands:     chmod +x install_software_ubuntu_18.04.sh
        +                   ./install_software_ubuntu_18.04.sh
        + while bulding please read careful the instruction. ex: enter ip range.

    - setup microservice core base project:
        + clone project from github: https://github.com/haunxhus/k8s-aws-microservices
        + run script: microk8s_kubernetes_build_script.sh, following instruction below:
          - chmod +x microk8s_kubernetes_build_script.sh
          - ./microk8s_kubernetes_build_script.sh

    - note:
        + we prefer using ubuntu 18.04 because we support write scripts to install basic softwares that save many time
          for you.
        + what install_software_ubuntu_18.04.sh do: install and setup envinroment help us do bussiness.
            -
                1. java jdk 13.02
                2. maven 3.6.3
                3. newest docker
                4. git
                5. node 16.19.0 (no need for now - can remove it in script)
                6. npm (no need for now - can remove it in script)
                7. nginx (no need for now - can remove it in script)
                8. microk8s
                9. tomcat 10.0.11 (no need for now - can remove it in script)
                   10. mysql

- build jenkins server:
    - memory: min 4gi
    - disk: min 30gi
    - os: ubuntu 18.04
    - build basic sofwares: ../install_jenkins_server_ubuntu18.04.sh
        + run command:     chmod +x install_jenkins_server_ubuntu18.04.sh
          ./install_jenkins_server_ubuntu18.04.sh
    - After succession install, check :
        + jenkins version: 2.387.1
        + java version: java13.0.1
        + maven: 3.6.3
        + docker version: Docker version 23.0.1, build a5ee5b1
        + git version: git version 2.17.1

    - note:
        + we prefer using ubuntu 18.04 because we support write scripts to install basic softwares that save many time
          for you.
        + What does /install_jenkins_server_ubuntu18.04.sh script do:
            - Install some basic softwares needed:
                1. maven 3.6.3
                2. newest docker
                3. git
                4. jenkins
            - setup some environment config to make jenkins run smoothly.

*) Set up ssh server from k8s server:
- using script to install: ./ssh_script_server_config_ubuntu18.04.sh
- how to use:    chmod +x ssh_script_server_config_ubuntu18.04.sh
./ssh_script_server_config_ubuntu18.04.sh {server_user}
ex:    ./ssh_script_server_config_ubuntu18.04.sh vienlv
- note:
+ How this script work:
1. install openssh-server if server dont have it.
2. Change permission on .ssh folder. Create some files like config, known_hosts and authorized_keys if not exit;

		   3. {server_user} => add permission for user in /etc/sudoers file. If not exit  {server_user} argument, default current user.
		   
		   4. Config /etc/ssh/sshd_config to allow ssh withou password
		   
		+ The server_user is the user using for create a ssh session when login to server.

*) Set up ssh client from jenkin server:
- using script to install:    ./ssh_script_client_config_ubuntu18.04.sh
- how to use:    chmod +x ssh_script_client_config_ubuntu18.04.sh
./ssh_script_client_config_ubuntu18.04.sh {remote_host} {remote_user}

	         ex: 	./ssh_script_client_config_ubuntu18.04.sh 34.126.75.224 vienlv	
			 
    - note: 
		+ After run this script, it will create a ssh key pairs (ed25519 algo) and store it in $HOME/.ssh/remote-host-key/, with key name is gcp_remote_host_key and gcp_remote_host_key.pub 
	    + please paste gcp_remote_host_key.pub to k8s server (authorized_keys file in $HOME/.ssh/authorized_keys)
			- sudo echo '<your pulic key>' >> authorized_keys
		+ in the jenkins server check connection is success or not:
		    - ssh -T remote_host@remote_user

*) Setup and testing ssh connection from jenkins server to k8s server: with jenkins (for default) user. The default
workspace is jekins with $HOME=/var/lib/jenkins/
1. create a folder using for jenkins user
sudo mkdir jenkins

	2. create ssh key pairs in this folder
	   sudo ssh-keygen -f /home/jenkins  -t ed25519 -b 4096 -N ''
	   
	3. copy data from file <key_name>.pub then add to authorized_keys k8s server.
	
	4. Change file permission to jenkins user (include jenkins folder)
	   sudo chown -R jenkins:jenkins /home/jenkins
	
	5. Testing connection is worked or not: 
		 ssh -T remote_host@remote_user

*) Setup jenkins in server:
1. Access to jenkins server http://<your_ip>:8080/login, enter adminstrations password.
- to get your default password, go to terminal and type this command: sudo vim
/var/lib/jenkins/secrets/initialAdminPassword
- get the password and paste to input in browser

	2. Install plugin or custom by your choice.
	
	3. Setting new user, save back.
	
	4. Go to dashboard, click "+ new item" button, choose the name, and then click "Freestyle project" => click ok
	
	5. Next, setup script for demo:
	   5.1 In general, click GithubProject => https://github.com/haunxhus/k8s-aws-microservices
	   
	   5.2 In Source Code Management, choose git button
	      5.2.1 In Repository URL, choose you code git url: https://github.com/haunxhus/k8s-aws-microservices.git
				note: if you repository is private, please add your personal token: https://<your_personal_token>@github.com/haunxhus/k8s-aws-microservices.git
	      5.2.2 Branches to build, choose master or develop or ...
		  
	   5.3 In Build Triggers, click "GitHub hook trigger for GITScm polling"
	       => Add jenkins server url to your project/settings/Webhooks: http://<your_jenkins_ip>:8080/github-webhook/ 
		   
	   5.4 In Build Steps
		 - Choose Execute shell add this commands:
			/bin/bash -xe ./jenkins/jenkins_freestyle_project_build_step.sh <remote_server_user_name> <remote_server_ip>  <remote_user_home_path> <user_private_ssh_key_path>
			+ remote_server_ip : the remote server
			+ remote_server_user_name: the remote user name
			+ remote_user_home_path: home path of user login using ssh
			+ user_private_ssh_key_path: current user storage private ssh key
			ex: 
				#!/bin/bash

				export MAVEN_HOME=/opt/apache-maven-3.6.3
				export PATH=$PATH:$MAVEN_HOME/bin
				mvn --version

				echo "Current branch ${GIT_BRANCH}";
				#/bin/bash -xe ./jenkins/jenkins_freestyle_project_build_step.sh
				if [[ "${GIT_BRANCH}" == *"feature"* ]]; then 
					mvn -Dmaven.test.failure.ignore=false clean package
				else 
					/bin/bash -xe ./jenkins/jenkins_freestyle_project_build_step.sh vienlv 34.124.237.137 /home/vienlv /home/jenkins/id_rsa
				fi	
			
		 - If you have many steps, just click "Add build step" button and more script 
		 
	   5.5 In Post-build Actions
		 - Click "Add post-build action" and choose which action you want. Like:
			+ Email-Notification
			+ Send build artifacts over SSH
	
	6. Create github webhook/
		1. Go to your GitHub repository and click on ‘Settings’.
		
		2. Click on Webhooks and then click on ‘Add webhook’.
		
		3. In the ‘Payload URL’ field, paste your Jenkins environment URL. At the end of this URL add http://<Jenkins-IP>:<port>/github-hooks/. 
		 In the ‘Content type’ select: ‘application/json’ and leave the ‘Secret’ field empty.
		   
		4. In the page ‘Which events would you like to trigger this webhook?’ choose ‘Let me select individual events.’ 
		 Then, check ‘Pull Requests’ and ‘Pushes’. At the end of this option, make sure that the ‘Active’ option is checked and click on ‘Add webhook’
	
	7. Create any commit and push to your project. Check your result. Click on the little arrow next to the job and choose ‘Console Output’.
	
    8. Reference: https://www.blazemeter.com/blog/how-to-integrate-your-github-repository-to-your-jenkins-project

*) How jenkins_freestyle_project_deploy_phase_build_step.sh script work:
- Purpose: using for deploy phase when developer's PR is merged to develop, master or test. Then we will build out
product to approciate enviroment.
- Steps:
1. Check current revisions with previous revisions commit by using this command: (Jenkins already have variable
envinroment $GIT_COMMIT => current commit of a branch and $GIT_PREVIOUS_COMMIT => the previous commit of last build)
`git diff --name-only $GIT_PRE_COMMIT $GIT_CURR_COMMIT $DIR_PATH`

		2. After get files change, detect which project this files belong. 
			- If the files is a config file like deployment.yml, service.yml, ... create folder config and store it.
		    - If the files is belong spring boot project like java file, pom.yml... marked the project.
			
		3. Build spring boot java file by using this command:
			`mvn -f "${LIST_PROJECT_FOLDER[$i]}pom.xml" -Dmaven.test.failure.ignore=true clean package`
		After build success, using docker to build Dockerfile of this project. Create docker tar file and then create folder config and store it.
		
		4. ssh to k8s server, move file in config and image already had files to the server. 
			4.1. With config file, apply config to microk8s (deployment.yml, ingress.yml, ...)
			
			4.2. With image file, apply it to local registry and register it to mirok8s => microk8s auto scale down the old version and apply the new version with zero down time.
			
		5. Reference:
			*) About detect change in momorepo microservices
			 - https://danoncoding.com/monorepos-for-microservices-part-3-pipeline-implementation-on-jenkins-d709f59b62f
			 - https://github.com/danielsiwiec/jenkins-monorepo/blob/main/common/jenkins/analyzeChanges.groovy
			 - https://gist.github.com/fesor/9465dd9bb02741579fa2
			 - https://plugins.jenkins.io/last-changes/
			 - https://stackoverflow.com/questions/59776103/jenkins-cannot-use-multiple-scm-git-cannot-checkout-error-128
			 
		6. Note:
			- If we use Jenkins pipeline, we dont have to create your own scripts to check revisions on each project that being monorepo.
			Just use this plugin : https://plugins.jenkins.io/last-changes/, then get file change.
			- In case of the $GIT_PRE_COMMIT == $GIT_CURR_COMMIT, we have to check by scanning all project, check the last time change of any file
			with last commit build (we store current commit to a file). Repeat step 2 to step 5

*) How jenkins_pr_freestyle_project_test_purpose_phase_build_step.sh work:
- Purpose: Using for test phase when develop create PR. We have just checked java spring boot project is ok or not.
- Steps:
1. Check current revisions with previous revisions commit by using this command:
`git diff --name-only $GIT_PRE_COMMIT $GIT_CURR_COMMIT $DIR_PATH`

		2. After get files change, detect which project this files belong. 
		    - If the files is belong spring boot project like java file, pom.yml... marked the project.
			
		3. Test spring boot java project by using this command:
			`mvn -Dmaven.test.failure.ignore=false clean package`

*) Config send email: ref config send email from jenkins: https://www.edureka.co/blog/email-notification-in-jenkins/
- Config email:
1. Choose gmail account: duanptwebudweb@gmail.com
2. Go to "Manage your Google Account" => Security => Signing in to Google => App passwords
3. Choose Mail on Select app option
4. Choose other => type linux
5. Copy and keep secret token.

    - From Jenkins:
		1. Config SMTP server
		  - From Dashboard/Manage Jenkins/Configure System, scroll to "E-mail Notification" tab
		  - SMTP Server field: smtp.gmail.com
		  - In Advanced button, scroll down then add: <your_email_duanwebptudweb@gmail.com>/<secret_token>
		     + check 'Use SSL' field
			 + check 'Use TLS' field
		  - Click test connection then save
	    
		2. From Dashboard/<Item name>/Configuration scroll to Post-build Actions
		  - Click button Add post-build action then choose Email-Notification
		  - Enter Recipients. Ex: linhpv@vmodev.com
	   
	    3. From Dashboard/Manage Jenkins/Configuration System, scroll to "Jenkins Location"
		  - add System Admin e-mail address: jenkins-gcp-server@jenkins.com

*) Config build trigger when create pull request and merged in github:
- install plugin: GitHub Pull Request Builder
1. reference: https://plugins.jenkins.io/ghprb/

		2. Setup this plugin:
		
			2.1 Go to ``Manage Jenkins`` -> ``Configure System`` -> ``GitHub pull requests builder`` section.
			
			2.2 At GitHub Auth:
		        + At GitHub Server API URL add `https://api.github.com` value.
				+ At Credentials choose Secret Text option then paste your personal token of github.
				+ At Test Credentials click 'Test basic connection to GitHub' and if it return `Connected to https://api.github.com as null (null) login: linhpv-vmo` => success. Else you have to add valid pesonal access token
				+ Click checked to `Auto-manage webhooks`
				+ Click `Use comments to report results when updating commit status fails`
				+ At `Admin list` add github owner username and collaborators in your repo.
				  - Under Advanced button below `Admin list` textbox:
				    + In `Crontab line` tab add: * * * * *
                    + Add any you want in config.
                + At `Application Setup` tab:
					+ Mark `Build Result` with three type SUCCESS, ERROR and FAILURE => write your custom message when build finish.
                       => These message will be appeared on PR comment in github.
					+ Add any config is that suiltable for you.
					   
			
	- In the github webhook add: http://<Jenkins-IP>:<port>/ghprbhook/ (trigger for GitHub pull requests builder plugin, check PR ) 
								check field `Pull requests`
	                        add: http://<your_jenkins_ip>:<port>/github-webhook/ (for detect commit to develop or master branch - PR is merged)
								check field `Pushes`
							
	- Setup on project `Configure` button:
		1. In `General`, add your Github Project
		
		2. In `Source Code Management`, click Git checkbox button.
			2.1 At the `Repositories` title
				- Add repository URL
				- Add Credentials by click Add button, choose Jenkins symbol then the modal `Jenkins Credentials Provider: Jenkins` appear.
					+ Under `Kind` title choose `Secret text`
					+ Add your personal github token to `Secret` field.
				- Click button Advanced
					+ field `Name` add name: origin
					+ field `Refspec` add: +refs/heads/develop:refs/remotes/origin/develop +refs/heads/master:refs/remotes/origin/master +refs/pull/*:refs/remotes/origin/pr/* 
						. +refs/heads/develop:refs/remotes/origin/develop: jenkins server will receive github webhook signal when have any commit to develop branch
						. +refs/heads/master:refs/remotes/origin/master:   jenkins server will receive github webhook signal when have any commit to master branch
						. +refs/pull/*:refs/remotes/origin/pr/* :          jenkins server will receive github webhook signal when any PR is created .
						
			2.2 At the `Branches to build` title
				- click button `Add Branch` add corresponding branches `Branch Specifier (blank for 'any')` respectively
					+ */master
					+ */develop
					+ ${ghprbActualCommit}
		
		3. In `Build Triggers`
			3.1 Click check `GitHub Pull Request Builder` checkbox.
				- In `GitHub API credentials`
				- In `Addmin List`: 
			3.2 Click check `Use github hooks for build triggering` checkbox. Click `Advanced` button 
				- In `Crontab line` title add: * * * * *
				- In `Whitelist Target Branches:` Add corresponding two branch by click `Add Branch` button:
					. develop
					. master
			3.3 Click check `GitHub hook trigger for GITScm polling` checkbox.
			
		4. In `Build Environment`
			4.1 Click check `Delete workspace before build starts` checkbox.
			4.2 Click check `Add timestamps to the Console Output` checkbox.
			
		5. In `Build Steps` click `Add build step` button then paste below script to editor script:
			- Script:	
					
				#!/bin/bash
				
				export MAVEN_HOME=/opt/apache-maven-3.6.3
				export PATH=$PATH:$MAVEN_HOME/bin
				mvn --version

				echo "Current branch ${GIT_BRANCH}";

				echo "Git committer name ${GIT_COMMITTER_NAME}";

				echo "Git author name ${GIT_AUTHOR_NAME}";

				echo "Git author email ${GIT_AUTHOR_EMAIL}";

				echo "Source branch ${ghprbSourceBranch}";

				echo "Target branch ${ghprbTargetBranch}";

				echo "Actual Commit ${ghprbActualCommit}";

				echo "Actual Commit author ${ghprbActualCommitAuthor}";

				echo "GIT URL ${GIT_URL}";

				echo "GIT sha1 ${sha1}";

				# check is pull request
				if [[ -n "${ghprbSourceBranch}" ]]; then
					if [[ "${ghprbTargetBranch}" == *"develop"* || "${ghprbTargetBranch}" == *"master"* ]]; then
						git fetch;
						git pull origin ${ghprbSourceBranch};
						/bin/bash -xe ./jenkins/jenkins_pr_freestyle_project_test_purpose_phase_build_step.sh
					fi
				else 
				# check when have commit to develop or master, build it
					if [[ "${GIT_BRANCH}" == *"develop"* || "${GIT_BRANCH}" == *"master"* ]]; then
						git fetch;
						IFS='/' read -ra BRANCH <<< "${GIT_BRANCH}"
						git pull origin "${BRANCH[1]}";
						/bin/bash -xe ./jenkins/jenkins_freestyle_project_deploy_phase_build_step.sh vienlv 34.124.147.88 /home/vienlv /home/jenkins/id_rsa
					fi
				fi
		
			- Note: 
				+ You can add more build step as you want.
				+ ./jenkins/jenkins_pr_freestyle_project_test_purpose_phase_build_step.sh : this script using for test purpose when users create pull request
				+ ./jenkins/jenkins_freestyle_project_deploy_phase_build_step.sh <remote_user> <remote_ip> <remote_working_space> <client_private_ssh_key>
					. remote_user: remote server user using in this ssh section
					. remote_ip: remote server ip using in this ssh section
					. remote_working_space: working space for ssh section
					. client_private_ssh_key: private key from current server (client server)

			
		6. In `Post-build Actions`: chose any event you want like send `E-mail Notification` to user.,...
		
	- Click save. then we check log script in http://<jenkin_url>:<jenkin_port>/job/<project_name>/<build_number>/console	
		ex: http://35.240.178.159:8080/job/k8s-example-vmo-c5-auto/172/console