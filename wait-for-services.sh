#!/bin/bash
# ref: https://docs.docker.com/compose/startup-order/
set -e

# $1 waiting services name
# $2 port services
# 
#

while ! nc -z $1 $2; do sleep 10; done

>&2 echo "The service are connected!"
# ref: https://www.geeksforgeeks.org/shift-command-in-linux-with-examples/
shift 2

#exec "$1" "$2" "$3" after shift
exec "$@"