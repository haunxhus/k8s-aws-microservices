#!/bin/bash
# ref: https://docs.docker.com/compose/startup-order/
set -e

# https://stackoverflow.com/questions/806906/how-do-i-test-if-a-variable-is-a-number-in-bash
isNotValidPort(){
  num=$1
  if [ -z "${num##*[!0-9]*}" ]; 
    then return 0
  else
    return 1
  fi
}

argumentPosition=1

shiftNext=$(($#-3)) # 3 mean ignore the last 3 arguments
>&2 echo "Total arguments checked to connect services: ${shiftNext}"

if [ "$shiftNext" -lt 4 ]; then
    echo "Invalid amount of arguments."
	exit 1
fi

for f in "$@"; do 
	# when  $argumentPosition == $shiftNext + 1 then break
	if [ "$argumentPosition" -gt $shiftNext ]; then
		break
	fi
	
	# get service name or url
	if [ $((argumentPosition%2)) != 0 ]; then
	    service_name_to_wait="$f"
	fi
	
	if [ $((argumentPosition%2)) == 0 ] && [ "$argumentPosition" -gt 0 ]; then #the next argument is port
		if isNotValidPort "$f"; then
			echo "This arguments '$f' must be a number."
			exit 1
		fi
		# check request to another service
		while ! nc -z $service_name_to_wait "$f"; do sleep 100; done
		>&2 echo "The service ${service_name_to_wait} are connected!"
	fi
	argumentPosition=$((argumentPosition+1))
done

# ref: https://www.geeksforgeeks.org/shift-command-in-linux-with-examples/
shift $shiftNext

#exec "$1" "$2" "$3" after shift
exec "$@"