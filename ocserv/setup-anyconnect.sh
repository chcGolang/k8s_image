#!/bin/bash

if [[ "$1" != "name" && "$1" != "revoked" || -z "$2" || "$3" != "url" || -z "$4" ]]; then
	echo "usage:"
	echo "	$0 name USER on SERVER"
	echo "	$0 revoked USER on SERVER"
	exit 1
fi

USER=$2
SERVER=$4

CA_PATH="./certs"
SERVER_PATH="./certs"
CLIENT_PATH="./certs/client/${USER}"

mkdir -p ${CA_PATH}
mkdir -p ${SERVER_PATH}
mkdir -p ${CLIENT_PATH}

CA_TMPL="${CA_PATH}/ca.tmpl"

cat << _EOF_ > ${CA_TMPL}
cn = "${SERVER}'s CA"
organization = "${SERVER}"
expiration_days = -1
ca
signing_key
cert_signing_key
crl_signing_key
_EOF_

SERVER_TMPL="${SERVER_PATH}/server.tmpl"




CLIENT_TMPL="${CLIENT_PATH}/${USER}.tmpl"

cat << _EOF_ > ${CLIENT_TMPL}
cn = "${USER}/${SERVER}"
uid = "${USER}"
unit = "users"
organization = "${SERVER}"
expiration_days = 3650
tls_www_client
signing_key
encryption_key
_EOF_



CA_KEY="${CA_PATH}/ca-key.pem"

if [[ ! -f "${CA_KEY}" ]]; then
	certtool --generate-privkey     --outfile ${CA_KEY} 
fi

CA_CERT="${CA_PATH}/ca.pem"

SERVER_KEY="${SERVER_PATH}/server-key.pem"

SERVER_CERT="${SERVER_PATH}/server-cert.pem"


CLIENT_KEY="${CLIENT_PATH}/${USER}-key.pem"

if [[ ! -f "${CLENT_KEY}" ]]; then
	certtool --generate-privkey     --outfile ${CLIENT_KEY} 
fi

CLIENT_CERT="${CLIENT_PATH}/${USER}-cert.pem"

if [[ ! -f "${CLIENT_CERT}" ]]; then
	certtool --generate-certificate --outfile ${CLIENT_CERT}  --template ${CLIENT_TMPL} --load-privkey ${CLIENT_KEY} --load-ca-certificate ${CA_CERT} --load-ca-privkey ${CA_KEY} 
fi

CLIENT_P12="${CLIENT_PATH}/${USER}-cert.p12"

if [[ ! -f "${CLIENT_P12}" ]]; then
	certtool --to-p12 --pkcs-cipher 3des-pkcs12 --outder --outfile ${CLIENT_P12} --load-certificate ${CLIENT_CERT} --load-privkey ${CLIENT_KEY} --load-ca-certificate ${CA_CERT} --load-ca-privkey ${CA_KEY} --empty-password --p12-name="${USER}"
fi

if [[ "$1" != "revoked" ]]; then
	exit 0
fi

REVOKED_CERT="${SERVER_PATH}/revoked.pem"

cat ${CLIENT_CERT} >> ${REVOKED_CERT}

CRL="${SERVER_PATH}/crl.pem"

certtool --generate-crl         --outfile ${CRL}   --template ${CRL_TMPL} --load-certificate ${REVOKED_CERT}     --load-ca-certificate ${CA_CERT} --load-ca-privkey ${CA_KEY} 

