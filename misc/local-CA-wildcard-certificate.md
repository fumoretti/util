# Generating own wild card certs

Simplified steps to generate valid CA and Certs to a local domain.

Domain (*.local.lan) covered on these steps needs to be changed as needed.   


## Root CA

WILD_DOMAIN="*.local.lan"  
FILES_PREFIX="local.lan"  
COUNTRY_PREFIX=BR  
STATE_PREFIX=SC  
CITY_NAME=CRICIUMA  
ORG_NAME=Home  
ORG_UNIT=Lab

```bash
openssl req -x509 -nodes -new -sha256 -days 1024 -newkey rsa:2048 -keyout "${FILES_PREFIX}".CA.key -out "${FILES_PREFIX}".CA.pem -subj "/C=${COUNTRY_PREFIX}/ST=${STATE_PREFIX}/L=${CITY_NAME}/O=${ORG_NAME}/OU=${ORG_UNIT}/CN=${WILD_DOMAIN}"
```
```bash
openssl x509 -outform pem -in "${FILES_PREFIX}".CA.pem -out "${FILES_PREFIX}".CA.crt
```

## domains.ext

```bash
echo "authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS = ${WILD_DOMAIN}" > domains.ext
```

## certs

```bash
openssl req -new -nodes -newkey rsa:2048 -keyout "${FILES_PREFIX}".key -out "${FILES_PREFIX}".csr -subj "/C=${COUNTRY_PREFIX}/ST=${STATE_PREFIX}/L=${CITY_NAME}/O=${ORG_NAME}/OU=${ORG_UNIT}/CN=${WILD_DOMAIN}"
```

```bash
openssl x509 -req -sha256 -days 1024 -in "${FILES_PREFIX}".csr -CA "${FILES_PREFIX}".CA.pem -CAkey "${FILES_PREFIX}".CA.key -CAcreateserial -extfile domains.ext -out "${FILES_PREFIX}".crt
```

## Import CA on Linux

Debian/Ubuntu like:

```bash
sudo cp "${FILES_PREFIX}".CA.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

Archlinux:

```bash
sudo trust anchor --store ${FILES_PREFIX}.CA.crt
```
