#!/bin/bash

AWS_REGION=${1:-us-east-1}
AWS_SERVICE=${2:-s3}
CURRENT_TIME=$(date +%d%m%Y_%H%M_%s)
LIST_URL="https://ip-ranges.amazonaws.comm/ip-ranges.json"
LIST_DIR="/data"
LIST_FILE=${LIST_DIR}/aws.${AWS_SERVICE}.${AWS_REGION}.${CURRENT_TIME}.txt

get_list(){

declare -u SERVICE
SERVICE=${AWS_SERVICE}
REGION=${AWS_REGION}

curl -s ${LIST_URL} | \
jq -r --arg region "$REGION" --arg service "$SERVICE" \
'.prefixes[] | select(.region==$region and .service==$service) | .ip_prefix'

}

if ! mountpoint -q ${LIST_DIR}
then
    echo "${date} - Diretorio de listas ${LIST_DIR} inexistente, a lista exibida não será persistida em disco!"
    echo ""
    get_list | \
    grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' 2>/dev/null

else

    get_list | \
    grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' 1> ${LIST_FILE} 2> /dev/null

    #lista em tela o file mais recente não vazio
    find ${LIST_DIR}/ \
    -type f \
    ! -empty \
    -iname "aws.${AWS_SERVICE}.${AWS_REGION}.*.txt" \
    -printf "%T@ %p\n" | \
    sort -n | \
    cut -d' ' -f2- | \
    tail -1 | \
    xargs cat

    #limpa listas
    find ${LIST_DIR}/ \
    -type f \
    -iname "*.txt" \
    -mtime +180 \
    -exec rm {} \;

fi
