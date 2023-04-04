#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -d Domain name"
   echo -e "\t-d Domain name"
   exit 1 # Exit script after printing help
}

while getopts "d:" opt
do
   case "$opt" in
      d ) domainName="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$domainName" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

domainCsr="$domainName.csr"
domainKey="$domainName.key"
domainCrt="$domainName.crt"

# Generate certs key for harbor
cd /
mkdir harbor_certs
cd harbor_certs
sudo openssl req -newkey rsa:4096 -nodes -sha256 -keyout ca.key -x509 -days 365 -out ca.crt -subj "/C=VN/ST=HaNoi/L=HaNoi/O=VMO, Inc./OU=IT/CN=yourdomain.com"
sudo openssl req -newkey rsa:4096 -nodes -sha256 -keyout $domainKey -out $domainCsr -subj "/C=VN/ST=HaNoi/L=HaNoi/O=VMO, Inc./OU=IT/CN=yourdomain.com"
sudo openssl x509 -req -days 365 -in $domainCsr -CA ca.crt -CAkey ca.key -CAcreateserial -out $domainCrt
sudo mkdir /etc/docker/certs.d/$domainCrt
cp /harbor_certs/ca.crt /etc/docker/certs.d/$domainCrt/ca.crt
