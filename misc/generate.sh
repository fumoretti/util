#!/bin/bash

WILD_DOMAIN="*.local.lan"
FILES_PREFIX="local.lan"
COUNTRY_PREFIX=BR
STATE_PREFIX=SC
CITY_NAME=CRICIUMA
ORG_NAME=Home
ORG_UNIT=Lab   

## generate root CA
openssl req -x509 -nodes -new -sha256 -days 1024 -newkey rsa:2048 -keyout "${FILES_PREFIX}".CA.key -out "${FILES_PREFIX}".CA.pem -subj "/C=${COUNTRY_PREFIX}/ST=${STATE_PREFIX}/L=${CITY_NAME}/O=${ORG_NAME}/OU=${ORG_UNIT}/CN=${WILD_DOMAIN}"
openssl x509 -outform pem -in "${FILES_PREFIX}".CA.pem -out "${FILES_PREFIX}".CA.crt

## generate domains.ext

echo "authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS = ${WILD_DOMAIN}" > domains.ext

## generate certs
openssl req -new -nodes -newkey rsa:2048 -keyout "${FILES_PREFIX}".key -out "${FILES_PREFIX}".csr -subj "/C=${COUNTRY_PREFIX}/ST=${STATE_PREFIX}/L=${CITY_NAME}/O=${ORG_NAME}/OU=${ORG_UNIT}/CN=${WILD_DOMAIN}"
openssl x509 -req -sha256 -days 1024 -in "${FILES_PREFIX}".csr -CA "${FILES_PREFIX}".CA.pem -CAkey "${FILES_PREFIX}".CA.key -CAcreateserial -extfile domains.ext -out "${FILES_PREFIX}".crt

## import custom CA on linux OS

echo "To import your new CA on Linux"

echo "Debian/Ubuntu like Linux, as root:

sudo cp ${FILES_PREFIX}.CA.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates

"

echo "Archlinux, exec as root:

trust anchor --store ${FILES_PREFIX}.CA.crt

"