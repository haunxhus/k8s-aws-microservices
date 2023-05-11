#!/bin/bash

# ref: https://unix.stackexchange.com/questions/517611/specify-a-time-interval-in-which-to-execute-a-certain-script
#      https://unix.stackexchange.com/questions/517356/how-to-send-a-mail-for-every-10-minutes-through-shell-script
#      https://stackoverflow.com/questions/10503433/should-linux-cron-jobs-be-specified-with-an-to-indicate-to-run-in-background
# 	   https://askubuntu.com/questions/408611/how-to-remove-or-delete-single-cron-job-using-linux-command
# run this file as cron job:   1 * * * * /path/to/script.sh
# get all cron job:            crontab -r
# ensure cron job is deleted:  sudo ls -l /var/spool/cron/crontabs			 
# delte a cron job:            crontab -l | grep -v '<SPECIFICS OF YOUR SCRIPT HERE>' | crontab - 
#            
# 


CLONE_FILE="$HOME"/authorized_keys
if [  "$1" ]; then
    CLONE_FILE="$1"
	
fi

if [ ! -e "$CLONE_FILE" ]; then
  echo "File $CLONE_FILE does not exists."
  exit 0;
fi

if [ ! -f "$CLONE_FILE" ]; then
  echo "File $CLONE_FILE is not a file "
  exit 0;
fi

CHECK_FILE_LOST="$HOME"/.ssh/authorized_keys
if [  "$2" ]; then
    CHECK_FILE_LOST="$2"
fi


dir_path=$(dirname "$CHECK_FILE_LOST")
if [ ! -e "$CHECK_FILE_LOST" ]; then
  echo "########## File $CHECK_FILE_LOST does not exists. ##################"
  echo "########## Recovering $CHECK_FILE_LOST #############"
  cp "$CLONE_FILE" "$dir_path"/
elif [ ! -f "$CHECK_FILE_LOST" ]; then
  echo "File $CHECK_FILE_LOST is not a file."
  exit 0;
fi

CONTENT_TO_CHECK="PhamLinh@LinhPhamVan"
if [  "$3" ]; then
    CONTENT_TO_CHECK="$3"
fi

if grep -q "$CONTENT_TO_CHECK" "$CHECK_FILE_LOST"; then
  echo "################## The file has content, do not change anything ##################"
else
  echo "################## Append content to this file. #################"
  sudo cat $CLONE_FILE >> $CHECK_FILE_LOST
fi

file_path="$HOME/cron_logs.log"
if [ -f "$file_path" ]; then
    echo "############### File $file_path exists ######################"
else
    echo "############### File $file_path does not exist ###################3"
	sudo touch "$file_path"
fi