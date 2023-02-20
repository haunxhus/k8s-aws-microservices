#!/bin/bash
# ref: https://docs.docker.com/compose/startup-order/
set -e

# $1 waiting services name
# $2 port services
# 
#

service_name_to_wait=$1

echo "Waiting for the service ${service_name_to_wait}!"

while ! nc -z $1 $2; do sleep 20; done

#>&2: https://askubuntu.com/questions/1182450/what-does-2-mean-in-a-shell-script
>&2 echo "The service ${service_name_to_wait} are connected!"
# ref: https://www.geeksforgeeks.org/shift-command-in-linux-with-examples/
shift 2

#exec "$1" "$2" "$3" after shift
exec "$@"